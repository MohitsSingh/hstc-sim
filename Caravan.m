classdef Caravan < hgsetget % subclass hgsetget
    %CARAVAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id = 0;
        maxSpeed = 90.0;
        minVehicleSpacing = 3.0 / 5280.0; % in miles
        destination = 0.0; %to where is it going?
        maxSize = 21;
        allVehicles;
    end
    
    methods
        
        % Constructor - Requires number of lanes and timesteps.
        function obj = Caravan()
            %obj= Caravan.getInstance; This is bad...an endless loop
        end
        
        % Create a caravan by loading it from a filename
        function obj = Initialze(obj,filename)
        end
        
        %location = 1 HEAD
        %location = -1 TAIL
        %location = 2..N this vehcile is the new one at that location
        function obj = InsertRequest(obj,location)
        end
        
        %assumes that new veichle is added to end of list.   For now
        %this is used to initalize a caravan before the simulation starts
        %running
        function obj = AddToVehicleList(obj,id)
             cv = Caravan.getInstance;
             
            %find nearest car in front of me, in my lane
            %posX = myposX, posY > my Posy
            numCars = length(cv.allVehicles);
            numCars = numCars + 1 ; 
            cv.allVehicles(numCars) = id;
          
        end
    end
    methods (Static)
        function caravanObj = getInstance
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = Caravan;
            end
            caravanObj = localObj;
        end
    end      
end

