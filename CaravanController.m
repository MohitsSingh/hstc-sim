classdef CaravanController  <handle
    
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    %todo handle only vehicles in my zone(so make me support zones)
    
    properties
        assignedCars = Vehicle.empty;
        allCaravans = Caravan.empty;
    end
    
    methods
        %determine if there is a suitable caravan for the car
        %a suitable caravan is within 20 miles behind the current car, 
        %and has a destination at least
        %CaravanControllerSetup.MinCaravanDistance ahead
        function [wasFound,availableCaravan] = isThereASuitableCaravan(obj, v)
            %global CaravanControllerSetup;
            
            % for allCaravans is there one close enough that is able to take
            % more cars
            numCaravans = length(obj.allCaravans);

            availableCaravan    = Caravan.empty;
            wasFound            = false;
            
            for i=1:numCaravans
                if obj.allCaravans(i).isAbleToTakeNewCars
                    %todo improve the distance calculations...maybe use
                    %time?
                    if (v.posY - obj.allCaravans(i).position > 20) ...
                        &  (obj.allCaravans(i).destination - v.destination > 10)
                        availableCaravan    = obj.allCaravans(i);
                        wasFound            = true;
                        break;
                    end
                end
            end
        end
        
        %check for two cars that would make a good caravan
        %some criteria...
%         they have similar destinations
%         they are with 20miles of each other
        function [formCaravan, whichCars] = shouldIFormACaravan(obj)
            whichCars = empty;
            formCaravan = false;
        end
        
        %create a new caravan object
        %tell car at the back of the new group to move into caravan lane
        %Assign other cars to the caravan
        function obj = CreateACaravan(obj)
        end
        

        function obj = AddCaravan(obj,newCaravan)
            %todo insert by position
            obj.allCaravans(length(obj.allCaravans)+1) = newCaravan;
        end
        
        %add vehicle to list of cars and caravans to be tracked.  
        %keep track of which car and which caravan
        %remove car from the wants caravan list
        function obj = AssignCarToCaravan(obj,v)
            %add to the list
            %remove car from list of cars wanting a caravan
            v.wantsCaravan      = false;
            %todo...be smarter about moving the car over to the merge lane
            v.moveToMergeLane   = true; %tell the car to move over
        end
        
        function obj = Update(obj)
            vm = VehicleMgr.getInstance;
            
            %first find cars that need a caravan
            numV = length(vm.currentVehicles);
            for i = 1 : numV
                v = vm.currentVehicles(i);
                if v.wantsCaravan
                    [found,availC] = obj.isThereASuitableCaravan(v);
                    if found
                        obj.AssignCarToCaravan(v);
                    else
                        [formCaravan,whichCars] =obj.shouldIFormACaravan(v);
                        if formCaravan
                            CreateCaravan(whichCars);
                        end
                    end
                end
            end
            
            %now work on getting cars to their caravan
            %tell the car when to move to caravan merge lane
            %tell caravan when separate to Insert car
            %tell car when to insert
            %remove car from assigned list
            numAssignedCars = length(obj.assignedCars);
            for i=1:numAssignedCars
                
            end
            
        end
    end
    
    methods (Static)
        function CaravanControllerObj = getInstance
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = CaravanController;
            end
            CaravanControllerObj = localObj;
        end
    end
end
