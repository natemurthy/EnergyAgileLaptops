nSteps = 288;
stepSize = 5;

bacnet = csvread('SDH-bacnet-1hr.csv');
load = bacnet(:,2);
load = load(:,1)-850;
normLoad = load(:,1)/(max(load));

lambda_Big = 8;
lambda_Small = 4;

poissonMatrix = zeros(2,nSteps); % first row for arrivals, second for departures

initialLaptopCount = 0;

for i=1:nSteps
    normLoadIndex = ceil(i/4);
    if (normLoadIndex < 15)
        poissonMatrix(1,i) = floor(poissrnd(normLoad(normLoadIndex)*lambda_Big));
        poissonMatrix(2,i) = floor(poissrnd(normLoad(normLoadIndex)*lambda_Small));
    elseif (normLoadIndex >= 15)
        poissonMatrix(1,i) = floor(poissrnd(normLoad(normLoadIndex)*lambda_Small));
        poissonMatrix(2,i) = floor(poissrnd(normLoad(normLoadIndex)*lambda_Big));
    end
end

totalArrivals = sum(poissonMatrix(1,:));
totalDepartures = sum(poissonMatrix(2,:));

if (totalDepartures > totalArrivals)
    initialLaptopCount = (totalDepartures - totalArrivals)+floor(poissrnd(lambda_Big));
end