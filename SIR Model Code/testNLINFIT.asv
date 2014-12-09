function testNLINFIT
x=[0 0 1 1 2 2 3 3 4 4 5 5];
y=[2.86 2.64 1.57 1.24 .45 1.02 .65 .18 .15 .01 .01 .36];
beta0 =[0 2 .5];
[beta,res1,J,CovB,MSE] = nlinfit(x, y, @nlin_func, beta0);%,lowerBound,upperBound,options, infected, dayI);
ci1 = nlparci(beta,res1,'covar',CovB);
ci2 = nlparci(beta,res1,'jacobian',J);

beta



end

function yhat = nlin_func(beta,x)
    yhat = beta(1) + beta(2) * exp(-beta(3)*x);
end