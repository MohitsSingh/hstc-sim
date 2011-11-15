classdef Driver
    %DRIVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function action = Agent(obj, car)
            actSpeed                = car.velocity;
            desiredSpeed            = car.targetVelocity;
            distanceToCarInFront    = VehicleMgr.DistanceAhead(car); %miles 

            if distanceToCarInFront < 3 * actSpeed / 3600 % 3 second rule (x mph for 3 seconds)
                if VehicleMgr.IsLeftClear(car)
                    car.MoveLeft();
                else
                    if VehicleMgr.IsRightClear(car)
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
                    %increase speed is the default behavior of the vehicle
%                     action = 1;
%                     car.SpeedUp(1.0);  %0 to 100% of deceleration rate
                end
            end
            
        end
        
    end
    
end

