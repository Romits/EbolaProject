function OptimizeSir
lowerBound = [0 3.5  0   0];
upperBound = [1 10.7 1   100];

load dataGuinea1
day1 = day1+110; % first day in day1 is march 22
idxI = find(infected>0);
idxD = find(death>0);
infectedData = infected(idxI);
day2 = day1(idxI);

deadData = death(idxD);
dayDead = day1(idxD);
    
param0 = [0.2500 5.5000 0.2000 0.1000];
% lsqnonlin will return the parameter values for beta and gamma and the norm
% of the residual function
options = optimset('MaxFunEvals',4000);
[betaHat,resnorm] = lsqnonlin(@SEIR1,param0,lowerBound,upperBound,options, infectedData, day2);
disp(betaHat);



%testOnevalueGuinea(p, day2, infectedData, dayDead, deadData);

%% estimating 95% CI by constructing boostrap sample

% get the residuals
I = SEIR2(betaHat, day2);
residuals = infectedData - I;

% resample the residuals using bootstrp fuction
nboot = 100; % number of bootstrap replicates
[~, bootIndices] = bootstrp(nboot,[],residuals);
bootResiduals = residuals(bootIndices);

% generate bootstrap datasets by adding the resampled residuals to the best
% fit curve
yFit = I;
yBoot = repmat(yFit, 1, nboot) + bootResiduals;

% Estimate the modelparameters again, by using the bootstrap data set as
% observed dataset, for each of the nboot sets
% store the estimates
betaBoot = zeros(nboot,length(betaHat));

for i = 1:nboot
    betaBoot(i,:) = lsqnonlin(@SEIR1,param0,lowerBound,upperBound,[], yBoot(:,i), day2);
    %nlinfit(dose, yBoot(:,i), @Hill, betaGuess);%, options);
    disp(betaBoot(i,:));
end

bootCI = prctile(betaBoot, [2.5 97.5]);
disp('bootstrap CI: ');
disp([betaHat' bootCI']);
disp('asymptotic CI: ');
disp([betaHat' asympCI]);



end
function res = SEIR1(input, infectedData, day2) 
    b0 = input(1); % transmission rate per person per day range 0<b<1
    k0 = 1/6.3; % mean incubation period (1/k) is 6.3 days, range 1<(1/k)<21] %5.5
    g0 = 1/input(2); % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7
    b1 = input(3);
    q = input(4);
    p0  = [b0 g0 b1 q];


    % Redeclare initial conditions and N
    N = 1000000;
    x0 = [N-1 0 1 0];

    % Set up the parameter vector to be passed
    p = [N p0];

    tspan =0:1:350;
    % Calls the ODE solver with the current parameter guess
    [t,y] = ode45(@SEIR,tspan,x0,[],p);
    I = cumsum(y(:,2)*k0);


    val = mean( (infectedData - I(day2)).^2) ./ mean(infectedData.^2);
    res = (infectedData - I(day2));
end


function I = SEIR2(input, day2)
    b0 = input(1); % transmission rate per person per day range 0<b<1
    k0 = 1/6.3; % mean incubation period (1/k) is 6.3 days, range 1<(1/k)<21] %5.5
    g0 = 1/input(2); % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7
    b1 = input(3);
    q = input(4);
    p0  = [b0 g0 b1 q];


    % Redeclare initial conditions and N
    N = 1000000;
    x0 = [N-1 0 1 0];

    % Set up the parameter vector to be passed
    p = [N p0];

    tspan =0:1:350;
    % Calls the ODE solver with the current parameter guess
    [t,y] = ode45(@SEIR,tspan,x0,[],p);
    I = cumsum(y(:,2)*k0);
    
    I = I(day2);

end



% The function containing the ODEs
function y = SEIR(t,x,p)
    N = p(1);
    b0 = p(2);
    k = 1/6.3;
    g = p(3);
    b1 = p(4);
    q = p(5);
    tau = 110;

    S = x(1);
    E = x(2);
    I = x(3);
    R = x(4);

    if t<tau
        b = b0;
    else
        b = b1 + (b0-b1)*exp(-q*(t-tau));
    end

    y = [- (b.* S* I /N);
    (b .* S * I / N) - (k * E);
    (k * E) - (g * I)
    (g * I)];
end

