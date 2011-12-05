classdef CaravanController  <handle
    
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    %todo handle only vehicles in my zone(so make me support zones)
    
    properties
        assignedCars            ;
        allCaravans             = Caravan.empty;
        
        numAssignedCars         = 0;
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
                    if (v.posY - obj.allCaravans(i).position < 30) ...
                        && (v.posY - obj.allCaravans(i).position > 20) ...
                        &&  (obj.allCaravans(i).destination - v.destination > 10)
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
        function [formCaravan, whichCars] = shouldIFormACaravan(obj,v)
            whichCars = [];
            formCaravan = false;
            
            vm = VehicleMgr.getInstance;
            
            numV = length(vm.currentVehicles);
            for i = 1 : numV
                currVeh = vm.currentVehicles(i);
                
                % ignore if already in a caravan, or me
                if currVeh.caravanNumber > 0 || v.id == currVeh.id 
                    continue;
                else
                    % TODO add some better criteria for similar
                    % destinations?
                    if abs(v.posY - currVeh.posY) <= 20 && ...
                            abs(v.destination - currVeh.destination) <= 5
                        whichCars = [whichCars currVeh];
                        
                        % Sort cars (sorted such that first in list has
                        % greatest posY)
                        [~,idx]=sort([whichCars.posY], 'descend');
                        whichCars = whichCars(idx);
                        
                        formCaravan = true;
                    end
                end
            end
        end
        
        function caravan = CreateACaravan(obj,whichCars)
            % Create a new caravan object
            caravan = Caravan.empty;
            
            % assign all cars to the Caravan
            for i=1:length(whichCars)
                 % tell car at the back of the new group to move into 
                 % caravan lane first in the list should be farthest back 
                 % (vehicles are put into list in ascending order)
                if i==length(whichCars)
                    whichCars(i).moveToCaravanLane = true;
                end
                
               AssignCarToCaravan(obj,whichCars(i), caravan); 
            end 
            
            AddCaravan(obj,caravan);
        end
        

        function obj = AddCaravan(obj,newCaravan)
            newCaravan.id = length(obj.allCaravans)+1;
            obj.allCaravans(length(obj.allCaravans)+1) = newCaravan;
            
            % Sort caravans by position (change ascend to descend if
            % desired)
            [~,idx]=sort([obj.allCaravans.allVehicles(1).posY], 'ascend');
            obj.allCaravans = obj.allCaravans(idx);
        end
        
        %add vehicle to list of cars and caravans to be tracked.  
        %keep track of which car and which caravan
        %remove car from the wants caravan list
        function obj = AssignCarToCaravan(obj,v,whichCaravan)
            %add to the list
            obj.assignedCars(obj.numAssignedCars+1).vehicle = v;
            obj.assignedCars(obj.numAssignedCars+1).caravan = whichCaravan;
            
            obj.numAssignedCars = obj.numAssignedCars+1;
            
            %remove car from list of cars wanting a caravan
            v.wantsCaravan      = false;
            v.joiningCaravan = true;
            %todo...be smarter about moving the car over to the merge lane
            v.moveToMergeLane   = true; %tell the car to move over
        end
        
        function obj = Update(obj)
            global SimulationSetup
            vm = VehicleMgr.getInstance;
            
            %first find cars that need a caravan
            numV = length(vm.currentVehicles);
            for i = 1 : numV
                v = vm.currentVehicles(i);
                if v.wantsCaravan
                    [found,availC] = obj.isThereASuitableCaravan(v);
                    if found
                        obj.AssignCarToCaravan(v, availC);
                    else
                        [formCaravan,whichCars] =obj.shouldIFormACaravan(v);
                        if formCaravan
                            CreateCaravan(whichCars);
                        end
                    end
                end
            end
            
            obj.allCaravans.Update();
            
            %now work on getting cars to their caravan
            %tell the car when to move to caravan merge lane
            %tell caravan when separate to Insert car
            %tell car when to insert
            %remove car from assigned list
            for i=1:obj.numAssignedCars
                 if obj.assignedCars(i).caravan.position > obj.assignedCars(i).vehicle.posY 
                     SimulationSetup.Pause = true;
                 end
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

