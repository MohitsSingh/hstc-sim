classdef VehicleMgr <handle
    %Vehcile Manager class
    %
    
    properties
        struct
        lanes = 0;
        allVehicles = Vehicle.empty;    % All vehicles in the system.
        highway;                        % The structure of the highway is
                                        % that column 1 is the index info
                                        % allVehicles, column 2 is the
                                        % distance from the beginning of
                                        % the highway of that vehicle.
                                        % Column 3 is the lane that vehicle
                                        % is in.
                                        % There may be zeros within the array
    end
    
    methods
        % Constructor - Requires number of lanes and timesteps.
        function obj = VehicleMgr(lanesIn)
            obj.lanes = lanesIn;
            obj.highway = zeros(0, 3);
        end
        
        % Function to add vehicles
        function obj = AddVehicles(obj, newVehicles)
            for i=1:length(newVehicles)
                numCars = length(obj.allVehicles)+1; %1 is base index of arrays
                if numCars > 1
                    for j = numCars-1:-1:1
                        if obj.allVehicles(j).posY >= newVehicles(i).posY
                            obj.allVehicles(j+1) = obj.allVehicles(j);
                        else
                            break;
                        end
                    end
                else 
                    j=1;
                end
                %this will be either the end of the array or the insertion
                %point
                obj.allVehicles(j) = newVehicles(i);
                
            end
            
           % After adding the vehicles, rebuild the array that represents
           % the highway
           obj = BuildHighway(obj);
        end

        
        function obj = TimeStep(obj, timeDelta)
            % First do the caravan lane
            % Starting at the end of the highway and moving towards the
            % beginning
            caravanLane = obj.lanes;
            for i = length(obj.allVehicles) :-1: 1
                if (obj.highway(i, 2) == caravanLane)
                    index = obj.highway(i, 1);
                    v = obj.allVehicles(index);
                    v = Advance(v, timeDelta, obj.highway, i);
                    obj.allVehicles(index) = v;
                end
            end
            
            % Now do the rest of the lanes.
            for i = length(obj.allVehicles) :-1: 1
                if ((obj.highway(i, 2) ~= caravanLane) && (obj.highway(i, 2) ~= 0))
                    index = obj.highway(i, 1);
                    v = obj.allVehicles(index);
                    v = Advance(v, timeDelta, obj.highway, i);
                    obj.allVehicles(index) = v;
                end
            end
            
            % Now rebuild the highway.
            obj = BuildHighway(obj);
        end
        
        function obj = BuildHighway(obj)
            % Get a new highway that is more than we will need.  This will
            % allow us to add without incurring overhead of adding
            obj.highway = zeros(length(obj.allVehicles), 3);
            % Now re-build the highway.  It consists of the index, location
            % and lane for every vehicle
%            temp = zeros(length(obj.allVehicles), 3);
            for v = 1:length(obj.allVehicles)
                obj.highway(v, 1:3) = [v, obj.allVehicles(v).lane, obj.allVehicles(v).posY];
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
        function [ distance ] = DistanceAhead( obj )
            %DISTANCEBETWEEN Summary of this function goes here
            %   Detailed explanation goes here
             vm = VehicleMgr.getInstance;
             
             distance = -1; % Steven's crude hack to make this work for now (distance isn't otherwise set if no vehicles present)

            %find nearest car in front of me, in my lane
            %posX = myposX, posY > my Posy
            numCars = length(vm.allVehicles);
            for i = 1:numCars-1
                if vm.allVehicles(i) == obj %find my car
                    if ~isempty(vm.allVehicles(i+1)) 
                        distance =  (vm.allVehicles(i+1).posY - vm.allVehicles(i).posY );
                    else
                        %no one in front of me
                        distance = 9999;
                    end
                end
            end
           
        end
    end
    methods (Static)
        function managerObj = getInstance
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = VehicleMgr(3);
            end
            managerObj = localObj;
        end
    end      
end

