% A function to run the ODE and return the value for I
% index case is december 2 fell ill 
% intervention March 2 2014, tau is 111

function SEIR0_WestAfrcia
    load dataTotal1
    if 1==1
        %for q = [0:0.01:1]
          %  beta1 = [ 0.3500    6.3000    3.9000    0.3000    1.0000];% imin =   0.0523
             beta1 = [  0.2000    6.3000    6.8000         0         0];% imin = 0.0031

            testOnevalue(beta1, dayI, infected, dayD, death );

        %end
        %beta1 = [0.4000   17.5000    9.0000    0.2000    5.0000];
    else
        counter =0;
        d = [];
        i = [];
        beta1 = [0:0.05:1];
        beta2 = [0:0.05:1];
        meanIncubation = 6.3%[1:0.5:10];
        meanRecovered = [3.5:0.1:10.7];
        q1 = [0:0.1:1];%0:1:100;        
        imin = 10000000;
        dmin = 10000000;
        for a = beta1
            for a1 = beta2
                if (a > a1)
                    for q = q1
                        for b = meanIncubation
                            for c = meanRecovered
                                if rem(counter,1000)==0
                                    disp(counter);
                                end
                                counter=counter+1;
                                [t, infected1, death1] = SEIR0Liberia(a,b,c,a1,q);
                                itemp = mean( (infected -  infected1(dayI)).^2 ) /mean( infected.^2 );
                                %mean((infected1(day1(idxI)) - infected(idxI)).^2);
                                dtemp = mean( (death - death1(dayD)).^2) / mean(death.^2);
                                if (imin>itemp)
                                    valI = [a b c a1 q];
                                    imin = itemp;
                                    disp(valI)
                                    disp(imin)

                                end
                                if (dmin>dtemp)
                                    valD = [a b c a1 q];
                                    dmin = dtemp;
                                end
                            end
                        end
                    end
                end
            end
        end
        
        save result1  imin valI dmin valD
        
    end
end

function testOnevalue(beta, dayI, infected, dayD, death)
    hold on
    [t, infected1, death1] = SEIR0Liberia(beta(1),beta(2),beta(3),beta(4),beta(5));
    res = mean( (infected -  infected1(dayI)).^2 )./mean( infected.^2 );
    disp(res);
    plot(t, infected1);
    hold on
    plot(dayI, infected);
    plot(t, 0.65*death1,'r')
    plot(dayD, death,'r')
end

function [t, infected, death] = SEIR0Liberia(a,b,c,d,e) 
b0 = a; % transmission rate per person per day1 range 0<b<1
k0 = 1/b; % mean incubation period (1/k) is 6.3 day1s, range 1<(1/k)<21] %5.5
g0 = 1/c; % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7

p0  = [b0 k0 g0 d e];


% Redeclare initial conditions and N
N = 1000000;
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
