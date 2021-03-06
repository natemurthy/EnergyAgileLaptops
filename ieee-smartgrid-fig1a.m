% Must be used in Dropbox/.../MATLAB directory
M = csvread('../data/ieee-smartgrid-fig1-data.csv');
P = @(c) (38.5).*(c >= 0 & c < 739) + (19.85).*(c >= 739 & c < 2445) + (8.35).*(c >= 2445 & c < 3900) + (8.35+(c-3900)*(18.5-25.2)/123).*(c >= 3900 & c < 4026) + (0.0).*(c >= 4026);
M(:,4) = P(M(:,1));
N = [M(:,1) M(:,3) M(:,4) M(:,3)-M(:,4)];
x = 1:length(N(:,1));
[ax, h(1), h(2)] = plotyy(x,N(:,2),x,N(:,1));
set(h(1),'LineWidth',2);
set(h(2),'LineWidth',2,'Color','m');
h(3) = line(x,N(:,4), 'Parent', ax(1), 'Color','r','LineWidth',2,'LineStyle','--');
h(4) = line(x,N(:,4), 'Parent', ax(1), 'Color','r','LineWidth',1);

h(5) = line(x,N(:,3), 'Parent', ax(1), 'Color','black','LineWidth',2,'LineStyle','--');
h(6) = line(x,N(:,3), 'Parent', ax(1), 'Color','black','LineWidth',1);

set(ax(2), 'YColor','m');
set(ax(1), 'YTick', 0:20:100);
set(ax(2), 'YTick', 0:1000:5000);
set(ax(1),'FontSize',15);
set(ax(2),'FontSize',15);