library(chron)
adat = read.table("midwest_influenza_2007_to_2008.dat",header=T,sep=",")
cat("The data file contains: ",names(adat),"\n")
adat=subset(adat,week>=47)  # make sure we are far enough into the season that there is at least one case per week

##################################################################################
# The CDC data is weekly, with the date of each point corresponding to the
# date of the end of the week over which the data were collected.
# Let's convert these dates to time in days, relative to Jan 1, 2007
# We will be using this vector of dates, vday, to obtain the model estimates
# of the incidence at that time.
##################################################################################
adat$julian_day = julian(1,6,2007)+(adat$week-1)*7-julian(1,1,2007)
vday = append(min(adat$julian_day)-7,adat$julian_day)

npop = 52000000 # this is approximately the population of IL IN MI MN OH WI (CDC region 5)
I_0 = 1      # put one infected person in the population
S_0 = npop-I_0
R_0 = 0      # initially no one has recovered yet

gamma = 1/3  # recovery period of influenza in days^{-1}
#R0 = 1.24    # the R0 hypothesis
#t0 = 233     # the time-of-introduction hypothesis, measured in days from Jan 1, 2007
R0 = 1.35    # the R0 hypothesis
t0 = 310     # the time-of-introduction hypothesis, measured in days from Jan 1, 2007

vt = seq(t0,550,1)  # let's determine the values of S,I and R at times in vt
beta  = R0*gamma

vparameters = c(gamma=gamma,beta=beta)
inits = c(S=S_0,I=I_0,R=R_0)

sirmodel = as.data.frame(lsoda(inits, vt, SIRfunc, vparameters)) # this numerically solves the SIR model

susceptible = sirmodel$S[sirmodel$time%in%vday]  
incidence = -diff(susceptible)

SIRfunc=function(t, x, vparameters){
  S = x[1]  # the value of S at time t
  I = x[2]  # the value of I at time t
  R = x[3]  # the value of R at time t
  if (I<0) I=0 # this is a cross check to ensure that we always have sensical values of I
  
  with(as.list(vparameters),{
    npop = S+I+R   # the population size is always S+I+R because there are no births or deaths in the model
    dS = -beta*S*I/npop            # the derivative of S wrt time
    dI = +beta*S*I/npop - gamma*I  # the derivative of I wrt time
    dR = +gamma*I                  # the derivative of R wrt time
    out = c(dS,dI,dR)
    list(out)
  })
}

