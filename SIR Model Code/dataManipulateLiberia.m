load dataLiberia1
iid = 1;
iid1 = length(day);

day  = double(day(iid:iid1));
infected = double(infected(iid:iid1));
death = double(death(iid:iid1));
infected(infected<0) = NaN;
death(death<0) = NaN;

idxI = find(~isnan(infected));
idxD = find(~isnan(death));

save finalDatLib idxI idxD death infected day
% plot(day(idxI), sort(infected(idxI)))
% hold on
% plot(day(idxD), sort(death(idxD)),'r')
