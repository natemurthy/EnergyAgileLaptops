nSteps = 96;
stepSize = 15;

%bacnet = csvread('SDH-bacnet-1hr.csv');
%load = bacnet(:,2);
%load = load(:,1)-850;
%normLoad = load(:,1)/(max(load));
% bacnet data fit
% x=1:24; y=-65*cos(1/3.3*x-4.7*pi/2)+72; hold on; plot(x,y,'Color','r');

% poisson rate scaling factor as a function of building load
alph0=-.45+.08*randn(60,1);
beta0=2.18+.10*randn(60,1);
beta1=1.1077*abs(alph0);
x=1:24;
for i=1:60
    y(i,:)=alph0(i)*cos(.2568*x-beta0(i)*pi)+beta1(i);
end

for i=1:60
    y(i,:)=y(i,:)/max(max(y));
end

lambda_Big = 20;
lambda_Small = 10;
%%%%%%% normalized Bacnet data %%%%%%%%%
%poissonMatrix = zeros(2,nSteps); % first row for arrivals, second for departures

%initialLaptopCount = 0;

%for i=1:nSteps
%    normLoadIndex = ceil(i/4);
%    if (normLoadIndex < 15)
%        poissonMatrix(1,i) = floor(poissrnd(normLoad(normLoadIndex)*lambda_Big));
%        poissonMatrix(2,i) = floor(poissrnd(normLoad(normLoadIndex)*lambda_Small));
%    elseif (normLoadIndex >= 15)
%        poissonMatrix(1,i) = floor(poissrnd(normLoad(normLoadIndex)*lambda_Small));
%        poissonMatrix(2,i) = floor(poissrnd(normLoad(normLoadIndex)*lambda_Big));
%    end
%end



%loadTraces(5,:) = abs(poissonMatrix(1,:)-poissonMatrix(2,:));

%stairs(poissonMatrix(1,:)-poissonMatrix(2,:)); hold on;
stairs(abs(poissonMatrix(1,:)-poissonMatrix(2,:)),'Color','g');

poissonMatrix = zeros(2,nSteps);
poissonAll = {};
for k=1:120
    for i=1:nSteps
        normLoadIndex = ceil(i/4);
        if (normLoadIndex < 15)
            poissonMatrix(1,i) = floor(poissrnd(y(k,normLoadIndex)*lambda_Big));
            poissonMatrix(2,i) = floor(poissrnd(y(k,normLoadIndex)*lambda_Small));
        elseif (normLoadIndex >= 15)
            poissonMatrix(1,i) = floor(poissrnd(y(k,normLoadIndex)*lambda_Small));
            poissonMatrix(2,i) = floor(poissrnd(y(k,normLoadIndex)*lambda_Big));
        end
    end
    poisonAll{k} = poissonMatrix;
    plot(all_PV(:,k)); hold on; stairs(60*abs(poissonMatrix(1,:)-poissonMatrix(2,:)),'Color','r'); 
    pause(1); clf;
end

totalArrivals = sum(poissonMatrix(1,:));
totalDepartures = sum(poissonMatrix(2,:));

if (totalDepartures > totalArrivals)
    initialLaptopCount = (totalDepartures - totalArrivals)+floor(poissrnd(lambda_Big));
end