% A function to run the ODE and return the value for I
function I = SEIR0 %(p0)
b0 = 0.27; % transmission rate per person per day range 0<b<1
k0 = 1/5.3; % mean incubation period (1/k) is 6.3 days, range 1<(1/k)<21]
g0 = 1/5.61; % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7

p0  = [b0 k0 g0];


% Redeclare initial conditions and N
N = 1000000;
x0 = [N-1 1 0 0];

% Set up the parameter vector to be passed
p = [N p0];

% Define the time over which to solve the ODE
%tspan = (0:14);
%tspan = (0:length(data));
tspan = 0:1:270;
% Calls the ODE solver with the current parameter guess
[t,y] = ode45(@SEIR,tspan,x0,[],p);
figure(1),
plot(cumsum(y(:,2)*k0)),
hold on
plot(cumsum(y(:,3)*g0*0.74),'r')

% Calculates the residuals to be minimized
%data = [3,6,25,73,222,294,258,237,191,125,69,27,11,4];
dataModel =  cumsum(p(3) * y(2:end,2));


I = dataModel - data';

end

function y = SEIR(t,x,p)

N = p(1);
b = p(2);
k = p(3);
g = p(4);


S = x(1);
E = x(2);
I = x(3);
R = x(4);
b = 0.27*exp(-0.0023*(t));

y = [- (b.* S* I /N);
(b .* S * I / N) - (k * E);
(k * E) - (g * I)
(1-0.74)*(g * I)];

end
