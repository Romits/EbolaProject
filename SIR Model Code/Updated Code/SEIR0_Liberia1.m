% A function to run the ODE and return the value for I
% intervention day Aug 4
% day 0 is March 31
% On March 31, 2014 Liberia confirmed its first two cases of Ebola virus
% disease, one died, one infected
% therefore, tau is around 110


function SEIR0_Liberia()
load dataLiberia % load data
% remove first 3 days from daya
dayI(1:3) = [];
dayD(1:3) = [];
infected(1:3) = []; 
death(1:3) = [];

dayI = dayI - 9 + 1;
dayD = dayD - 9 + 1;
dayD = [dayD' 227 230]';     
death = [death' 2766 2836]';
dayI = [dayI' 209 215 221 225]';
infected = [infected' 6525 6535 6619 6822]';
normalizingConstant = mean( infected.^2 );
tau = 120;
N = 1000000;
kOptim = 6.3;   
lowerBound = [0.01 3.5  0.0001   0.00001];
upperBound = [1 10.7 1   100];

isTestValue = 1;
isOptimization = 0;
isCalculateCI = 0;

if (isOptimization)
    param0 = [0.1701  10.7000    0.1301    0.1000];
%    param0 = [0.3  8    .3    0.5];
    param0 = [ 0.1901     9.0000    0.0071    0.0085];
    % lsqnonlin will return the parameter values for beta and gamma and the norm
    % of the residual function
    options = optimset('MaxFunEvals',4000);
    performCrossValidation(param0,lowerBound,upperBound,options, kOptim, N, tau, infected, dayI, tau);

    [paramEst,resnorm] = lsqnonlin(@SEIR1,param0,lowerBound,upperBound,options, kOptim, N, tau, infected, dayI);
     disp(paramEst)
end

if (isCalculateCI)
    nboot = 1000;
    [t, iPred, dPred] = SEIR0Liberia(paramEst(1), kOptim, paramEst(2),paramEst(3),paramEst(4),N, tau);    
    residuals = infected - iPred(dayI);
    [betaHat, bootCI] = performBootstrapCI(residuals, nboot,iPred(dayI),paramEst,param0, N, tau, kOptim, lowerBound, upperBound,dayI);
    disp('bootstrap CI: ');
    disp([betaHat' bootCI']);
    save resultCI1 betaHat bootCI
    
    
end



if (isTestValue);
    beta1 = [ 0.3000   16.0000    8.0000         0    0.0100];
    beta1 = [0.2600    6.0000    6.0000    0.1500    0.0100];
    beta1 = [    0.2000    6.3000    9.0000    0.1500    0.6000];
    beta1 = [0.2050    6.3000    8.6000    0.1500    0.1000];
    betaOptim = [0.206    6.3000    8.98    0.15    0.46];  
    betaOptim = [0.1980   6.3000  8.3703    0.1588   22.2617];
    %betaOptim = [paramEst(1) 6.3 paramEst(2:end)];
    betaOptim = [0.169 6.3 10.7 0.0001 0.0085];
    betaOptim =[ 0.1697 6.3  10.5083    0.0001    0.0068];

   % load resultLiberiaLatinSquare %estimateMin
   %betaOptim = [0.206 6.3 8.98 0.15 0.46 ]
    figure, 
    testOnevalue(betaOptim, dayI, infected, dayD, death, N, tau);
   % figure, testOnevalue(estimateMin, dayI, infected, dayD, death, N, tau);

else

    beta0Range = [0.0001:0.001:0.2];
    beta1Range = [0.0001:0.001:0.2];
     
    gammaRange = [3:1:10.7 10.7];    
    qRange = [0.0085];%[ 0.1 0.5  10];%qRange = [0.001:0.1:2 3:7:100];
    
    %load resultLiberiaLatinSquare
    %plotParameterRange(resMatrix, beta0Range, beta1Range,  gammaRange, qRange);
    
    resMatrix = 1000000*ones(length(beta0Range), length(beta1Range), length(gammaRange), length(qRange));
    resVector = [];
    resMin = 1000000;
    
    for cQ = 1:length(qRange)
        qCurrent = qRange(cQ);
        for cG = 1:length(gammaRange)
            gammaCurrent = gammaRange(cG);
            for cB1 = 1:length(beta1Range)
                beta1Current = beta1Range(cB1);
                for cB0 = 1:length(beta0Range)
                    beta0Current = beta0Range(cB0);
                    
                    if (beta0Current>= beta1Current)
                        [t, iPred, dPred] = SEIR0Liberia(beta0Current,kOptim,gammaCurrent,beta1Current,qCurrent,N, tau);
                        
                        resCurrent = mean( (infected - iPred(dayI)).^2 ) / normalizingConstant;
                        resMatrix(cB0, cB1, cG, cQ) = resCurrent;
                        resVector = [resVector resCurrent];
                        
                        if (resMin>resCurrent)
                            resMin = resCurrent;
                            disp(resMin);
                            estimateMin = [beta0Current kOptim gammaCurrent beta1Current qCurrent];
                            disp(estimateMin);
                        end

                    end

                    
                end % cB0
            end % cB1
        end % cG
    end % cQ

    save resultLiberiaLatinSquare_2  resMatrix resVector resMin estimateMin

end
return

function performCrossValidation(param0,lowerBound,upperBound,options, kOptim, N, tau, infected, dayI, dayIdx)
    idx = find(dayI>=dayIdx,1);
    e = [];
 
    while (idx+1<=length(dayI))
        infected1 = infected(1:idx);
        dayI1 = dayI(1:idx);
        infected2 = infected(idx+1);
        dayI2 = dayI(idx+1);
        [par,resnorm] = lsqnonlin(@SEIR1,param0,lowerBound,upperBound,options, kOptim, N, tau, infected1, dayI1);
        [t, iPred, dPred] = SEIR0Liberia(par(1),kOptim, par(2),par(3),par(4),N, tau);
        e = [e iPred(t==dayI2) - infected2];
        idx = idx+1;
    end
    e
 
    
return

function [betaHat, bootCI] = performBootstrapCI(residuals,nboot,I,paramEst,param0,N, tau,kOptim, lowerBound, upperBound,dayI)                   
% resample the residuals using bootstrp fuction
betaHat = paramEst;
[~, bootIndices] = bootstrp(nboot,[],residuals);
bootResiduals = residuals(bootIndices);
% generate bootstrap datasets by adding the resampled residuals to the best
% fit curve
yFit = I;
yBoot = repmat(yFit, 1, nboot) + bootResiduals;

% Estimate the modelparameters again, by using the bootstrap data set as
% observed dataset, for each of the nboot sets
% store the estimates
betaBoot = zeros(nboot,length(betaHat));

for i = 1:nboot
    betaBoot(i,:) = lsqnonlin(@SEIR1,param0,lowerBound,upperBound,[], kOptim, N, tau, yBoot(:,i), dayI);
    %nlinfit(dose, yBoot(:,i), @Hill, betaGuess);%, options);
    disp(betaBoot(i,:));
end

bootCI = prctile(betaBoot, [2.5 97.5]);

return

function plotParameterRange(resMatrix, beta0Range, beta1Range,  gammaRange, qRange)

resBeta0 = [];
for cB0 = 1:length(beta0Range)
    tempMatrix = resMatrix(cB0, :, :, :);
    resBeta0 = [resBeta0 min(tempMatrix(:))]    
end

resBeta1 = [];
for cB1 = 1:length(beta1Range)
    tempMatrix = resMatrix(:, cB1, :, :);
    resBeta1 = [resBeta1 min(tempMatrix(:))]    
end

resGamma = [];
for cG = 1:length(gammaRange)
    tempMatrix = resMatrix(:, :, cG, :);
    resGamma = [resGamma min(tempMatrix(:))]    
end

resQ= [];
for cQ = 1:length(qRange)
    tempMatrix = resMatrix(:, :, :, cQ);
    resQ = [resQ min(tempMatrix(:))]    
end

subplot(2,2,1), plot(beta0Range, resBeta0,'ro');
subplot(2,2,2), plot(beta1Range, resBeta1,'ro');
subplot(2,2,3), plot(gammaRange, resGamma,'ro');
subplot(2,2,4), plot(qRange, resQ,'ro');

return
function testOnevalue(par, dayI, infected, dayD, death, N, tau)
    [t, iPred, dPred] = SEIR0Liberia(par(1),par(2),par(3),par(4),par(5),N, tau);

    res = mean( (infected - iPred(dayI)).^2 ) /mean( infected.^2 );
    disp(res);
    %calcMortalityRate(dayD, dPred, death)
    
    plot(t, iPred,'c','LineWidth',1.5);
    hold on
    plot(dayI-1, infected,'ko');
    
        
    alpha1 = [0:0.001:1];
    val = [];
    for alpha= alpha1
        val =[val mean( (death - alpha*dPred(dayD)).^2) ./ mean(death.^2)];
    end
    [~,id]=min(val);
    disp(alpha1(id))
    
    plot(t, alpha1(id)*dPred,'r')
    plot(dayD-1, death,'ro')
return

function calcMortalityRate(dayD, dPred, death)
    alpha = [0:0.001:1];
    res = [];
    for a = alpha
        res = [res mean( (death - a* dPred(dayD)).^2 ) /mean( death.^2 )];
    end
    plot (alpha, res)
    [~, ind] = min(res);
    disp(alpha(ind));
    
return

%% SEIR model wrapper for lsqnonlin
function OP = SEIR1(par, kOptim, N, tau, infected, dayI)
[t, iPred, dPred] = SEIR0Liberia(par(1),kOptim, par(2),par(3),par(4),N, tau);
OP = infected - iPred(dayI);
res = mean( (infected - iPred(dayI)).^2 ) /mean( infected.^2 );
disp(res);
return

function OP = SEIR1(par, kOptim, N, tau, infected, dayI)
[t, iPred, dPred] = SEIR0Liberia(par(1),kOptim, par(2),par(3),par(4),N, tau);
OP = infected - iPred(dayI);
res = mean( (infected - iPred(dayI)).^2 ) /mean( infected.^2 );
disp(res);
return


%% SEIR model for lsqnonlin
function [t, infected, death] = SEIR0Liberia(a,b,c,d,e,N, tau) 
b0 = a; % transmission rate per person per day1 range 0<b<1
k0 = 1/b; % mean incubation period (1/k) is 6.3 day1s, range 1<(1/k)<21] %5.5
g0 = 1/c; % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7

p0  = [b0 k0 g0 d e];


% Redeclare initial conditions and N
x0 = [N-2 0 2 0 2]; % S E I R C

% Set up the parameter vector to be passed
p = [N p0];

tspan =0:1:275;
% Calls the ODE solver with the current parameter guess
[t,y] = ode45(@SEIR,tspan,x0,[],p,tau);
infected = y(:,5);
%infectedC = cumsum(y(:,2)*k0);
death = cumsum(y(:,3)*g0);
% plot(t,y(:,2),'g')
% hold on
% plot(t,y(:,3),'b')
% plot(t,y(:,4),'k')


return

%% SEIR model for ODE
function y = SEIR(t,x,p,tau)

N = p(1);
b0 = p(2);
k = p(3);
g = p(4);
b1 = p(5);
q = p(6);

S = x(1);
E = x(2);
I = x(3);
R = x(4);
C = x(5);

if t<tau
    b = b0;
else
    b = b1 + (b0-b1)*exp(-q*(t-tau));
end

y = [- (b.* S* I /N); %dS
(b .* S * I / N) - (k * E); %dE
(k * E) - (g * I); %dI
(g * I); %dR
(k*E)]; %dC 

return