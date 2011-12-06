classdef Caravan < hgsetget % subclass hgsetget
    %CARAVAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id = 0;
        maxSpeed                = 90.0;
        minVehicleSpacing       = 3.0 / 5280.0; % in miles
        destination             = 0.0; %to where is it going?
        position                = 0.0; %where is it now?
        velocity                = 0.0;
        maxSize                 = 21;
        isAbleToTakeNewCars     = true;
        insertLocation          = 0;
        allVehicles             = Vehicle.empty;
        
    end
    
    methods
        
        function obj = Update(obj)
            obj.position = obj.allVehicles(1).posY;
            obj.velocity = obj.allVehicles(1).velocity;
        end

        function sizeOfGap = GapSize(obj)
            sizeOfGap = obj.allVehicles(obj.insertLocation).posY - ...
                obj.allVehicles(obj.insertLocation+1).posY ;
        end
        function [gapFront,gapBack] = GetGap(obj)
            gapFront = obj.allVehicles(obj.insertLocation).posY - ...
                obj.allVehicles(obj.insertLocation).length - ...
                obj.minVehicleSpacing;

            gapBack = obj.allVehicles(obj.insertLocation+1).posY + ...
                obj.minVehicleSpacing;
        end
        
        function midPoint = GetMidPoint(obj)
            cvFront = obj.allVehicles(1).posY;

            cvBack = obj.allVehicles(length(obj.allVehicles)).posY + ...
                obj.allVehicles(length(obj.allVehicles)).length;
            midPoint = (cvFront + cvBack)/2.0;
        end          
        function endPoint = GetEndPoint(obj)
            endPoint = obj.allVehicles(length(obj.allVehicles)).posY + ...
                obj.allVehicles(length(obj.allVehicles)).length;
        end          

        function insertionPoint = GetInsertionPoint(obj)
            if obj.insertLocation == 0
                insertionPoint = obj.allVehicles(1).posY;
            else
                gapFront = obj.allVehicles(obj.insertLocation).posY - ...
                    obj.allVehicles(obj.insertLocation).length - ...
                    obj.minVehicleSpacing;

                gapBack = obj.allVehicles(obj.insertLocation+1).posY + ...
                    obj.minVehicleSpacing;
                insertionPoint = (gapFront + gapBack)/2.0;
            end
        end          
        
        %location = 1 HEAD
        %location = -1 TAIL
        %location = 2..N this vehcile is the new one at that location
        function obj = InsertRequest(obj,location)
            obj.insertLocation = location;
            obj.allVehicles(location+1).insertMode = true;
            % send a message to all cars behind insertion point to
            % slow down 2 mph.   All cars in front of point  to speed up 2mph
            for i = 1 : obj.insertLocation
                obj.allVehicles(i).targetVelocity   = obj.allVehicles(i).targetVelocity + 2.0;
                obj.allVehicles(i).targetRate       = 0.2;
            end
        end
        
        function obj = ResumeSpeed(obj)
            % send a message to all cars behind insertion point to
            % slow down 2 mph.   All cars in front of point  to speed up 2mph
            for i = 1 : obj.insertLocation
                obj.allVehicles(i).targetVelocity = obj.maxSpeed;
            end
        end

        function obj = CloseRanks(obj,location)
            % send a message to all cars to return to follow mode
            for i = 1 : length(obj.allVehicles)
                obj.allVehicles(i).insertMode = false;
            end
        end
        
        
        %assumes that new veichle is added to end of list.   For now
        %this is used to initalize a caravan before the simulation starts
        %running
        function obj = AddToVehicleList(obj,v)
            %find nearest car in front of me, in my lane
            %posX = myposX, posY > my Posy
            numCars = length(obj.allVehicles);
            numCars = numCars + 1 ; 
            obj.allVehicles(numCars) = v;
          
            
            %update position and destination 
            obj.position = obj.allVehicles(1).posY; %lead car
            if v.destination > obj.destination      %car going the farthest
                obj.destination  = v.destination ;   
            end
                
        end
    end
end

