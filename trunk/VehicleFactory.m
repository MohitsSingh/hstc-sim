classdef VehicleFactory
    %VEHICLEFACTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        vehicleParameters
    end
    
    methods
        function x = readConfigFile(obj,filename)
            load 'vehicles.dat'  -mat
            obj.vehicleParameters = vehicleParameters;
            
        end % readConfigFile method

        function nv = createVehicle(obj,type)
            if isa(type, 'char') 
                %name of vehicle type
                fprintf('Type requested %s\n', type);
                
                %find vehicle by name
                %create a new vehicle with arrtibutes
                for i= 1:size(obj.vehicleParameters)
                    disp obj.vehicleParameters(i).name
                end
                
            else
                %0 = randomize, else index of vehicle
                if type == 0
                    disp 'Random Vehicle'
                else
                    fprintf('Type requested Index %d\n', type);
                end
                
            end 
                
        end % createVehicle method
        
        
    end
    
end

