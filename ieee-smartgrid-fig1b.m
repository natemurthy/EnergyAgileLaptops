M = csvread('../data/dell-laptop.csv');
N = M(1:10:3320);
x = 1:length(N(:,1));
forest=[.1328 .5430 .1328];
%h = plot(x,N);

% f = @(x) 26.33*exp((-.66e-2)*(x)) + 12.33*exp((-7.217e-3)*(x)) + 30;
% k = @(x) 20*exp(-.15*x)+60;

f =@(x) (20*exp(-.15*x)+40).*(x<17) + (30*exp(-.0101*x)+17).*(x>=17 & x<145) + (26.33*exp((-.66e-2)*(x)) + 12.33*exp((-7.217e-3)*(x)) + 10).*(x>=145);
C_dell = zeros(1,331);
for i=1:332
    C_dell(i+1)=C_dell(i)+f(i);
end
C = 900*C_dell(1:331)/120/12;
max_C = C(331);
C(331:400)=max_C;
diff = N - f(x)';

x_prime = 1:400;
N(333:400)=0;

[ax,h1,h2] = plotyy(x_prime,N,x_prime,C);
set(ax(1),'YTick',0:20:100);
set(ax(2),'YTick',0:1000:7000);

set(h1,'LineWidth',2);
set(h2,'LineWidth',2,'Color','forest');

h3 = line(x,f(x),'Color','black');
h4 = line(x,f(x),'Color','black','LineWidth',2,'LineStyle','--');

h5 = line(x,diff(x),'Color','r');
h6 = line(x,diff(x),'Color','r','LineWidth',2','LineStyle','--');

set(ax(1),'FontSize',15);
set(ax(2),'FontSize',15);
set(ax(2),'YColor','forest');