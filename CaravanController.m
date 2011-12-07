classdef CaravanController  <handle
    
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    %todo handle only vehicles in my zone(so make me support zones)
    
    properties
        assignedCars            ; % a array  of structures
                                  % .vehicle object
                                  % .caravan
                                  % .state  - waitFor15, spread caravan,
                                  % insert car, restore caravan
        removingCars            ; % a array  of structures
                                  % .vehicle object
                                  % .caravan
                                  % .state  - spread caravan,
                                  % extract car, restore caravan
        extSpreadCaravan           = 1;
        extExtractCar              = 2;
        extWaitForCarinPosition    = 3;
        extRestoreCaravan          = 4;

        waitFor15               = 1;
        spreadCaravan           = 2;
        waitFor5                = 3;
        waitForCarinPosition    = 4;
        insertCar               = 5;
        restoreCaravan          = 6;
        
        allCaravans             = Caravan.empty;
        
%         numAssignedCars         = 0;
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
            %todo insert in ordered list by destination
            newCaravan.id = length(obj.allCaravans)+1;
            obj.allCaravans(length(obj.allCaravans)+1) = newCaravan;
            
            % Sort caravans by position (change ascend to descend if
            % desired)
            [~,idx]=sort([obj.allCaravans.allVehicles(1).posY], 'ascend');
            obj.allCaravans = obj.allCaravans(idx);
        end
        
        function [isIn, offset, gapCenter] = IsCarInGap( obj, whichCar )
            [gapFront, gapBack] = obj.assignedCars(whichCar).caravan.GetGap();
            [carFront,carBack ] = obj.assignedCars(whichCar).vehicle.GetDims();

            isIn = false;
            offset = 0.0;
            gapCenter = (gapFront+gapBack)/2;
            if( gapFront > carFront) && ( carBack >gapBack)
                isIn = true;
            else
                offset =  (carFront+carBack)/2 - gapCenter;
                disp(offset*5280);
            end
        end
            
        
        %add vehicle to list of cars and caravans to be tracked.  
        %keep track of which car and which caravan
        %clear the wants caravan flag
        function obj = AssignCarToCaravan(obj,v,whichCaravan)
            %add to the list
            newNdx = length(obj.assignedCars) + 1;
            obj.assignedCars(newNdx).vehicle = v;
            obj.assignedCars(newNdx).caravan = whichCaravan;
            obj.assignedCars(newNdx).state   = obj.waitFor15;
            
%             obj.numAssignedCars = obj.numAssignedCars+1;
            
            %remove car from list of cars wanting a caravan
            v.wantsCaravan      = false;
            v.joiningCaravan    = true;
            %todo...be smarter about when to move the car over to the merge lane
            v.moveToMergeLane   = true; %tell the car to move over
        end
        
        %add vehicle to list of cars and caravans to be tracked.  
        %keep track of which car and which caravan
        %clear the wants caravan out of caravan flag
        function obj = RemoveCarFromCaravan(obj,v)
            %confirm car in the list of caravans
            whichCaravan = Caravan.empty;
            for i = 1:length(obj.allCaravans)
                if obj.allCaravans(i).id == v.caravanNumber
                    whichCaravan = obj.allCaravans(i);
                    break;
                end
            end
            if ~isempty(whichCaravan)
                %add to the list
                newNdx = length(obj.removingCars) + 1;
                obj.removingCars(newNdx).vehicle = v;
                obj.removingCars(newNdx).caravan = whichCaravan;
                obj.removingCars(newNdx).state   = obj.extSpreadCaravan;

                %issue extract request to caravan
                extractVid = v.id;
                whichCaravan.ExtractRequest(extractVid);   

                %remove car from list of cars wanting a caravan
                v.wantsOutOfCaravan = false;
                v.leavingCaravan    = true;
            end
        end
        
        function acceleration = CalculateAccelerationFromIntersectionPoint(obj,c,v,t)
            cv = c.allVehicles(c.gapLocation+1);
            intCaravanPosition = cv.posY + cv.velocity * t;
            acceleration = 2*(intCaravanPosition - v.posY - v.velocity*t) / t^2;
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
                            %todo set speed and following distance
                        end
                    end
                elseif v.wantsOutOfCaravan
                    RemoveCarFromCaravan(obj,v)
                end
            end
            
            %update the caravan position and velcoity information
            obj.allCaravans.Update();
            
            %now work on getting cars to their caravan
            %tell the car when to move to caravan merge lane
            %tell caravan when separate to Insert car
            %tell car when to insert
            %remove car from assigned list
            numA = length(obj.assignedCars);
            for i=1:numA
                
                %a simple statemachine is used for each caravan /car pair
                %when the carvan is 15 seconds away, issue a caravan insert
                %command
                %when the caravan is along side the vehicle, tell the
                %vehicle to move in
                %when the vehcile is in position, restore speed of lead
                %vehicles
                if obj.assignedCars(i).state == obj.waitFor15
                    %if the caravan is 15 seconds away, tell the lead cars to
                    %speedup
                    timeToMeetingInHours = (obj.assignedCars(i).vehicle.posY - obj.assignedCars(i).caravan.GetEndPoint()) ...
                                    / (obj.assignedCars(i).caravan.velocity - obj.assignedCars(i).vehicle.velocity);
                    if timeToMeetingInHours < 15 / 3600 %15seconds
                        
                        obj.assignedCars(i).vehicle.targetVelocity =  ...
                             obj.assignedCars(i).caravan.velocity-1;
                        obj.assignedCars(i).vehicle.targetRate =  ...
                             (obj.assignedCars(i).caravan.velocity - ...
                             obj.assignedCars(i).vehicle.velocity) / (15)  ;

                        obj.assignedCars(i).caravan.InsertRequest(2);
                        obj.assignedCars(i).state = obj.spreadCaravan;
                    end

                elseif obj.assignedCars(i).state == obj.spreadCaravan
                    if obj.assignedCars(i).caravan.GapSize() > 25.0 / 5280.0 ... 
                        obj.assignedCars(i).state = obj.waitFor5;
                        %tell the lead cars to go back to normal speed
                        obj.assignedCars(i).caravan.ResumeSpeed();
                    end
                    
                elseif obj.assignedCars(i).state == obj.waitFor5
                    %if the caravan is 5 seconds away, tell the lead cars to
                    %speedup
                    timeToMeetingInHours = (obj.assignedCars(i).vehicle.posY - obj.assignedCars(i).caravan.GetInsertionPoint()) ...
                                    / (obj.assignedCars(i).caravan.velocity - obj.assignedCars(i).vehicle.velocity);
                    if timeToMeetingInHours < 5 / 3600 %5seconds
                        % adjust target car speed 
                        intPoint = obj.assignedCars(i).caravan.GetInsertionPoint()...
                                + obj.assignedCars(i).caravan.velocity * SimulationSetup.SimTimeStep /3600;
                        [inGap, offset, gapCenter] = obj.IsCarInGap(i);
                        assert(offset > -100 /5280);  %behind by 100 feet
                        if  inGap
                            obj.assignedCars(i).state = obj.insertCar;
                        else
                            %todo..this should acutally control
                            %acceleration
                            obj.assignedCars(i).vehicle.targetVelocity =  ...
                                (intPoint - obj.assignedCars(i).vehicle.posY) / (SimulationSetup.SimTimeStep / 3600);
                            obj.assignedCars(i).vehicle.velocity =  ...
                                obj.assignedCars(i).vehicle.targetVelocity;
                        end
                    end
                   
                elseif obj.assignedCars(i).state == obj.insertCar
                    %TODO undo instantaneous acceleration
                    obj.assignedCars(i).vehicle.velocity = obj.assignedCars(i).caravan.velocity;
                    obj.assignedCars(i).vehicle.targetVelocity = obj.assignedCars(i).vehicle.velocity;
                    obj.assignedCars(i).vehicle.moveToCaravanLane = true;
                    obj.assignedCars(i).vehicle.caravanSpeed = obj.assignedCars(i).caravan.velocity;
                    obj.assignedCars(i).vehicle.caravanPosition = ...
                        obj.assignedCars(i).caravan.GetInsertionPoint() + ...
                        + obj.assignedCars(i).caravan.velocity * SimulationSetup.SimTimeStep /3600+...
                        obj.assignedCars(i).vehicle.length / 2.0;
                    obj.assignedCars(i).state = obj.restoreCaravan;
                    
                elseif obj.assignedCars(i).state == obj.restoreCaravan
                    if obj.assignedCars(i).vehicle.lane == vm.lanes; %in caravan lane?
                        obj.assignedCars(i).caravan.CloseRanks();
                        
                        %update the caravan and vehicle flags
                        obj.assignedCars(i).vehicle.caravanNumber = ...
                            obj.assignedCars(i).caravan.id;
                        obj.assignedCars(i).vehicle.joiningCaravan = false;
                        
                        %todo update caravan veihcile array
                        %       remove assigned vehicle list item
                    end
                end
                    
                if obj.assignedCars(i).caravan.GetInsertionPoint > obj.assignedCars(i).vehicle.posY 
                    %SimulationSetup.Pause = true;
                end
            end
            

            % REMOVAL STATE MACHINE
            %now work on getting cars out of their caravan
            numR = length(obj.removingCars);
            for i=1:numR
                
                %a simple statemachine is used for each caravan /car pair
                %when the carvan is 15 seconds away, issue a caravan insert
                %command
                %when the caravan is along side the vehicle, tell the
                %vehicle to move in
                %when the vehcile is in position, restore speed of lead
                %vehicles
                if obj.removingCars(i).state == obj.extSpreadCaravan
                    if obj.removingCars(i).caravan.GapSize() > 25.0 / 5280.0 ... 
                        obj.removingCars(i).state = obj.extWaitForCarinPosition;
                        obj.removingCars(i).vehicle.moveToMergeLane = true;
                        %tell the lead cars to go back to normal speed
%                         obj.removingCars(i).caravan.ResumeSpeed();
                    end
                    
                elseif obj.removingCars(i).state == obj.extWaitForCarinPosition
                    if obj.removingCars(i).vehicle.lane == vm.lanes; %in caravan lane?
                        obj.removingCars(i).caravan.CloseRanks();
                        
                        %update the caravan and vehicle flags
                        obj.removingCars(i).vehicle.caravanNumber = ...
                            obj.removingCars(i).caravan.id;
                        obj.removingCars(i).vehicle.joiningCaravan = false;
                        
                        %todo update caravan veihcile array
                        %       remove assigned vehicle list item
                    end
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

