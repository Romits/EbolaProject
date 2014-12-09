function [vtime, vpredb, vobs, y] = generate_epidemic(minday, maxday, Npop, kappa, gamma, beta, A, lsmear)
  
  delta_t = 0.1;
  vt = minday:delta_t:maxday;%seq(minday,maxday,delta_t) # vector of times
  E_0 = 0;
  I_0 = 0;
  R_0 = 0;
  S_0 = Npop-E_0-I_0-R_0;
  
  vparameters = [kappa gamma beta A];
  %vparameters = list(kappa=kappa,gamma=gamma,beta=beta,A=A)
 
  inits = [S_0 E_0 I_0 R_0];
  %inits = c(S_h=S_0,E_h=E_0,I_h=I_0,R_h=R_0)
  %epidemic_model_solution = as.data.frame(lsoda(inits, vt, disease_model_func, vparameters))
  [t,y] = ode45(@disease_model_func,vt,inits,[],vparameters);

  v = delta_t*kappa*y(:,2);%v = delta_t*kappa*epidemic_model_solution$E_h
  
  vpred  =[];
  for day = 1:30/delta_t:length(v)
      firstday = day;
      lastday = firstday+30/delta_t-1;

      if lastday<=length(v)
        vpred = [vpred sum(v(firstday:lastday))];
      end
  end
  
  %vsum = sum(v(1:30/delta_t)); %vsum = running(v,width=30/delta_t,fun=sum) # sum within month
  %vpred = vsum( rem(1:length(vt), (30/delta_t)) == 1 );%vpred = vsum[seq(1,length(vt))%%(30/delta_t)==1]
  %vpred = vpred( 1:round(maxday/30) );%vpred = vpred[1:as.integer(maxday/30)]
  vpredb = vpred;
  vpred( vpred==0 ) = 0.1;

  vtime = vt( rem(1:length(vt),30/delta_t)==1 ); %  vt[seq(1,length(vt))%%(30/delta_t)==1]
  vtime = vtime( 1:round(maxday/30) );%vtime[1:as.integer(maxday/30)]

  if (lsmear)
    %set.seed(52341)
    vobs = zeros(0,1,length(vpred));%rep(0,length(vpred))
    for i = 1:length(vpred)
        vobs(i) = my_rnbinom(1,vpred(i),0.10);%my_rnbinom(1,vpred[i],0.10)
    end
  else
      vobs = vpredb;
  end
  
end
    
    
function dy = disease_model_func(t, x, vparameters)
    kappa = vparameters(1);
    gamma = vparameters(2);
    beta = vparameters(3);
    A = vparameters(4);

    S_h = x(1);
    E_h = x(2);
    I_h = x(3);
    R_h = x(4);

    I_h(I_h<0) = 0;
    % with(as.list(vparameters),{
    N_h = S_h+E_h+I_h+R_h;
    M_I = A*cos(2*pi*t/365+pi);
    M_I(M_I<0) = 0;

    dS_h = -beta*M_I*S_h/N_h;
    dE_h = +beta*M_I*S_h/N_h - kappa*E_h;
    dI_h = kappa*E_h - gamma*I_h;
    dR_h = +gamma*I_h ;

    dy = [dS_h;dE_h;dI_h;dR_h];
end


function x = my_rnbinom(n,mu,alpha)
   size = 1/alpha;
   prob = size/(mu+size);
   x = nbinrnd(size, prob ,1,size);
   %return(rnbinom(n,size=size,prob=prob))
end
