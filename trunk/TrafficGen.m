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
        lastVehicleId;      % Last ID used for a vehicle.
    end
    
    methods
        % Constructor
        % Just zeros out the required values.
        function obj = TrafficGen
            obj.arrivalTimes = zeros(0, 0);
            obj.previousTime = 0;
            obj.timeIndex = zeros(1, 0);
            obj.lanes = 0;
            obj.lastVehicleId = 0;
        end
        
        % Method to initial for a run.
        % This will generate the arrival times for all of the lanes based
        % on the parameters passed in
        function obj = InitTraffic(obj, lanes, arrivalRate, lengthOfRun, timeStep)
            obj.arrivalTimes = zeros(lanes, uint32(lengthOfRun/timeStep));
            obj.timeIndex = ones(1, lanes);
            obj.previousTime = 0;
            obj.timeStep = timeStep;
            obj.lanes = lanes;
            obj.lastVehicleId = 0;
            
            % Spread the arrival rate over the number of lanes.
            meanArrival = 1/(arrivalRate/lanes);
            % Now fill out arrival times for each of the lanes
            for l = 1:lanes
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
                fprintf(1, 'number of arrivals is %d\n', i);
            end
        end
        
        
        % Method to create an array of vehicles that will be added for this
        % time step.
        function [obj, vehicles] = TimeStep(obj)
            time = obj.previousTime + obj.timeStep;
            vehicles = Vehicle.empty;
            vId = obj.lastVehicleId;
            % For each lane, see if we have to create any vehicles.
            % Don't do the caravan lane;
            for lane = 1:obj.lanes - 1
                % Now look at the arrival times for this lane, starting at
                % the index previously saved.  While there are arrival
                % times less than the current time, create a vehicle
                i = obj.timeIndex(lane);
                addedOneThisLane = false;
                while (obj.arrivalTimes(lane, i) < time)
                    if (~addedOneThisLane)
                        addedOneThisLane = true;
                        vId = vId + 1;
                        fprintf(1, 'Creating a vehicle, lane %d, id %d\n',...
                                lane, vId);
                        v = TrafficGen.NewVehicle(lane, vId, obj.caravanThreshold);
                        vehicles = [vehicles v];
                    end
                    i = i + 1;
                end
                obj.timeIndex(lane) = i;
            end
            obj.previousTime = time;
            obj.lastVehicleId = vId;
        end
        
    end
    
   methods(Static)
    function v = NewVehicle (lane, id, caravanThreshold)
        v = Vehicle;
        v.lane = lane;
        v.id = id;
        
        % For the velocity of the vehicle, we will use a normal distribution
        % and offset it based on the lane number.  The range will be +/- 10
        % around a nominal speed.  The function to determin the speed is 55
        % + ((lane - 1) * 10)
        nominalSpeed = 55 + ((lane - 1) * 10);
        
        % Range is +/- 1 0 around the nominal value
        loSpeed = nominalSpeed - 10;
        hiSpeed = nominalSpeed + 10;
        v.initialVelocity = loSpeed + (hiSpeed - loSpeed) * rand();
        
        % We will no assume that a certain percentange of a nominal
        % distribution of vehicles want to join a caravan.  This percentage
        % is a constant (caravanReqests);
        if (rand() < caravanThreshold)
            v.wantsCaravan = true;
        end
    end
   end
end

