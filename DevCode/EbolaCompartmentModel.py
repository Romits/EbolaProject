# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

from pyndamics import Simulation
from pyndamics.mcmc import MCMCModel
import pandas as pd

# <codecell>

ebolaDf = pd.DataFrame.from_csv('./country_timeseries.csv',index_col=0)
ebolaDf = ebolaDf.sort_index()
ebolaDf = ebolaDf.fillna(method='bfill')

# <codecell>

#Initialize the values
tau = 110
beta0 = 0.2500
invGamma = 5.5000
beta1 = 0.2000
q = 0.1000
invk = 6.3


# <codecell>

ebolaDf['Cases_Liberia_temp'] = 0

# <codecell>

ebolaDf['Cases_Liberia_temp'][1::] = ebolaDf.Cases_Liberia[:-1:]

# <codecell>

ebolaDf['Uncum_Cases_Liberia'] = ebolaDf.Cases_Liberia - ebolaDf.Cases_Liberia_temp

# <codecell>

numOfDays = ebolaDf['Day'].values
numOfCases = ebolaDf['Uncum_Cases_Liberia'].values

# <codecell>

print numOfDays

# <codecell>

def beta(t):
    if t >= tau:
        return beta1 + (beta0-beta1)**(-q*(t-tau))
    else:
        return beta0
    

# <codecell>

N = 1000000
sim = Simulation()
sim.add("S'=-beta(t)*(S*I)/N", N, plot=False)
sim.add("E'=-beta(t)*(S*I)/N - (E/invk)",135,plot=1)
sim.add("I'=(E/invk) - (1/invGamma *I)",136,plot=1)
sim.add("R'=(1/invGamma*I)",0,plot=False)
sim.params(N=N, k = 1/6.3, q = 0.1000,invGamma = 5.5000,invk=6.3)
sim.functions(beta)
sim.add_data(t=numOfDays, I=numOfCases, plot=1)
sim.run(0,350)

# <codecell>

model = MCMCModel(sim,{'beta0':[0,1], 'invGamma':[3.5,10.7],'beta1':[0,1],'q':[0,100], 'tau':[100,150],'invk':[5,22]})
#model = MCMCModel(sim,{'invGamma':[3.5,10.7],'q':[0,10]})
model.fit(iter=500)
model.plot_distributions()

# <codecell>

Beta0 = model.beta0

# <codecell>

Beta1 = model.beta1

# <codecell>

#beta = (Beta0 + Beta1)/2

# <codecell>

incubationTime = model.invk

# <codecell>

infectionTime = model.invGamma

# <codecell>

Tau = model.tau

# <codecell>

Q = model.q

# <codecell>

ReproductiveRate = Beta0*infectionTime

