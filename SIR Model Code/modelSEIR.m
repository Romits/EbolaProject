function modelSEIR

% Population Size
N = 4000000;

% The data we use to fit
load dataLiberia
%data = [3,6,25,73,222,294,258,237,191,125,69,27,11,4];
%data = round(diff(infected));
data = diff(infected);%round(infected);
% Initial Guesses for  beta and gamma.
b0 = 0.33; % transmission rate per person per day range 0<b<1
k0 = 1/5.3; % mean incubation period (1/k) is 6.3 days, range 1<(1/k)<21]
g0 = 1/5.61; % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7

initialCondition  = [b0 k0 g0];
lowerBound = [0 0 0];%(1/20.999)(1/10.699)];
%upperBound = [1 (1/1.001) (1/3.499)];
upperBound = [Inf Inf Inf];
% lsqnonlin will return the parameter values for beta and gamma and the norm
% of the residual function
%[p,resnorm] = lsqnonlin(@SIR0,[b0 g0],[0 0],[inf inf])
[p,resnorm] = lsqnonlin(@SEIR0,initialCondition,lowerBound,upperBound);


% Define a separate time vector for a more smooth solution to ODE
tspan = (0:0.1:length(data));

% Define the initial conditions for S and I
y0 = [N-1 1 1];

% Integrate the ODEs with the optimal parameter values
[t,y] = ode45(@SEIR,tspan,y0,[],[N p]);
dataModel =  y(:,3);

% Time steps over which we will solve the ODE, chosen to match days of data
% collection
t_vals = (1:length(data));

% Plot the solution of I(t) with the data
figure(1)
plot(t,dataModel,'r')
hold on;
plot(t_vals,data,'g--')
hold off;

R0 = p(1)/p(2)

end




% A function to run the ODE and return the value for I
function I = SIR0(p0)

% Redeclare initial conditions and N
N = 763;
x0 = [N-1 1];

% Set up the parameter vector to be passed
p = [N p0];

% Define the time over which to solve the ODE
tspan = (0:14);

% Calls the ODE solver with the current parameter guess
[t,y] = ode45(@SIR,tspan,x0,[],p);

% Calculates the residuals to be minimized
data = [3,6,25,73,222,294,258,237,191,125,69,27,11,4];
I = y(2:end,2) - data';

end

% A function to run the ODE and return the value for I
function I = SEIR0(p0)

load dataLiberia
data = round(infected);

% Redeclare initial conditions and N
N = 4000000;
x0 = [N-1 1 1];

% Set up the parameter vector to be passed
p = [N p0];

% Define the time over which to solve the ODE
%tspan = (0:14);
tspan = (0:length(data));

% Calls the ODE solver with the current parameter guess
[t,y] = ode45(@SEIR,tspan,x0,[],p);

% Calculates the residuals to be minimized
%data = [3,6,25,73,222,294,258,237,191,125,69,27,11,4];
%dataModel = cumsum( p(3) * y(2:end,2) )./(1:length(y)-1)';
dataModel = y(2:end,3);

I = dataModel - data;
sum((I).^2)
end
function y = SEIR(t,x,p)

N = p(1);
b = p(2);
k = p(3);
g = p(4);


S = x(1);
E = x(2);
I = x(3);

y = [- b* S* I /N;
(b * S * N / N) - (k * E);
(k * E) - (g * I)];

end


% The function containing the ODEs
function y = SIR(t,x,p)

N = p(1);
b = p(2);
g = p(3);

S = x(1);
I = x(2);

y = [-b*S*I/N;
    b*S*I/N-g*I];

end