Npop = 1000000;
A    = 100;
minday = 0;
maxday = 30*24;

vkappa = 1:1:21;%seq(1,21,2)
vgamma = 1:1:21;%seq(1,21,2)
vbeta  = 10:2:20;%seq(10,20,2)
wkappa = [];%numeric(0)
wgamma = [];%numeric(0)
wbeta  = [];%numeric(0)
wlike  = [];%numeric(0)

observed = [0
0
0
8678
34046
65182
19637
49781
20087
4081
123
1
0
0
0
2273
10204
39867
34534
22622
22867
4427
258
7]';

predicted=[0
0
0
5557
23774
37134
40008
32618
17763
2926
147
7
0
0
0
2882
17440
29894
33846
28951
17307
3821
203
10]';
predicted(predicted<=0) = 1e-3;
poisson_neg_log_like_true = sum(predicted - observed.*log(predicted));

minlike = 1e9;
for kappa_try = vkappa
  for gamma_try = vkappa
    for beta_try  = vkappa
      kappa = 1/kappa_try;
      gamma = 1/gamma_try;
      [vtime, vpred, vobs, y] = generate_epidemic(minday,maxday,Npop,kappa,gamma,beta_try,A,0);
      %vpred = myepidemic$vpred
      vpred(vpred<=0) = 1e-3;
      poisson_neg_log_like = sum(vpred-observed.*log(vpred))-poisson_neg_log_like_true;
      %if (!is.na(poisson_neg_log_like)){
        wkappa = [wkappa kappa_try];
        wgamma = [wgamma,gamma_try];
        wbeta  = [wbeta beta_try];
        wlike  = [wlike poisson_neg_log_like];
        
        if (poisson_neg_log_like<minlike)
          minlike = poisson_neg_log_like;
          vpred_best = vpred;
          disp(vpred);
        end
        
        %if (length(wkappa)%%1==0){
%           cat(length(wkappa),length(vkappa)*length(vgamma)*length(vbeta),"\n")
%           mult.fig(4)
%           plot(wdat$observed,ylim=c(0,1.1*max(max(wdat$observed),max(vpred_best))),xlab="Time, in months",ylab="\043 human cases per month")
%           lines(vpred_best,lwd=5,col=2)
%           lines(wdat$predicted,lwd=5,col=3)
%           points(wdat$observed)
%           lgood = wlike<=(min(wlike)+100000)
%           lgood = T
%           plot(wkappa[lgood],wlike[lgood],xlab="Hypothesized value of 1/kappa",ylab="Poisson neg log likelihood")
%           plot(wgamma[lgood],wlike[lgood],xlab="Hypothesized value of 1/gamma",ylab="Poisson neg log likelihood")
%           plot(wbeta[lgood],wlike[lgood],xlab="Hypothesized value of beta",ylab="Poisson neg log likelihood")
        %}
      %}
        end
        end
  end
figure
