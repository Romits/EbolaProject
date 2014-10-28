# Ebola 2014 Project

from pylab import *
from pymc import *
 
# load the model
import SEIRModel as mod
reload(mod)  # this reload streamlines interactive debugging
 
# fit the model with mcmc
mc = MCMC(mod)
mc.use_step_method(AdaptiveMetropolis, [mod.beta, mod.gamma, mod.SEIR_0])
mc.sample(iter=200000, burn=100000, thin=20, verbose=1)
 
 
# plot the estimated size of S and I over time
figure(1)
 
subplots_adjust(hspace=0, right=1)
subplot(2, 1, 1)
title('SEIR model with uncertainty')
plot(mod.susceptible_data, 's', mec='black', color='black', alpha=.9)
plot(mod.S.stats()['mean'], color='red', linewidth=2)
plot(mod.S.stats()['95% HPD interval'], color='red',
     linewidth=1, linestyle='dotted')
yticks([950,975,1000,1025])
ylabel('S (people)')
axis([-1,10,925,1050])
 
subplot(2, 1, 2)
plot(mod.infected_data, 's', mec='black', color='black', alpha=.9)
plot(mod.I.stats()['mean'], color='blue', linewidth=2)
plot(mod.I.stats()['95% HPD interval'], color='blue',
     linewidth=1, linestyle='dotted')
xticks(range(1,10,2))
xlabel('Time (days)')
yticks([0,15,30])
ylabel('I (people)')
axis([-1,10,-1,35])
savefig('SEIR.png')
 
# plot the joint distribution of the epidemic parameters
figure(2)
title('Joint Distribution of Epidemic Parameters')
plot([mod.beta.random() for i in range(1000)],
     [mod.gamma.random() for i in range(1000)],
     linestyle='none', marker='o', color='blue', mec='blue',
     alpha=.5, label='Prior', zorder=-100)
plot(mod.beta.trace(), mod.gamma.trace(),
     linestyle='none', marker='o', color='green', mec='green',
     alpha=.5, label='Posterior', zorder=-99)
 
import scipy.stats
gkde = scipy.stats.gaussian_kde([mod.beta.trace(), mod.gamma.trace()])
x,y = mgrid[0:40:.05, 0:1.1:.05]
z = array(gkde.evaluate([x.flatten(),y.flatten()])).reshape(x.shape)
contour(x, y, z, linewidths=1, alpha=.5, cmap=cm.Greys)
 
ylabel(r'$\gamma$', fontsize=18, rotation=0)
xlabel(r'$\beta$', fontsize=18)
legend()
axis([-1, 41, -.05, 1.05])
savefig('param_dist.png')
 
 
# plot the autocorrelation of the MCMC trace for each var as evidence of mixing
figure(3)
 
def my_corr(tr, with_dots=False):
    acorr(tr, detrend=mlab.detrend_mean, usevlines=True)
    if with_dots:
        acorr(tr, detrend=mlab.detrend_mean, usevlines=False)
    xticks([])
    yticks([])
    axis([-11, 11,-.1, 1.1])
 
axes([.05, .5, .475, .5])
my_corr(mod.beta.trace(), with_dots=True)
yticks([0,.5,1.])
text(-10, .9, r'$\beta$')
 
axes([.525, .5, .475, .5])
my_corr(mod.gamma.trace(), with_dots=True)
text(-10, .9, r'$\gamma$')
 
for i in range(10):
    axes([.05 + i*.095, .25, .095, .25])
    my_corr(mod.S.trace()[:,i])
    text(-10, .9, '$S_%d$'%i)
    if i == 0:
        yticks([0,.5,1.])
    axes([.05 + i*.095, 0., .095, .25])
    my_corr(mod.I.trace()[:,i])
    text(-10, .9, '$I_%d$'%i)
    if i == 0:
        yticks([0,.5,1.])
savefig('acorr.png')
