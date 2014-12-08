function test
[t,y] = ode45(@program5, [0 50], [0.1, 0.6])
help 

end
function yp = program5(t,y)
%
alpha = 0.3;
beta = 0.4;
xx = y(1);
yy = y(2);
yp1 = -beta*xx*yy + xx;
yp2 = beta*xx*yy - alpha*yy; yp=[yp1; yp2];
end