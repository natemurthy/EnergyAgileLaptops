% Charge curve: capacity as a function of time
C_dell = zeros(1,130);
% power trace as a function of time
P_dell = @(t)(62.3).*(t<20)+(40*exp(-.0366*(t-20))+12.33*exp((-5.217e-4)*(t-20))+10).*(t>=20);

% Charge curve of Dell Latitude
% 130 minute charge time
for i=1:130
    C_dell(i+1)=C_dell(i)+P_dell(i);
end
% Assume 12V battery with .90 efficiency
chargeData_dell = 900*C_dell(2:131)/60/12; 
chargeTrace_dell = zeros(2,130);
chargeTrace_dell(1,:) = chargeData_dell; % capacity
chargeTrace_dell(2,:) = P_dell(1:130);   % power

% Discharge curve of Dell Latitude: capacity as a function of time
% 240 min discharge time
maxCapacity = max(chargeData_dell);
D_dell = @(t) (-t*maxCapacity/240+maxCapacity).*(t<=240) + (0).*(t>240);
dischargeTrace_dell = zeros(2,240);
dischargeTrace_dell(1,:) = D_dell(1:240); % capacity, power=0

% plot 1 cycle
hold on; plot(chargeTrace_dell(1,:),'Color','g'); hold on; plot(131:370,dischargeTrace_dell,'Color','r');