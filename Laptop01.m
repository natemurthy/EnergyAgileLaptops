% Charge curve: capacity as a function of time
C_mac = @(t) (t*160/3).*((t >= 0) & (t < 15)) + (800+24*(t-15)).*((t >= 15) & (t < 90)) + (2600+(t-90)*(4123-2600)/145).*((t >= 90) & (t < 235)) + (4123).*(t >= 235);
chargeData_mac = C_mac(1:235); % 235 min charge time, the last index needs to map to 0 since (dis)charging has stopped

% Discharge curve of My Mac Book: capacity as a function of time
D_mac = @(t) (-t*4123/135+4123).*(t<=135) + (0).*(t>135);
dischargeData_mac = D_mac(1:135);  % 135 min discharge time, the last index needs to map to 0 since (dis)charging has stopped

% power trace as a function of capacity
P_mac = @(c) (54.9).*(c >= 0 & c < 800) + (36.25).*(c >= 800 & c < 2600) + (24.75).*(c >= 2600 & c < 4000) + (24.75+(c-4000)*(18.5-25.2)/123).*(c >= 4000 & c < 4123) + (16.4).*(c >= 4123);

% capacity and power traces for one MacBook 2006 during charging
chargeTrace_mac = zeros(2,length(chargeData_mac));   
chargeTrace_mac(1,:) = chargeData_mac;
chargeTrace_mac(2,:) = P_mac(chargeData_mac);

% caapcity and power traces during discharging
dischargeTrace_mac = zeros(2,length(dischargeData_mac));
dischargeTrace_mac(1,:) = dischargeData_mac;

% plot 1 cycle
plot(chargeData_mac,'Color','b'); hold on; plot(237:373,dischargeData_mac,'Color','m');
