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
isTest = 0;
isOptimize = 1;
isCv = 1;
if (isOptimize)
    param0 = [0.2500 5.5000 0.2000 0.1000];
    % lsqnonlin will return the parameter values for beta and gamma and the norm
    % of the residual function
    options = optimset('MaxFunEvals',4000);
     if (isCv)
    performCrossValidation(param0,lowerBound,upperBound,options, infectedData, day2, 200)
    end
    [p,resnorm] = lsqnonlin(@SEIR1,param0,lowerBound,upperBound,options, infectedData, day2);
    p
    resnorm
end

if isTest
    %p = [  0.2407    5.4957    0.2084   32]
    p=[ 0.2 6.8 0 0];
    testOnevalueGuinea(p, day2, infectedData, dayDead, deadData);
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

    tspan =0:1:394;
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

function performCrossValidation(param0,lowerBound,upperBound,options,  infected, dayI, dayIdx)
    idx = find(dayI>=dayIdx,1);
    e = [];
 
    while (idx+1<=length(dayI))
        infected1 = infected(1:idx);
        dayI1 = dayI(1:idx);
        infected2 = infected(idx+1);
        dayI2 = dayI(idx+1);
         [beta,resnorm] = lsqnonlin(@SEIR1,param0,lowerBound,upperBound,options, infected1, dayI1);
 %           [p,resnorm] = lsqnonlin(@SEIR1,param0,lowerBound,upperBound,options, infectedData, day2);
        [t,y] = ode45(@SEIR,[0:1:394],[ 999999           0           1           0],[],[1000000 beta(1) 1/beta(2) beta(3) beta(4)]);
        infected11 = cumsum(y(:,2)/6.3);

        %[t, infected11, death1] = SEIR0Liberia(beta(1), 6.3, beta(2),beta(3),beta(4));
        e = [e infected11(t==dayI2) - infected2];
        idx = idx+1;
    end
    e
 
    
end

function [t, infected, death] = SEIR0Liberia(a,b,c,d,e) 
b0 = a; % transmission rate per person per day range 0<b<1
k0 = 1/b; % mean incubation period (1/k) is 6.3 days, range 1<(1/k)<21] %5.5
g0 = 1/c; % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7

p0  = [b0 k0 g0 d e];


% Redeclare initial conditions and N
N = 10000000;
x0 = [N-1 0 1 0];

% Set up the parameter vector to be passed
p = [N p0];

tspan =0:1:394;
% Calls the ODE solver with the current parameter guess
[t,y] = ode45(@SEIR,tspan,x0,[],p);
infected = cumsum(y(:,2)*k0);
death = cumsum(y(:,3)*g0);

end