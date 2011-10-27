classdef Driver
    %DRIVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function action = Agent(obj, car)
            actSpeed = car.velocity;
            desiredSpeed = car.targetVelocity;
            distanceToCarInFront = DistanceBetween(car); %miles 

            if distanceToCarInFront < 3 * actSpeed *5280 /3600 % 3 second rule
                if VehicleManager.IsLeftClear(car)
                    car.MoveLeft();
                else
                    if VehicleManager.IsRightClear(car)
                        car.MoveRight();
                    else
                        car.SlowDown(1.0);  %0 to 100% of deceleration rate
                    end
                end
                    
            else
                if abs( (actSpeed-desiredSpeed)/desiredSpeed) < 0.05 %within 5 percent of desired speed
                    %everything is copacetic
                    action = 0;
                else
                    %increase speed
                    action = 1;
                end
            end
            
        end
        
    end
    
end

