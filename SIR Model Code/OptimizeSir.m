function OptimizeSir

% Population Size
N = 763;

% The data we use to fit
data = [3,6,25,73,222,294,258,237,191,125,69,27,11,4];

% Initial Guesses for  beta and gamma.
b0 = 5;
g0 = 0.1;

% lsqnonlin will return the parameter values for beta and gamma and the norm
% of the residual function
[p,resnorm] = lsqnonlin(@SIR0,[b0 g0],[0 0],[inf inf])

% Define a separate time vector for a more smooth solution to ODE
tspan = (0:.1:14);

% Define the initial conditions for S and I
y0 = [N-1 1];

% Integrate the ODEs with the optimal parameter values
[t,y] = ode45(@SIR,tspan,y0,[],[N p]);

% Time steps over which we will solve the ODE, chosen to match days of data
% collection
t_vals=(1:14);

% Plot the solution of I(t) with the data
figure(1)
plot(t,y(:,2))
hold on;
plot(t_vals,data,'o')
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