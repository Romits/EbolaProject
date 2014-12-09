
deltaT = 0.01;
time = [1:deltaT:250];

S = [10000000];
N = S;

E = [0];
I = [1];
R = [0];
beta0 = 0.357;
beta1 = 0.2012;
q = 32;
k = 1/6.3;
gamma = 1/6.36;
tau = 50;

for counter = 1:length(time)
    St = S(end);
    Et = E(end);
    It = I(end);
    Rt = R(end);
    
    if time(counter) < tau
        beta = beta0;
    else
        beta = beta1 + (beta0-beta1)*exp(-q * (time(counter)-tau));
    end
    
    Stp1 = St - (beta * St * It /N )*deltaT;
    Etp1 = Et + ((beta * St * It /N) - (k * Et))*deltaT;
    Itp1 = It + ((k * Et) - (gamma * It))*deltaT;
    Rtp1 = Rt + (gamma * It)*deltaT;
    
    S = [S Stp1];
    E = [E Etp1];
    I = [I Itp1];
    R = [R Rtp1];
end


plot(time, E(1:end-1));
hold on
plot(time,I(1:end-1),'g');
plot(time,R(1:end-1),'r');
hold on
plot(time,cumsum(k*E(1:end-1)*deltaT),'k');
