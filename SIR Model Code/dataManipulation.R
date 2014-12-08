data =  read.csv("country_timeseries.csv")

dataT = data.frame(data$Day, data$Date, data$Cases_Liberia+data$Cases_Guinea+data$Cases_SierraLeone, data$Deaths_Guinea+data$Deaths_Liberia+data$Deaths_SierraLeone)
names(dataT) = c("day", "date", "infected", "death")
dataT$date = as.Date(dataT$date, format="%m/%d/%Y")
dataT = dataT[order(dataT$date),]

library(R.matlab)
writeMat("dataTotal.mat", day=dataT$day, death = dataT$death, infected = dataT$infected, date = dataT$date)




datLib = datLib[order(datLib$day),]


datLib = data.frame(data$Day, data$Deaths_Liberia, data$Cases_Liberia)
names(datLib) = c("day", "death", "infected")
#datLib$date = as.Date(datLib$date, format="%m/%d/%Y")
datLib = datLib[order(datLib$day),]
library(R.matlab)
writeMat("dataLiberia1.mat", day=datLib$day, death = datLib$death, infected = datLib$infected)
#plot(datLib[complete.cases(datLib$death),c(1,2)])
#plot(datLib[complete.cases(datLib$death),c(1,3)])

library(zoo)
times.init <-datLib$date
#data2 <-zoo(datLib$death,times.init)
data2 <-zoo(datLib[,c(2,3)],times.init)
data3 <-merge(data2, zoo(, seq(min(times.init), max(times.init), "d")))
data4 <-na.approx(data3)

writeMat("dataLiberia1.mat", date=datLib$date, death = data4$death, infected = data4$infected)






data =  read.csv("country_timeseries.csv")

datLib = data.frame(data$Day, data$Deaths_Liberia, data$Cases_Liberia)
names(datLib) = c("day", "death", "infected")
#datLib$date = as.Date(datLib$date, format="%m/%d/%Y")
datLib = datLib[order(datLib$day),]
library(R.matlab)
writeMat("dataLiberia1.mat", day=datLib$day, death = datLib$death, infected = datLib$infected)
#plot(datLib[complete.cases(datLib$death),c(1,2)])

