classdef TrafficGen
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        % This number represents the percentange of vehicles that want to
        % join a caravan.
        caravanThreshold = .15;
    end

    properties
        arrivalTimes;       % Sorted set of arrival times for each lane.
        timeIndex;          % Next time index (per lane).  Only incremented when a 
                            % new vehicle has been created for that lane.
        previousTime;       % Tells the last time stamp that was used 
        timeStep;           % Time step used for this simulation run.
        lanes;              % Number of lanes
        travelLanes;        % Number of lanes open for general travel. Either
                            % lanes (if not having a caravan lane) or lanes
                            % - 1 (if having a caravan lane)
        lastVehicleId;      % Last ID used for a vehicle.
        useCaravans;        % True if we are using caravans, false if not.
        
        % Caravan info
        lastCaravanId;      % Last ID used for a caravan.
        caravanSpeed = 75;
        minDistanceBetweenCaravans = .5;  % Half mile between caravans
        minCaravanSize = 4;
        maxCaravanSize = 30;
        createdFirstCaravan = false;
    end
    
    methods
        % Constructor
        % Just zeros out the required values.
        function obj = TrafficGen
            obj.arrivalTimes = zeros(0, 0);
            obj.previousTime = 0;
            obj.timeIndex = zeros(1, 0);
            obj.lanes = 0;
            obj.travelLanes = 0;    % If using caravans, this is lanes - 2.
            obj.lastVehicleId = 0;
            obj.useCaravans = true;
            obj.lastCaravanId = 0;
            obj.createdFirstCaravan = false;
        end
        
        % Method to initial for a run.
        % This will generate the arrival times for all of the lanes based
        % on the parameters passed in
        function obj = InitTraffic(obj, lanes, arrivalRate, lengthOfRun, timeStep, useCaravans)
            obj.arrivalTimes = zeros(lanes, uint32(lengthOfRun/timeStep));
            obj.timeIndex = ones(1, lanes);
            obj.previousTime = 0;
            obj.timeStep = timeStep;
            obj.lanes = lanes;
            obj.lastVehicleId = 0;
            obj.useCaravans = useCaravans;
            if (useCaravans)
                obj.travelLanes = lanes - 2;
            else
                obj.travelLanes = lanes;
            end
            
            % Spread the arrival rate over the number of lanes.
            meanArrival = 1/(arrivalRate/lanes);
            % Now fill out arrival times for each of the lanes
            for l = 1:obj.lanes
                lastArrive = 0;
                i = 0;
                while (lastArrive < lengthOfRun)
                    i = i + 1;
                    if (i >= 2)
                        obj.arrivalTimes(l, i) = obj.arrivalTimes(l, i-1) - meanArrival * log(1-rand);
                    else
                        obj.arrivalTimes(l, i) = -meanArrival * log(1 - rand);
                    end
                    lastArrive = obj.arrivalTimes(l, i);
                end
            end
        end
        
        
        % Method to create an array of vehicles that will be added for this
        % time step.
        function [obj, vehicles] = TimeStep(obj)
            time = obj.previousTime + obj.timeStep;
            vehicles(1000) = Vehicle;
            vId = obj.lastVehicleId;
            % For each lane, see if we have to create any vehicles.
            % Don't do the caravan lane;
            for lane = 1:obj.travelLanes
                % Now look at the arrival times for this lane, starting at
                % the index previously saved.  While there are arrival
                % times less than the current time, create a vehicle
                i = obj.timeIndex(lane);
                maxIndex = size(obj.arrivalTimes, 2);
                v = 0;
                while ((i < maxIndex) && (obj.arrivalTimes(lane, i) < time))
                    vId = vId + 1;
                    v = v+ 1;
                    vehicles(v) = TrafficGen.NewVehicle(lane, vId, obj.caravanThreshold, obj.useCaravans);
                    i = i + 1;
                end
                
                if (v < 1000)
                    vehicles = vehicles(1:v);
                end
                obj.timeIndex(lane) = i;
            end
            
            % Now create a caravan, if needed.
            if (obj.useCaravans) 
                caravanLane = obj.lanes;
                vm = VehicleMgr.getInstance;
                % Find the closest caravan and see if it is far enough away
                lastCaravanDistance = TrafficGen.ClosestInLane (caravanLane, vm);
                if ~obj.createdFirstCaravan || (lastCaravanDistance >= obj.minDistanceBetweenCaravans)
                    % Now look at the arrival times for this lane, starting at
                    % the index previously saved.  While there are arrival
                    % times less than the current time, create a vehicle
                    createdCaravan = false;
                    cId = obj.lastCaravanId;

                    % No matter how many arrival times we have, we will only
                    % create one caravan.
                    i = obj.timeIndex(lane);
                    maxIndex = size(obj.arrivalTimes, 2);
                    posY = 0.0;
                    while ((i < maxIndex) && obj.arrivalTimes(caravanLane, i) < time)
                        if (~createdCaravan)
                            createdCaravan = true;
                            obj.createdFirstCaravan = true;
                            cId = cId + 1;
                            numCaravanCars = obj.minCaravanSize + (obj.maxCaravanSize - obj.minCaravanSize) * rand();
                            for c = 1:numCaravanCars
                                vId = vId + 1;
                                v = TrafficGen.NewVehicle(caravanLane, vId + 1000000, 0, false);
                                v.caravanNumber = cId;
                                v.caravanPosition = c;
                                v.posY = posY;
                                v.velocity = obj.caravanSpeed;
                                v.targetVelocity = v.velocity;
                                vehicles = [vehicles v];
                                
                                % Calc the NEXT posY
                                posY = posY - v.length - v.minCaravanDistance;
                            end
                        end
                        i = i + 1;
                    end

                    obj.timeIndex(caravanLane) = i;
                    obj.lastCaravanId = cId;
                end
            end
            
            obj.lastVehicleId = vId;
            obj.previousTime = time;
        end
            
    end
    
   methods(Static)
    % Function to search the highway and find the closest to the
    % BEGINNING of the highway.  It will return the distance down the
    % highway of the vehcile.
    function closest = ClosestInLane(lane, vm)
        closest = 0;
        % The closest will be the first one we find.
        for i=1:size(vm.highway, 1)
            if (vm.highway(i, 2) == lane)
                closest = vm.highway(i, 3);
                return;
            end
        end
    end

    % Function to create a new vehicle for the caravan.
    function v = NewVehicle (lane, id, caravanThreshold, useCaravans)
        v = Vehicle;
        v.lane = lane;
        v.id = id;
        
        % For the velocity of the vehicle, we will use a normal distribution
        % and offset it based on the lane number.  The range will be +/- 10
        % around a nominal speed.  The function to determine the speed is
        %  60 + ((lane - 1) * 10)
        nominalSpeed = 60 + ((lane - 1) * 10);
        
        % Range is +/- 1 0 around the nominal value
        loSpeed = nominalSpeed - 10;
        hiSpeed = nominalSpeed + 10;
        v.velocity = loSpeed + (hiSpeed - loSpeed) * rand();
        v.targetVelocity = v.velocity;
        
        % We will no assume that a certain percentange of a nominal
        % distribution of vehicles want to join a caravan.  This percentage
        % is a constant (caravanReqests);
        if (useCaravans)
            if (rand() < caravanThreshold)
                v.wantsCaravan = true;
            end
        end
        
        % Now pick a desitination ramp anywhere from 20 to 250 miles.
        v.destinationRamp = 20+(250-20) * rand();
        v.destination = v.destinationRamp;
        
        % And a drag area between 0.5 and 1.2
        %http://en.wikipedia.org/wiki/Automobile_drag_coefficient#Drag_area
        v.dragArea = 0.5+(1.2-0.5) * rand();
    end
   end
end

