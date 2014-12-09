for counter=1:1

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
t = [0];
while(t(end)<200)
    time = t(end);
    St = S(end);
    Et = E(end);
    It = I(end);
    Rt = R(end);
    
    if time < tau
        beta = beta0;
    else
        beta = beta1 + (beta0-beta1)*exp(-q * (time-tau));
    end
    
    rate1 = beta*St*It/N;
    rate2 = k*Et;
    rate3 = gamma*It;
    rateT = rate1+rate2+rate3;
    deltaT = min(1/rateT,1);
    
    y = rand;
    Stp1 = St;
    Etp1 = Et;
    Itp1 = It;
    Rtp1 = Rt;
    
    if (y<=rate1*deltaT)
        if (Stp1>0)
            Stp1 = St-1;
            Etp1 = Et+1;
        end                
    elseif (y<=(rate1+rate2)*deltaT)
        if (Etp1>0)
            Etp1 = Et-1;
            Itp1 = It+1;
        end
    elseif (y<=(rate1+rate2+rate3)*deltaT)
        if (Itp1>0)
            Itp1 = It-1;
            Rtp1 = Rt+1;
        end
    end
    
    tp1 = time+deltaT;
    t = [t tp1];
    S = [S Stp1];
    E = [E Etp1];
    I = [I Itp1];
    R = [R Rtp1];
    disp(tp1)
end
disp(max(t))

    plot(t, E);
    hold on
    plot(t,I,'g');
    plot(t,R,'r');
    hold on


end



