M = csvread('data/dell-laptop.csv');
N = M(1:10:3320);
x = 1:length(N(:,1));
h = plot(x,N);

% f = @(x) 26.33*exp((-.66e-2)*(x)) + 12.33*exp((-7.217e-3)*(x)) + 30;
% k = @(x) 20*exp(-.15*x)+60;

f =@(x) (20*exp(-.15*x)+40).*(x<17) + (30*exp(-.0101*x)+17).*(x>=17 & x<145) + (26.33*exp((-.66e-2)*(x)) + 12.33*exp((-7.217e-3)*(x)) + 10).*(x>=145);
C = (-140*f(x) + 8.009982333990162e+03)';
diff = N - f(x)';

[ax,h1,h2] = plotyy(x,N,x,C);
set(ax(1),'YTick',0:20:100);
set(ax(2),'YTick',0:1000:10000);

set(h1,'LineWidth',2);
set(h2,'LineWidth',2,'Color','m');

h3 = line(x,f(x),'Color','black');
h4 = line(x,f(x),'Color','black','LineWidth',2,'LineStyle','--');

h5 = line(x,diff(x),'Color','r');
h6 = line(x,diff(x),'Color','r','LineWidth',2','LineStyle','--');

set(ax(1),'FontSize',15);
set(ax(2),'FontSize',15);
set(ax(2),'YColor','m');