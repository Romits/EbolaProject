function worldWide_ode1
Len = 23;
global t0;
t0 = -1*ones(1, Len);
t0(1) = 1;
% Redeclare initial conditions and N
N0 = 1000000;
x0 = [N0-1 0 1 0 1];
%x0 = [N0-500 500 1 0 1];
x01 = [N0 0 0 0 0];
x0 = [x0 repmat(x01,1,Len-1)];

% Set up the parameter vector to be passed
%p = [N p0];

tspan =0:1:394;
% Calls the ODE solver with the current parameter guess
b0 = 0.2; % transmission rate per person per day range 0<b<1
k0 = 1/6.3; % mean incubation period (1/k) is 6.3 days, range 1<(1/k)<21] %5.5
g0 = 1/6.8; % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7

B = b0 * ones(1, Len);
K = k0 * ones(1, Len);
G = g0 * ones(1, Len);
B0 = [0.24 0.36 0.21 b0*ones(1,Len-3)];
B1 = [0.21 0.22 0.0001 0.2*ones(1,Len-3)];
G = [1/5.5 1/6.36 1/10.7 (1/6.3)*ones(1,Len-3)];
Q = [32 34  0.0085 34*ones(1,Len-3)];
T = [110 50 120  30*ones(1,Len-3)];
%N = N0 * ones(1, Len);
N = 1000000*[11.75 6.092 4.294 15.3 20.32 1.7 14.13 143.5 47.27 4.6 8.08 316.1 80.62 28.8 15.7 2.16 1357 66 127 59.83 16.8 10.7 173.6];


[t,y] = ode45(@SEIR,tspan,x0,[],B0, B1, Q, T, K, G, N0, N, Len);
%[t,y] = ode45(@SEIR,tspan,x0,[],p);
%y = SEIR(t,x,B, K, G, N)
% y = SEIR(t,x,p)
a=[],for ii=1:23, a =[a y(end,ii*5)];, end
a
return;
function worldWide_ode1
% guinea - 1
idxC1_1 = [1];
idxC2_1 = [4 5 2 3 6 7 8 9 10 11 12 13];
num_1 = [301   231   225   167   119   102    18    16    12    11    11    10];


% Sierra Leone - 2
idxC1_2 = [2];
idxC2_2 = [1 3 12 14 15 8 16 17 18 13 5 19];
num_2 = [ 417   157    54    22    10    10     9     6     4     4     3     3];

% Liberia - 3
idxC1_3 = [3];
idxC2_3 = [5 1 2 13 12 20 18 21 22 23 9 19];
num_3 = [191   144    73    24    16    12     7     5     4     2     2     1];

%M = [num_1; num_2; num_3];
%Idx = [idxC2_1; idxC2_2; idxC2_3];
Len = 23;
load dataM
createSum('S', 1, Len, M)
b0 = 0.2; % transmission rate per person per day range 0<b<1
k0 = 1/6.3; % mean incubation period (1/k) is 6.3 days, range 1<(1/k)<21] %5.5
g0 = 1/6.8; % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7

b = b0 * ones(1, Len);
k = k0 * ones(1, Len);
g = g0 * ones(1, Len);

return
%% SEIR model for ODE
function y = SEIR(t,x, B0, B1, Q, T, K, G, N0, N, Len)
 
disp(t)
global t0
load dataM;

for counterIdx = 1:Len
    id = (counterIdx-1)*5;
    eval(['S_' num2str(counterIdx) ' = max(0,' num2str(x(id+1)) ');']);
    eval(['E_' num2str(counterIdx) ' = max(0,' num2str(x(id+2)) ');']);
    eval(['I_' num2str(counterIdx) ' = max(0,' num2str(x(id+3)) ');']);
    eval(['R_' num2str(counterIdx) ' = max(0,' num2str(x(id+4)) ');']);
    eval(['C_' num2str(counterIdx) ' = max(0,' num2str(x(id+5)) ');']);
    eval(['N_' num2str(counterIdx) ' = ' num2str(N(counterIdx)) ';']);
    
    eval(['cond1 = (C_'  num2str(counterIdx) '> 1 && t0(' num2str(counterIdx) ')==-1);']);
    if (cond1>0)
        t0(counterIdx) = t;
    end
end

%     S = x(1);
%     E = x(2);
%     I = x(3);
%     R = x(4);
%     C = x(5);
y = [];
for counterIdx = 1:Len
    if t0(counterIdx)==-1
        b = B0(counterIdx);
    else 
        if (t-t0(counterIdx))> T(counterIdx)
            b = B1(counterIdx) + (B0(counterIdx)-B1(counterIdx))*exp(-Q(counterIdx)*(t-t0(counterIdx)-T(counterIdx)));
        else
            b = B0(counterIdx);
        end
    end
    k = K(counterIdx);
    g = G(counterIdx);
   
%    dS = eval(['- b * S_'  num2str(counterIdx) ' * I_' num2str(counterIdx) ' / N_' num2str(counterIdx)]);    
    dS = eval(['- b * S_'  num2str(counterIdx) ' * I_' num2str(counterIdx) ' / N0']);    

    [term1, term2] = createSum('S', counterIdx, Len, M);
    for counter = 1:length(term1)
        dS = dS + eval(term1{counter}) + eval(term2{counter});
    end
    
    %dE =    eval(['(b * S_'  num2str(counterIdx) ' * I_' num2str(counterIdx) ' / N_' num2str(counterIdx) ') - ( k * E_'  num2str(counterIdx) ' )']);
    dE =    eval(['(b * S_'  num2str(counterIdx) ' * I_' num2str(counterIdx) ' / N0 '  ') - ( k * E_'  num2str(counterIdx) ' )']);
    [term1, term2] = createSum('E', counterIdx, Len, M);
    for counter = 1:length(term1)
        dE = dE + eval(term1{counter}) + eval(term2{counter});
    end
    
    dI =  eval(['(k * E_' num2str(counterIdx) ') - (g * I_' num2str(counterIdx) ' ) ']);  
    
    dR = eval(['(g * I_' num2str(counterIdx)  ' )']);
    
    dC = eval(['(k * E_' num2str(counterIdx) ')']);
    ytemp = [dS; dE; dI; dR; dC];
    y = [y ; ytemp];
%     ytemp = [- (b.* S* I /N);           %dS
%             (b .* S * I / N) - (k * E); %dE
%             (k * E) - (g * I);          %dI
%             (g * I);                    %dR
%             (k*E)];                     %dC 

    

end

return