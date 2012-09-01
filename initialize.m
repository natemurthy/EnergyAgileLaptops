nSteps = 96;
nDays = 120;
stepSize = 15;

% Load solar traces
summer=csvread('../data/fatspaniel-summer-matlabsafe.csv');
winter=csvread('../data/fatspaniel-winter-matlabsafe.csv');
A=reshape(summer,96,60); B=reshape(winter,96,60);
solarTraces=[A B];

%%%%%%% Dell %%%%%%%%
% Charge curve: capacity as a function of time
% 80 min charge time (default)
cTime_dell = 120;
C_dell = zeros(1,cTime_dell);
% power trace as a function of time
P_dell = @(t)(62.3).*(t<40)+(40*exp(-.0366*(t-40))+12.33*exp((-5.217e-4)*(t-40))+10).*(t>=40);
% Charge curve of Dell Latitude
% 130 minute charge time
for i=1:cTime_dell-1
    C_dell(i+1)=C_dell(i)+P_dell(i);
end
% 12V battery with .90 efficiency
chargeData_dell = 900*C_dell/60/12; 
chargeTrace_dell = zeros(2,cTime_dell);
chargeTrace_dell(1,:) = chargeData_dell; % capacity
chargeTrace_dell(2,:) = P_dell(1:cTime_dell);   % power
% Discharge curve of Dell Latitude: capacity as a function of time
% 240 min discharge time (default)
dTime_dell = 240;
maxCapacity = max(chargeData_dell);
D_dell = @(t) (-t*maxCapacity/dTime_dell+maxCapacity).*(t<=dTime_dell) + (0).*(t>dTime_dell);
dischargeTrace_dell = zeros(2,dTime_dell);
dischargeTrace_dell(1,:) = D_dell(1:dTime_dell);

%%%%%%% Mac %%%%%%%%
% Charge curve: capacity as a function of time
% 235 min charge time (default)
cTime_mac = 235;
C_mac = @(t) (t*160/3).*((t >= 0) & (t < 15)) + (800+24*(t-15)).*((t >= 15) & (t < 90)) + (2600+(t-90)*(4123-2600)/145).*((t >= 90) & (t < 235)) + (4123).*(t >= 235);
chargeData_mac = C_mac(1:cTime_mac);
% Discharge curve of My Mac Book: capacity as a function of time
% 135 min discharge time (default)
dTime_mac = 135;
D_mac = @(t) (-t*4123/dTime_mac+4123).*(t<=dTime_mac) + (0).*(t>dTime_mac);
dischargeData_mac = D_mac(1:dTime_mac); 
% power trace as a function of capacity
P_mac = @(c) (54.9).*(c >= 0 & c < 800) + (36.25).*(c >= 800 & c < 2600) + (24.75).*(c >= 2600 & c < 4000) + (24.75+(c-4000)*(18.5-25.2)/123).*(c >= 4000 & c < 4123) + (16.4).*(c >= 4123);
% capacity and power traces for one MacBook 2006 during charging
chargeTrace_mac = zeros(2,length(chargeData_mac));   
chargeTrace_mac(1,:) = chargeData_mac;
chargeTrace_mac(2,:) = P_mac(chargeData_mac);
% caapcity and power traces during discharging
dischargeTrace_mac = zeros(2,length(dischargeData_mac));
dischargeTrace_mac(1,:) = dischargeData_mac;


%%%%%%% Poisson Model %%%%%%%%
% poisson rate scaling factor as a function of building occupancy
alph0=-.25+.08*randn(nDays,1);
beta0=2.18+.10*randn(nDays,1);
beta1=1.1077*abs(alph0);
x=1:24;
for i=1:nDays
    y(i,:)=alph0(i)*cos(.2568*x-beta0(i)*pi)+beta1(i);
end

for i=1:nDays
    y(i,:)=y(i,:)/max(max(y)); % normalize w.r.t. peak occupancy 
end
% Poisson parameters
lambda_Big = 4;
lambda_Small = 2;
poissonMatrix = zeros(2,nSteps); % first row for arrivals, second for departures
initialLaptopCount = 0;
poissonAll = {};
% nest within step function
for k=1:nDays
    for i=1:nSteps
        normLoadIndex = ceil(i/4);
        if (normLoadIndex < 12 )
            poissonMatrix(1,i) = floor(poissrnd(y(k,normLoadIndex)*lambda_Big));
            poissonMatrix(2,i) = floor(poissrnd(y(k,normLoadIndex)*lambda_Small));
        elseif (normLoadIndex >= 12)
            poissonMatrix(1,i) = floor(poissrnd(y(k,normLoadIndex)*lambda_Small));
            poissonMatrix(2,i) = floor(poissrnd(lambda_Big));
        end
    end
    poissonAll{k} = poissonMatrix;
end

initvargs = {poissonAll,solarTraces,chargeTrace_dell, dischargeTrace_dell, chargeTrace_mac, dischargeTrace_mac};
zone=ControlArea(initvargs);
%[currrentStep, deviceArray] = zone.initializeDevices(initvargs);
%zone.runSimulation(nDays,nSteps);