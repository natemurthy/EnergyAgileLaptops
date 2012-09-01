% isolate individual days
summer=csvread('fatspaniel-summer-matlabsafe.csv');
winter=csvread('fatspaniel-winter-matlabsafe.csv');

%input=summer;
%input=winter;
all_PV=zeros(96,120);

col=1;

while (col <= 60)
    row=1;
    colMod=mod(col-1,12)+1;
    while (row <= 480)
        rowMod=mod(row-1,96)+1;
        all_PV(rowMod,col)=summer(row,colMod);
        row=row+1;
    end
    col=col+1;
end

if (col==61)
    while (col <= 120)
        row=1;
        colMod=mod(col-61,12)+1;
        while (row <= 480)
            rowMod=mod(row-1,96)+1;
            all_PV(rowMod,col)=winter(row,colMod);
            row=row+1;
        end
        col=col+1;
    end
end

Y = [1, 5, 3;
	3, 2, 7;
	1, 5, 3;
	2, 6, 1];
area(Y)
grid on
colormap summer
set(gca,'Layer','top')
title 'Stacked Area Plot'

sum(poissonAll{1}(2,:))-sum(poissonAll{1}(1,:))

for k=1:120
    total=zeros(1,96);
    for t=1:95
        total(1)=(poissonAll{k}(1,1)-poissonAll{k}(2,1));
        total(t+1)=total(t)+(poissonAll{k}(1,t+1)-poissonAll{k}(2,t+1));
        if total(t+1) <= 0
            total(t+1)=0;
        end
    end
    clf; plot(50*total,'LineWidth',2); hold on; plot(solarTraces(:,k)','Color','r','LineWidth',2);
    pause(1);
end

%zscore
x=0:.04:1; y=x;
[xx,yy]=meshgrid(x,y);
zz = (1-yy)*exp(-3*xx);
surf(xx,yy,zz);

% moving averages
movingAvgSolarTraces_1hr=zeros(96,120); % prediction
for r=1:120
    movingAvgSolarTraces_1hr(:,r)=smooth(solarTraces(:,r),4);
end

movingAvgSolarTraces_2hr=zeros(96,120); % volatility benchmark
for r=1:120
    movingAvgSolarTraces_2hr(:,r)=smooth(solarTraces(:,r),8);
end

% plot figure 6 in energy-agile-laptop.pdf
%persistence
subplot(3,1,1);
b=regress(dependence_p', [ones(1,120); log(scaledIMV_p)]');
yH2=[ones(1,120); log(scaledIMV_p)]'*b;
[temp, i2] = sort(scaledIMV_p);
hold on;semilogx(scaledIMV_p, dependence_p, 'x','color','r','LineWidth',2); hold on; semilogx(scaledIMV_p(i2), yH2(i2)','r','LineWidth',2);
b=regress(dependence_baseline', [ones(1,120); log(scaledIMV_baseline)]')
yH=[ones(1,120); log(scaledIMV_baseline)]'*b;
[temp, i] = sort(scaledIMV_baseline);
hold on; semilogx(scaledIMV_baseline, dependence_baseline, 'o','MarkerFaceColor','black','MarkerEdgeColor','black','LineWidth',.5); hold on; semilogx(scaledIMV_baseline(i), yH(i)','black','LineWidth',2);
grid on
% moving avg
subplot(3,1,2);
b=regress(dependence_m', [ones(1,120); log(scaledIMV_m)]')
yH3=[ones(1,120); log(scaledIMV_m)]'*b;
[temp, i3]=sort(scaledIMV_m);
hold on;semilogx(scaledIMV_m, dependence_m, 'x','color',[.1328 .5430 .1328],'LineWidth',2); hold on; semilogx(scaledIMV_m(i3), yH3(i3)','g','LineWidth',2);
hold on; semilogx(scaledIMV_baseline, dependence_baseline, 'o','MarkerFaceColor','black','MarkerEdgeColor','black','LineWidth',.5); hold on; semilogx(scaledIMV_baseline(i), yH(i)','black','LineWidth',2);
grid on;
%oracle
subplot(3,1,3);
b=regress(dependence_o', [ones(1,120); log(scaledIMV_o)]')
yH4=[ones(1,120); log(scaledIMV_o)]'*b;
[temp, i4]=sort(scaledIMV_o);
hold on;semilogx(scaledIMV_o, dependence_o, 'x','color','b','LineWidth',2); hold on; semilogx(scaledIMV_o(i4), yH4(i4)','b','LineWidth',2);
hold on; semilogx(scaledIMV_baseline, dependence_baseline, 'o','MarkerFaceColor','black','MarkerEdgeColor','black','LineWidth',.5); hold on; semilogx(scaledIMV_baseline(i), yH(i)','black','LineWidth',2);
grid on;

%
% semilog regression
%
%persistence
subplot(2,1,1);
b=regress(dependence_p', [ones(1,120); log(scaledIMV_p)]');
yH2=[ones(1,120); log(scaledIMV_p)]'*b;
[temp, i2] = sort(scaledIMV_p);
semilogx(scaledIMV_p, dependence_p, 'x','color','r','LineWidth',2); hold on; semilogx(scaledIMV_p(i2), yH2(i2)','r','LineWidth',4,'LineStyle',':');
%moving avg
b=regress(dependence_m', [ones(1,120); log(scaledIMV_m)]')
yH3=[ones(1,120); log(scaledIMV_m)]'*b;
[temp, i3]=sort(scaledIMV_m);
hold on; semilogx(scaledIMV_m, dependence_m, 'x','color',[.1328 .5430 .1328],'LineWidth',2); hold on; semilogx(scaledIMV_m(i3), yH3(i3)','g','LineWidth',3,'LineStyle','--');
%oracle
b=regress(dependence_o', [ones(1,120); log(scaledIMV_o)]')
yH4=[ones(1,120); log(scaledIMV_o)]'*b;
[temp, i4]=sort(scaledIMV_o);
hold on; semilogx(scaledIMV_o, dependence_o, 'x','color','b','LineWidth',2); hold on; semilogx(scaledIMV_o(i4), yH4(i4)','b','LineWidth',3,'LineStyle','-.');
% baseline
b=regress(dependence_baseline', [ones(1,120); log(scaledIMV_baseline)]')
yH=[ones(1,120); log(scaledIMV_baseline)]'*b;
[temp, i] = sort(scaledIMV_baseline);
hold on; semilogx(scaledIMV_baseline, dependence_baseline, 'o','MarkerFaceColor','black','MarkerEdgeColor','black','LineWidth',.5); hold on; semilogx(scaledIMV_baseline(i), yH(i)','black','LineWidth',3);
grid on

%
% normal regression
%
%persistence
subplot(2,1,2);
b=regress(dependence_p', [ones(1,120); log(scaledIMV_p)]');
yH2=[ones(1,120); log(scaledIMV_p)]'*b;
[temp, i2] = sort(scaledIMV_p);
plot(scaledIMV_p, dependence_p, 'x','color','r','LineWidth',2); hold on; plot(scaledIMV_p(i2), yH2(i2)','r','LineWidth',2);
%moving avg
b=regress(dependence_m', [ones(1,120); log(scaledIMV_m)]')
yH3=[ones(1,120); log(scaledIMV_m)]'*b;
[temp, i3]=sort(scaledIMV_m);
hold on; plot(scaledIMV_m, dependence_m, 'x','color',[.1328 .5430 .1328],'LineWidth',2); hold on; plot(scaledIMV_m(i3), yH3(i3)','g','LineWidth',2);
%oracle
b=regress(dependence_o', [ones(1,120); log(scaledIMV_o)]')
yH4=[ones(1,120); log(scaledIMV_o)]'*b;
[temp, i4]=sort(scaledIMV_o);
hold on; plot(scaledIMV_o, dependence_o, 'x','color','b','LineWidth',2); hold on; plot(scaledIMV_o(i4), yH4(i4)','b','LineWidth',2);
% baseline
b=regress(dependence_baseline', [ones(1,120); log(scaledIMV_baseline)]')
yH=[ones(1,120); log(scaledIMV_baseline)]'*b;
[temp, i] = sort(scaledIMV_baseline);
hold on; plot(scaledIMV_baseline, dependence_baseline, 'o','MarkerFaceColor','black','MarkerEdgeColor','black','LineWidth',.5); hold on; plot(scaledIMV_baseline(i), yH(i)','black','LineWidth',2);
grid on