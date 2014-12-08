load dataGuinea1
%load dataLiberia1
iid = 1;
iid1 = find(day==151);
idx  = double(day(iid:iid1))
infected = double(infected(iid:iid1))
death = double(death(iid:iid1))


idx1 = idx(infected>0)
infected = infected(infected>0)
idx1 = idx1+112;

idx2 = idx(death>0)
death = death(death>0)
idx2 = idx2+112;

figure(2)
plot(idx1,infected)
hold on
plot(idx2,death,'r')