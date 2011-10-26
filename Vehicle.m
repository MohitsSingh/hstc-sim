classdef Vehicle
    %VECHICLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id = 0;
        posX = 0.0; %miles?
        posY = 0.0; %miles
        velocity = 0.0; %mph
        acceleration = 0.0; %ft/s/s
        entryRamp =0;
        destinationRamp = 0;
        dragCoefficient= 0.4;
        wantsCaravan = false;
        caravanNumber = 0;  %might be redundant...can lookup in caravan
        caravanPosition = 0;
        fuelEconomy = 20.0; %mpg
        
        
        
    end
    
    methods
    end
    
end

