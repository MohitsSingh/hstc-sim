classdef VehicleMgr <handle
    %Vehcile Manager class
    %
    
    properties
        lanes = 0;
        travelLanes = 0;
        currentVehicles = Vehicle.empty;    % All vehicles in the system.
        highway;                        % The structure of the highway is
                                        % column 1 is the index into currentVehicles
                                        % column 2 is the lane that vehicle is in
                                        % column 3 is the distance from the beginning of
                                        % the highway of that vehicle.
                                        % column 4 is the id of the vehicle
                                        % There may be zeros within the array
        exitedVehicles = Vehicle.empty; % Those vehicles that have left the highway.
    end
    
    methods
        % Constructor - Requires number of lanes and timesteps.
        %don;t call this directly...use getInstance instead
        function obj = VehicleMgr(lanesIn)
            obj.lanes = lanesIn;
            obj.travelLanes = lanesIn - 2;      % Assume caravan lanes exist
            obj.highway = zeros(0, 4);
        end
        
        % Function to add vehicles
        function obj = AddVehicles(obj, newVehicles)
            % Append to the all vehicles array
            obj.currentVehicles = [obj.currentVehicles newVehicles];
            % After adding the vehicles, rebuild the array that represents
            % the highway
            obj = BuildHighway(obj);
        end

        
        function obj = TimeStep(obj, timeDelta)
            % First do the caravan lane
            % Starting at the end of the highway and moving towards the
            % beginning
            caravanLane = obj.lanes;
%             disp('CARAVAN LANES');
            for i = size(obj.highway, 1) :-1: 1
                if (obj.highway(i, 2) == caravanLane)
                    index = obj.highway(i, 1);
                    v = obj.currentVehicles(index);
                    v = Advance(v, timeDelta, obj.highway, i);
                    
                    %update highway array so that cars behind can see an
                    %accurate position
                    obj.highway(i, 3) = v.posY;
                    obj.currentVehicles(index) = v;
                end
            end
%             disp('Other LANES');
            % Now do the rest of the lanes.
            for i = size(obj.highway, 1) :-1: 1
                if ((obj.highway(i, 2) ~= caravanLane) && (obj.highway(i, 2) > 0))
                    index = obj.highway(i, 1);
                    v = obj.currentVehicles(index);
                    v = Advance(v, timeDelta, obj.highway, i);
                    %update highway array so that cars behind can see an
                    %accurate position
                    obj.highway(i, 3) = v.posY;
                    obj.currentVehicles(index) = v;
                end
            end
            
            % Now tell the ones in lane zero that they can enter.
            % Current restriction is that only one on a ramp at a time.
            for i = size(obj.highway, 1) :-1: 1
                if (obj.highway(i, 2) == 0)
                    index = obj.highway(i, 1);
                    v = obj.currentVehicles(index);
                    v = Enter(v, timeDelta, obj.highway, i);
                    obj.currentVehicles(index) = v;
                end
            end
            
            % Now for all those from currentVehicles that have exited,
            % move them to exitedVehicles.
            for v = length(obj.currentVehicles):-1:1
                if (obj.currentVehicles(v).lane < 0)
                    obj.exitedVehicles = [obj.exitedVehicles obj.currentVehicles(v)];
                    obj.currentVehicles(v) = [];
                end
            end
            
            % Now rebuild the highway.
            obj = BuildHighway(obj);
        end
        
        function obj = BuildHighway(obj)
            % Get a new highway that is more than we will need.  This will
            % allow us to add without incurring overhead of adding
            obj.highway = zeros(length(obj.currentVehicles), 4);
            % Now re-build the highway.  It consists of the index, location
            % and lane for every vehicle
            for v = 1:length(obj.currentVehicles)
                assert(obj.currentVehicles(v).lane > 0, 'lane = %d\n', obj.currentVehicles(v).lane);
                obj.highway(v, 1:4) = [v, obj.currentVehicles(v).lane, obj.currentVehicles(v).posY, ...
                                       obj.currentVehicles(v).id];
            end
            
            % Now sort the rows by position
            obj.highway = sortrows(obj.highway, 3);
        end
    end
    
    
    %what follows is john's attempt to completely ruin brian's code.
    %really, it's just a merging of the old and real vehicle manager
    %until we find the real place for this code to live
   methods(Static)
        function isOk = IsLeftClear(car)
            vm = VehicleMgr.getInstance;
            isOk = false;
        end
        function isOk = IsRightClear(car)
            vm = VehicleMgr.getInstance;
            isOk = false;
        end 
        function isLane = IsCaravanLane(lane)
            vm = VehicleMgr.getInstance;
            isLane = ~VehicleMgr.IsTravelLane(lane);
        end
        function isLane = IsTravelLane(lane)
            vm = VehicleMgr.getInstance;
            isLane = (lane > 0) && (lane <= vm.travelLanes);
        end
        
        %Function to move vehicles around on the highway AFTER they have
        %moved and done a lane change.  This method will find the correct
        %place for the vehicle to be.  Since we process from the furthest
        %to the end, this won't disturb any other processing that has been
        %done.
        function LaneChange (currentIndex)
            vm = VehicleMgr.getInstance;
            vehicleToMove = vm.highway(currentIndex, 1);
            idMoving = vm.currentVehicles(vm.highway(currentIndex, 1)).id;
            myDistance = vm.currentVehicles(vehicleToMove).posY;
            i = currentIndex + 1;
            while (i <= size(vm.highway,1)) && (myDistance > vm.currentVehicles(vm.highway(i, 1)).posY)
                vm.highway(i - 1, 1) = vm.highway(i, 1);
                vm.highway(i - 1, 2) = vm.highway(i, 2);
                vm.highway(i - 1, 3) = vm.highway(i, 3);
                vm.highway(i - 1, 4) = vm.highway(i, 4);
                i = i + 1;
            end
            if (i > size(vm.highway, 1))
                vm.highway(i - 1, 1:4) = [vehicleToMove, vm.currentVehicles(vehicleToMove).lane, ...
                                          vm.currentVehicles(vehicleToMove).posY,...
                                          vm.currentVehicles(vehicleToMove).id];
            else
                vm.highway(i, 1:4) = [vehicleToMove, vm.currentVehicles(vehicleToMove).lane, ...
                                      vm.currentVehicles(vehicleToMove).posY,...
                                      vm.currentVehicles(vehicleToMove).id];
            end
        end
        
        function [ distance ] = DistanceAhead( obj )
            %DISTANCEBETWEEN Summary of this function goes here
            %   Detailed explanation goes here
             vm = VehicleMgr.getInstance;
             
             distance = -1; % Steven's crude hack to make this work for now (distance isn't otherwise set if no vehicles present)

            %find nearest car in front of me, in my lane
            %posX = myposX, posY > my Posy
            numCars = length(vm.currentVehicles);
            for i = 1:numCars-1
                if vm.currentVehicles(i) == obj %find my car
                    if ~isempty(vm.currentVehicles(i+1)) 
                        distance =  (vm.currentVehicles(i+1).posY - vm.currentVehicles(i).posY );
                    else
                        %no one in front of me
                        distance = 9999;
                    end
                end
            end
           
        end
    end
    methods (Static)
        function managerObj = getInstance(numLanes)
            persistent localObj
    
            if isempty(localObj) || ~isvalid(localObj)
                if nargin == 0
                    numLanes = 5;
                end
                localObj = VehicleMgr(numLanes);
            end
            managerObj = localObj;
        end
    end      
end

