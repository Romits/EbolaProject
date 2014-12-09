function OptimizeSir
lowerBound = [0 3.5  0   0];
upperBound = [1 10.7 1   5];

infectedData = [          12
          12
          12
          12
          13
          13
          13
          13
          13
          33
          41
          51
         107
         115
         131
         142
         172
         174
         196
         224
         249
         329
         391
         468
         516
         554
         599
         670
         786
         834
         972
        1082
        1378
        1698
        1871
        2081
        2407
        2710
        3022
        3280
        3458
        3696
        3834
        3924
        4076
        4249
        4262
        4665];
    
    day = [    49
    51
    62
    66
    67
    71
    73
    75
    80
    86
    89
    92
   100
   102
   106
   108
   112
   114
   117
   120
   123
   126
   129
   132
   135
   137
   140
   142
   144
   147
   149
   151
   157
   162
   167
   169
   171
   176
   179
   183
   185
   190
   193
   196
   199
   203
   205
   210];

%param0 = [ 0.3000   13.5000    7.5000    0.2000   10.0000];
param0 = [0.4106    3.9068    3.5918    0.3307    6.0960   50.7888];% [ 0   13.5000    7.5000    0.2000   10.0000];
param0 = [ 0.2050     8.6000    0.1500    0.1000];
param0 = [ 0.2050     8.6000    0.1500    0.1000];
param0 = [ 0.4050     8.6000    0.200    0.8000];

% lsqnonlin will return the parameter values for beta and gamma and the norm
% of the residual function
options = optimset('MaxFunEvals',4000);
[p,resnorm] = lsqnonlin(@SEIR1,param0,lowerBound,upperBound,options);
p
resnorm
testOnevalue(p, day, infectedData);
% % Define a separate time vector for a more smooth solution to ODE
% tspan = (0:.1:14);
% 
% % Define the initial conditions for S and I
% y0 = [N-1 1 0];
% 
% % Integrate the ODEs with the optimal parameter values
% [t,y] = ode45(@SIR,tspan,y0,[],[N p]);
% 
% % Time steps over which we will solve the ODE, chosen to match days of data
% % collection
% t_vals=(1:14);
% 
% % Plot the solution of I(t) with the data
% figure(1)
% plot(t,y(:,2))
% hold on;
% plot(t_vals,data,'o')
% hold off;
% 
% R0 = p(1)/p(2)

end
function res = SEIR1(input) 
b0 = input(1); % transmission rate per person per day range 0<b<1
k0 = 1/6.3; % mean incubation period (1/k) is 6.3 days, range 1<(1/k)<21] %5.5
g0 = 1/input(2); % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7
b1 = input(3);
q = input(4);
p0  = [b0 g0 b1 q];


% Redeclare initial conditions and N
N = 4000000;
x0 = [N-2 0 1 1];

% Set up the parameter vector to be passed
p = [N p0];

tspan =0:1:210;
% Calls the ODE solver with the current parameter guess
[t,y] = ode45(@SEIR,tspan,x0,[],p);
I = cumsum(y(:,2)*k0);
infectedData = [          12
          12
          12
          12
          13
          13
          13
          13
          13
          33
          41
          51
         107
         115
         131
         142
         172
         174
         196
         224
         249
         329
         391
         468
         516
         554
         599
         670
         786
         834
         972
        1082
        1378
        1698
        1871
        2081
        2407
        2710
        3022
        3280
        3458
        3696
        3834
        3924
        4076
        4249
        4262
        4665];
    
    day = [    49
    51
    62
    66
    67
    71
    73
    75
    80
    86
    89
    92
   100
   102
   106
   108
   112
   114
   117
   120
   123
   126
   129
   132
   135
   137
   140
   142
   144
   147
   149
   151
   157
   162
   167
   169
   171
   176
   179
   183
   185
   190
   193
   196
   199
   203
   205
   210];

val = mean( (infectedData - I(day)).^2) ./ mean(infectedData.^2);
if val<0.0053
    'hello'
end
disp(p0);
disp(val)

res = (infectedData - I(day));
end


function I = SEIR0(input) 
b0 = input(1); % transmission rate per person per day range 0<b<1
k0 = 1/6.3;%input(2); % mean incubation period (1/k) is 6.3 days, range 1<(1/k)<21] %5.5
g0 = 1/input(2); % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7
b1 = input(3);
q = input(4);
%tau = input(6);
p0  = [b0 g0 b1 q];% tau];


% Redeclare initial conditions and N
N = 4000000;
x0 = [N-2 0 1 1];

% Set up the parameter vector to be passed
p = [N p0];

tspan =0:1:210;
% Calls the ODE solver with the current parameter guess
[t,y] = ode45(@SEIR,tspan,x0,[],p);
infected = cumsum(y(:,2)*k0);
death = cumsum(y(:,3)*g0);

infectedData = [          12
          12
          12
          12
          13
          13
          13
          13
          13
          33
          41
          51
         107
         115
         131
         142
         172
         174
         196
         224
         249
         329
         391
         468
         516
         554
         599
         670
         786
         834
         972
        1082
        1378
        1698
        1871
        2081
        2407
        2710
        3022
        3280
        3458
        3696
        3834
        3924
        4076
        4249
        4262
        4665];
    
    day = [    49
    51
    62
    66
    67
    71
    73
    75
    80
    86
    89
    92
   100
   102
   106
   108
   112
   114
   117
   120
   123
   126
   129
   132
   135
   137
   140
   142
   144
   147
   149
   151
   157
   162
   167
   169
   171
   176
   179
   183
   185
   190
   193
   196
   199
   203
   205
   210];

    I = [infected(day) - infectedData];
end


% The function containing the ODEs
function y = SEIR(t,x,p)

N = p(1);
b0 = p(2);
%k = p(3);
k = 1/6.3;
g = p(3);
b1 = p(4);
q = p(5);
%tau = 110;
%tau = p(7);
tau = 50;
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

