classdef ControlArea
    
    properties
        totalSimulationRuns
        currRun
        totalSteps              
        currStep
        deviceArray
        poissonAll
        varSupplyAll
        chargeTrace_pc
        dischargeTrace_pc
        chargeTrace_mac
        dischargeTrace_mac
    end
    
    methods
        function obj = ControlArea(vargin)
            obj.poissonAll = vargin{1};
            obj.varSupplyAll = vargin{2};
            obj.chargeTrace_pc = vargin{3};
            obj.dischargeTrace_pc = vargin{4};
            obj.chargeTrace_mac = vargin{5};
            obj.dischargeTrace_mac = vargin{6};
        end
        
        function [obj, currentStep, deviceArray] = initializeDevices(obj, currentRun)
            r=currentRun;
            obj = setCurrRun(obj,r); obj = setCurrStep(obj,1);
            initialLaptopCount = obj.poissonAll{r}(1,1)-obj.poissonAll{r}(2,1);
            if initialLaptopCount < 0
                initialLaptopCount = 0;
            end
            nIDs = initialLaptopCount;
            for i=1:nIDs
                toss = rand;
                if toss >= 0.5
                    % PC
                    isCharging = rand;
                    if isCharging >= 0.5
                        obj.deviceArray{i,obj.currStep} = Laptop('pc',obj.chargeTrace_pc,obj.dischargeTrace_pc,true);
                    else
                        obj.deviceArray{i,obj.currStep} = Laptop('pc',obj.chargeTrace_pc,obj.dischargeTrace_pc,false);
                    end
                else
                    % Mac
                    isCharging = rand;
                    if isCharging >= 0.5
                        obj.deviceArray{i,obj.currStep} = Laptop('mac',obj.chargeTrace_mac,obj.dischargeTrace_mac,true);
                    else
                        obj.deviceArray{i,obj.currStep} = Laptop('mac',obj.chargeTrace_mac,obj.dischargeTrace_mac,false);
                    end
                end
            end
            currentStep = obj.currStep;
            deviceArray = obj.deviceArray;
        end
        
        function [currentStep, iterDeviceArray] = stepZone(obj, currRun, currStep, origDeviceArray, stepSize, dsmFlag, supplyPrediction)
            r=currRun; s=currStep;
            arrivals = obj.poissonAll{r}(1,s); departures = obj.poissonAll{r}(2,s);
            origDeviceCount = length(origDeviceArray);
            if origDeviceCount+arrivals-departures <= 0
                temp = {};
            else
                temp=addDevices(obj,origDeviceArray,arrivals);
                temp=removeDevices(obj,temp,departures);
                for i = 1:length(temp) % check that temp{i} is not null
                    if ~isempty(temp{i})
                        temp{i} = stepLaptop(temp{i},stepSize);
                    end
                end
                if(dsmFlag)
                    [temp,knapsackCells] = knapsackScheduler(obj,temp,supplyPrediction,0.8);
                end
            end
            currentStep = s+1;
            iterDeviceArray = temp;
        end
        
        function deviceArray = runSimulation(obj,nRuns, nSteps)
            obj.totalSimulationRuns = nRuns;
            obj.currRun = 1;
            obj.totalSteps = nSteps;
            while r <= nRuns
                for s=1:nSteps
                end
                obj.currRun=obj.currRun+1;
                if (obj.CurrRn > obj.totalSimulationRuns)
                    break
                end
            end
        end
        
        function [scheduledDeviceArray,resortedKnapsackCellMatrix] = knapsackScheduler(obj,currDeviceArray,P_supply_predicted,zscore_thresh)
            if isempty(currDeviceArray)
                m = currDeviceArray;
            else   
                m = currDeviceArray;
                nIDs=length(m);
                knapsackCellMatrix = cell(nIDs,3);
                for i=1:nIDs
                    knapsackCellMatrix{i,1}=i; knapsackCellMatrix{i,2}=m{i};
                    if ~isempty(m{i})
                        knapsackCellMatrix{i,3}=getZscore(m{i});
                    else
                        knapsackCellMatrix{i,3}=0;
                    end
                end
                sortedKnapsackCellMatrix = sortcell(knapsackCellMatrix,3,'descend');
                P_load_predicted=0;
                if P_supply_predicted > 0
                    divider = 1;
                    for i=1:nIDs
                        if P_load_predicted < P_supply_predicted
                            if ~isempty(sortedKnapsackCellMatrix{i,2})
                                if getIsCharging(sortedKnapsackCellMatrix{i,2})
                                    P_load_predicted = P_load_predicted + getCurrPower(sortedKnapsackCellMatrix{i,2});
                                else
                                    P_load_predicted = P_load_predicted + getProjectedPower(sortedKnapsackCellMatrix{i,2});
                                end
                                if P_load_predicted >= P_supply_predicted
                                    divider = i;
                                    break;
                                else
                                    if ~getIsCharging(sortedKnapsackCellMatrix{i,2})
                                        sortedKnapsackCellMatrix{i,2} = translateLaptop(sortedKnapsackCellMatrix{i,2},'d->c');
                                    end
                                end
                            end
                        end
                        divider = i;
                    end
                    for i = divider:nIDs
                        if ~isempty(sortedKnapsackCellMatrix{i,2}) && getIsCharging(sortedKnapsackCellMatrix{i,2})
                            sortedKnapsackCellMatrix{i,2} = translateLaptop(sortedKnapsackCellMatrix{i,2},'c->d');
                        end
                    end
                else
                    zscore_safety = 0.75*zscore_thresh;
                    threshOn = false;
                    if (threshOn)
                        for i=1:nIDs
                            if ~isempty(sortedKnapsackCellMatrix{i,2})
                                if sortedKnapsackCellMatrix{i,3} <= .4
                                    if getIsCharging(sortedKnapsackCellMatrix{i,2})
                                        sortedKnapsackCellMatrix{i,2} = translateLaptop(sortedKnapsackCellMatrix{i,2},'c->d');
                                    end
                               end
                                if sortedKnapsackCellMatrix{i,3} >= .8
                                    if ~getIsCharging(sortedKnapsackCellMatrix{i,2})
                                        sortedKnapsackCellMatrix{i,2} = translateLaptop(sortedKnapsackCellMatrix{i,2},'d->c');
                                    end
                                end
                            end
                        end
                    end
                end
                resortedKnapsackCellMatrix = sortcell(sortedKnapsackCellMatrix,1,'ascend');
                m = resortedKnapsackCellMatrix(:,2);
            end
            scheduledDeviceArray = m;
        end
        
        function totalEnergy = getTotalEnergy(obj,inputPowerTrace)
            [m,n]=size(inputPowerTrace);
            energy=zeros(m,1);
            if inputPowerTrace(1) <= 0
                energy(1) = 0;
            else
                energy(1)=inputPowerTrace(1)*.25;
            end
            for t=1:95
                if inputPowerTrace(t+1) <= 0
                    energy(t+1) = energy(t) + 0;
                else
                    energy(t+1)=energy(t)+inputPowerTrace(t+1)*.25;
                end
            end
            totalEnergy=energy(96);
        end
        
        function value = getScaledIMV(obj,unscaledIMV, supplyTrace,demandTrace)
            supply = getTotalEnergy(obj,supplyTrace);
            demand = getTotalEnergy(obj,demandTrace);
            value = unscaledIMV*(demand/supply); %orig: supply/demand
        end
        
        function newDeviceArray = addDevices(obj,origDeviceArray,nArrivals)
            origDeviceCount=length(origDeviceArray);
            for arr = 1:nArrivals
                toss = rand;
                if toss >= 0.5
                    % PC
                    isCharging = rand;
                    if isCharging > 0.35
                        origDeviceArray{origDeviceCount+arr,1} = Laptop('pc',obj.chargeTrace_pc,obj.dischargeTrace_pc,true);
                    else
                        origDeviceArray{origDeviceCount+arr,1} = Laptop('pc',obj.chargeTrace_pc,obj.dischargeTrace_pc,false);
                    end
                else
                    % Mac
                    isCharging = rand;
                    if isCharging > 0.35
                        origDeviceArray{origDeviceCount+arr,1} = Laptop('mac',obj.chargeTrace_mac,obj.dischargeTrace_mac,true);
                    else
                        origDeviceArray{origDeviceCount+arr,1} = Laptop('mac',obj.chargeTrace_mac,obj.dischargeTrace_mac,false);
                    end
                end 
            end
            newDeviceArray = origDeviceArray;
        end
        
        function newDeviceArray = removeDevices(obj,origDeviceArray,nDepartures)
            origDeviceCount = length(origDeviceArray);
            if nDepartures > 0
                leavingDevices = rand_int(1,origDeviceCount,nDepartures);
                for d = 1:nDepartures
                    for nID = 1:origDeviceCount
                        if nID == leavingDevices(d)
                            origDeviceArray{nID,1} = [];
                        end
                    end
                end
            end
            newDeviceArray = origDeviceArray;
        end
        
        function value = aggrDeviceLoad(obj,currDeviceArray)
            aggrLoad = 0;
            for d = 1:length(currDeviceArray)
                if ~isempty(currDeviceArray{d,1})
                    aggrLoad = aggrLoad+getCurrPower(currDeviceArray{d,1});
                end
            end
            value = aggrLoad;
        end
                
        function value = aggrDeviceCapacity(obj,currDeviceArray)
            aggrCapacity = 0;
            for d = 1:length(currDeviceArray)
                if ~isempty(currDeviceArray{d,1})
                    aggrCapacity = aggrCapacity+getCurrCapacity(currDeviceArray{d,1});
                end
            end
            value = aggrCapacity;
        end
        
        function value = totalDeviceCount(obj,currDeviceArray)
            temp = currDeviceArray;
            count=0;
            for i=1:length(temp)
                if ~isempty(temp{i})
                    count=count+1;
                end
            end
            value = count;
        end
        
        function value = pluggedDeviceCount(obj,currDeviceArray)
            temp = currDeviceArray;
            count=0;
            for i=1:length(temp)
                if ~isempty(temp{i})
                    if getIsCharging(temp{i})
                        count=count+1;
                    end
                end
            end
            value = count;
        end
        % Getters and Setters
        function value = getTotalSimulationRuns(obj)
            value = obj.totalSimulationRuns;
        end
        function value = getCurrRun(obj)
            value = obj.currRun;
        end
        function value = getTotalSteps(obj)
            value = obj.totalSteps;
        end
        function value = getCurrStep(obj)
            value = obj.currStep;
        end
        function value = getDeviceArray(obj)
            value = obj.deviceArray;
        end
        function value = getPoissonAll(obj)
            value = obj.poissonAll;
        end
        function value = getVarSupplyAll(obj)
            value = obj.varSupplyAll;
        end
        function value = getChargeTrace_pc(obj)
            value = obj.chargeTrace_pc;
        end
        function value = getDischargeTrace_pc(obj)
            value = obj.dischargeTrace_pc;
        end
        function value = getChargeTrace_mac(obj)
            value = obj.chargeTrace_mac;
        end
        function value = getDischargeTrace_mac(obj)
            value = obj.dischargeTrace_mac;
        end
        
        function obj = setTotalSimulationRuns(obj,value)
            obj.totalSimulationRuns = value;
        end
        function obj = setCurrRun(obj,value)
            obj.currRun = value;
        end
        function obj = setTotalSteps(obj,value)
            obj.totalSteps = value;
        end
        function obj = setCurrStep(obj,value)
            obj.currStep = value;
        end
        function obj = setDeviceArray(obj,value)
            obj.deviceArray = value;
        end
        function obj = setPoissonAll(obj,value)
            obj.poissonAll = value;
        end
        function obj = setVarSupplyAll(obj,value)
            obj.varSupplyAll = value;
        end
        function obj = setChargeTrace_pc(obj,value)
            obj.chargeTrace_pc = value;
        end
        function obj = setDischargeTrace_pc(obj,value)
            obj.dischargeTrace_pc = value;
        end
        function obj = setChargeTrace_mac(obj,value)
            obj.chargeTrace_mac = value;
        end
        function obj = setDischargeTrace_mac(obj,value)
            obj.dischargeTrace_mac = value;
        end
        
    end
end