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
        
        %Minimum distance between cars NOT in caravan
        minNonCaravanDistance = 0.005681 % 30 feet in miles.
        
        %Minimum distance between cars in caravan
        minCaravanDistance = 0.0005681 % 3 feet in miles.
                                
    end
    
    methods
        function pos = GetNewPos(obj, deltaTinSeconds)
            maxDelta = obj.targetRate *3600 / 5280 *deltaTinSeconds; %convert from ft/s/s to m/h/s
            obj.velocity = min(max( obj.targetVelocity,obj.velocity-maxDelta),obj.velocity+maxDelta) ;
            pos = obj.posY + deltaTinSeconds / 3600 * obj.velocity; %convert seconds to hours for math
        end
        
        function closest = ClosestInLane(obj, lane, highway, startIndex)
            % Return the highway index of the closest vehicle in the lane
            % provided.  If nothing is close, return -1.
            closest = -1;
            i = startIndex + 1;
            while (i < size(highway, 1) && (closest  == -1))
                if (highway(i, 2) == lane)
                    closest = i;
                else
                    i = i + 1;
                end
            end
        end
        
        function obj = Advance(obj, deltaTinSeconds, highway, highwayIndex)
%            maxDelta = obj.targetRate *3600 / 5280 *deltaTinSeconds; %convert from ft/s/s to m/h/s
%            obj.velocity = min(max( obj.targetVelocity,obj.velocity-maxDelta),obj.velocity+maxDelta) ;
            % Get our proposed new position.  If someone is between our
            % current position and that position, move to just behind the
            % closest one.
            newPos = GetNewPos(obj, deltaTinSeconds);
%           vel = obj.velocity;
%           acc = obj.targetRate;
            
            % Now search for cars forward from our position and see if we
            % can go there.
            % Once we find the next one in our lane, we need to see where
            % it is.
            closest = ClosestInLane (obj, obj.lane, highway, highwayIndex);

            %If we don't have one, just advance to the calculated position.
            if (closest < 0)
                obj.posY = newPos;
            else
                % Now that we have the closest in our lane, see how far we can
                % advance.
                disp('Have a car in front');
                inFrontPos = highway(closest, 3);
                if (inFrontPos > (newPos + obj.minNonCaravanDistance))
                    obj.posY = newPos;
                else
                    % Can only advance so far this time.
                    newPos = inFrontPos - obj.minNonCaravanDistance;
                    % Complain if we backup
                    assert (newPos > obj.posY, 'Car did NOT advance [oldPos = %f, newPos = %f]',...
                            obj.posY, newPos);
                    obj.posY = newPos;
                end
            end
            obj.drv.Agent(obj);
        end
        
        function  obj = SlowDown(obj,howHard)
            maxDelta = howHard * obj.deceleration *3600 / 5280; %convert from ft/s/s to m/h/s
            %maxDelta = howHard * obj.deceleration *3600 / 5280 *deltaTinSeconds; %convert from ft/s/s to m/h/s
            obj.velocity = min(max( obj.targetVelocity,obj.velocity-maxDelta),obj.velocity+maxDelta) ;
        end
        
        
        function obj = Enter(obj,deltaTinSeconds, highway, highwayIndex)
            % Get the closest car in lane 1 and see if we can enter.
            entryPoint = obj.posY;
            newPos = getNewPos(object, deltaInSeconds);
            closest = ClosestInLane (1, highway, highwayIndex);
            if (closest < 0)
                obj.lane = 1;
            else
                disp('Have a car in front');
                inFrontPos = highway(closest, 3);
                if (inFrontPos > (newPos + obj.minNonCaravanDistance))
                    obj.posY = newPos;
                    obj.lane = 1;
                else
                    % Can only advance so far this time.
                    newPos = inFrontPos - obj.minNonCaravanDistance;
                    % if we can't advance at all (newPos <= current), stay
                    % in 0.
                    if (newPos > obj.posY)
                        obj.posY = newPos;
                        obj.lane = 1;
                    end
                end
            end
        end
        
    end

        
   methods (Static)
%       function num = getEmpNumber
%          num = queryDB('LastEmpNumber') + 1;
%       end
   end
    
end

