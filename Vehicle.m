classdef Vehicle < hgsetget % subclass hgsetget
    %VECHICLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id              = 0;
        lane            = 0.0; %miles?
        posY            = 0.0; %miles
        velocity        = 0.0; %mph
        acceleration    = 3.0; %ft/s/s 2-20ft/s/s
        deceleration    = -1.5; %ft/s/s
        
% http://physics.info/acceleration/        
% Automotive Acceleration (g) 1g = 32ft/s/s
% event         typical car 	sports car 	F-1 race car 	large truck
% starting      0.3–0.5         0.5–0.9 	1.7             < 0.2
% braking       0.8–1.0         1.0–1.3 	2               ~ 0.6
% cornering 	0.7–0.9         0.9–1.0 	3               ??        

        entryRamp       = 0;
        destinationRamp = 0;
        
        destination     = 0;    %in miles.
        
        dragCoefficient = 0.4;
        wantsCaravan    = false;
        caravanNumber   = 0;  %might be redundant...can lookup in caravan
        caravanPosition = 0;
        fuelEconomy     = 20.0; %mpg
        
        %john variables
        preferredSpeed  = 55;    %45, 55, 65 +-5mph gaussian
                                %randomize for 1/2/3
                                %randomize for spread
        initialVelocity = 0;    %may be set to desired speed +- if
                                %we are populating a roadway for initial
                                %conditions
        targetVelocity  = 0;    % how fast do we want to be going
        targetRate      = 0;    % how fast do we want to change our speed
        
        drv             = Driver;
                                
    end
    
    methods
        function [pos,vel,acc] = Advance(obj,deltaTinSeconds)
             maxDelta = obj.targetRate *3600 / 5280 *deltaTinSeconds; %convert from ft/s/s to m/h/s
            obj.velocity = min(max( obj.targetVelocity,obj.velocity-maxDelta),obj.velocity+maxDelta) ;
            obj.posY = obj.posY + deltaTinSeconds / 3600 * obj.velocity; %convert seconds to hours for math
            pos = obj.posY;
            vel = obj.velocity;
            acc = obj.targetRate;
            
            obj.drv.Agent(obj);
            
        end
        
        function  obj = SlowDown(obj,howHard)
            maxDelta = howHard * obj.deceleration *3600 / 5280; %convert from ft/s/s to m/h/s
            %maxDelta = howHard * obj.deceleration *3600 / 5280 *deltaTinSeconds; %convert from ft/s/s to m/h/s
            obj.velocity = min(max( obj.targetVelocity,obj.velocity-maxDelta),obj.velocity+maxDelta) ;
        end
        
        
    end

   methods (Static)
%       function num = getEmpNumber
%          num = queryDB('LastEmpNumber') + 1;
%       end
   end
    
end

