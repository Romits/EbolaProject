function OptimizeSir
lowerBound = [0.001 3.5  0.001   0.001];
upperBound = [1 10.7 1   100];

load dataTotal1

   %0.2064    6.4914    0.2098   49.0775
param0 = [  0.2000     6.8000        0.01         1];
%param0 = [  0.200     6.8000        0.1         1];
% lsqnonlin will return the parameter values for beta and gamma and the norm
% of the residual function
options = optimset('MaxFunEvals',4000);
[beta, sse1, res1, exit1,output,lambda,J] = lsqnonlin(@SEIR1,param0,lowerBound,upperBound,options, infected, dayI);
%[beta,res1,J,CovB,MSE] = nlinfit(dayI, infected, @SEIR2, param0);%,lowerBound,upperBound,options, infected, dayI);
%%ci1 = nlparci(beta,res1,'covar',CovB);
% dfe = [#observations - #estimated parameters];
% [Q,R] = qr(jacobian,0);
% Rinv = inv(R);
% se = sqrt(sum(Rinv.*Rinv,2)*resnorm/dfe);

beta = [0.2 6.8 0 0];
testOnevalueGuinea(beta, dayI, infected, dayD, death);

end

function res = SEIR2(beta, x) 
    b0 = beta(1); % transmission rate per person per day range 0<b<1
    k0 = 1/6.3; % mean incubation period (1/k) is 6.3 days, range 1<(1/k)<21] %5.5
    g0 = 1/beta(2); % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7
    b1 = beta(3);
    q = beta(4);
    p0  = [b0 g0 b1 q];
    disp(beta);

    % Redeclare initial conditions and N
    N = 1000000;
    x0 = [N-1 0 1 0];

    % Set up the parameter vector to be passed
    p = [N p0];

    tspan =0:1:350;
    % Calls the ODE solver with the current parameter guess
    if (sum(beta<0)>0)
        res = zeros(1,length(x));
    else
    [t,y] = ode45(@SEIR,tspan,x0,[],p);
    I = cumsum(y(:,2)*k0);
    res = I(x);
    end

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
    disp(p0);
    disp(val)

    res = (infectedData - I(day2));
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

