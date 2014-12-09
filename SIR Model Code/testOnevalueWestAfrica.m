function testOnevalueWestAfrica(beta, day, infected, dayDead, deadData)
    figure
    [t, infected1, death1] = SEIR0Liberia(beta(1), 6.3, beta(2),beta(3),beta(4));
    plot(t, infected1);
    hold on
    plot(day, infected);
    
    alpha1 = [0:0.001:1];
    val = [];
    for alpha= alpha1
        val =[val mean( (deadData - alpha*death1(dayDead)).^2) ./ mean(deadData.^2)];
    end
    [~,id]=min(val);
    disp(alpha1(id))
    plot(t,  alpha1(id)*death1, 'r');
    plot(dayDead, deadData,'r');
  %  plot(day, death,'r')
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

tspan =0:1:350;
% Calls the ODE solver with the current parameter guess
[t,y] = ode45(@SEIR,tspan,x0,[],p);
infected = cumsum(y(:,2)*k0);
death = cumsum(y(:,3)*g0);


end



function y = SEIR(t,x,p)

N = p(1);
b0 = p(2);
k = p(3);
g = p(4);
b1 = p(5);
q = p(6);
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

