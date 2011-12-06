classdef Vehicle < hgsetget % subclass hgsetget
    %VECHICLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id              = 0;
        lane            = 0;   %if lane is -1, not on highway.
        posY            = 0.0; %miles
        velocity        = 0.0; %mph
        acceleration    = 3.0; %ft/s/s 2-20ft/s/s
        deceleration    = -1.5; %ft/s/s
        fps2mph         = 3600 / 5280;
        length          = 13.0/5280.0; %13 feet in miles.   make all cars same length for now
        
% http://physics.info/acceleration/        
% Automotive Acceleration (g) 1g = 32ft/s/s
% event         typical car 	sports car 	F-1 race car 	large truck
% starting      0.3–0.5         0.5–0.9 	1.7             < 0.2
% braking       0.8–1.0         1.0–1.3 	2               ~ 0.6
% cornering 	0.7–0.9         0.9–1.0 	3               ??        

        entryRamp       = 0;
        destinationRamp = 10000.0;       % Set to high value by default.
        
        destination     = 0;    %in miles.
        
        dragArea        = 0.75;
        wantsCaravan    = false;
        joiningCaravan  = false;
        wantsOutOfCaravan    = false;
        moveToCaravanLane   = false;
        moveToMergeLane     = false;    %the caravan controller will tell us when to move
        insertMode          = false;
        caravanNumber   = 0;  %might be redundant...can lookup in caravan
        caravanPosition = 0;
        fuelEconomy     = 20.0; %mpg
        baseFuelEconomy = 20.0; %mpg
        
        %john variables
        preferredSpeed  = 55;    %45, 55, 65 +-5mph gaussian
                                %randomize for 1/2/3
                                %randomize for spread
        initialVelocity = 0;    %may be set to desired speed +- if
                                %we are populating a roadway for initial
                                %conditions
        targetVelocity  = 0;    % how fast do we want to be going
        targetRate      = 0;    % how fast do we want to change our speed
        
        drv             = Driver; %simulator of human agent
        accModule       = Acc;      %the computerized driver (no steering, though)
        
        % Statitics to collect for KPP4
        driveTime = 0.0;        % Time from entry to exit in seconds
        distanceTraveled = 0.0; % How far have we gone?  In miles
        
        %Minimum distance between cars NOT in caravan
        minNonCaravanDistance = 0.005681 % 30 feet in miles.
        
        %Minimum distance between cars in caravan
        minCaravanDistance = 0.0005681 % 3 feet in miles.
                                        
    end
   
    methods
        function pos = GetNewPos(obj, deltaTinSeconds)
            maxDelta = obj.targetRate *3600 / 5280 *deltaTinSeconds; %convert from ft/s/s to m/h/s
            obj.velocity = min(max( obj.targetVelocity,obj.velocity-maxDelta),obj.velocity+maxDelta) ;
            if obj.velocity < 0
                obj.velocity = 0;
            end
            pos = obj.posY + deltaTinSeconds / 3600 * obj.velocity; %convert seconds to hours for math
        end
        
        function [front,back] = GetDims(obj)
            front = obj.posY;

            back = obj.posY - obj.length;
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
            vm = VehicleMgr.getInstance;
            % Don't advance if we have exited.
            if (obj.lane < 0)
                return;
            end
            
            % Get our proposed new position.  If someone is between our
            % current position and that position, move to just behind the
            % closest one.
            
            % TODO add the checking for how far we should be allowed
            %   to move (maxPos)
            newPos = GetNewPos(obj, deltaTinSeconds);
%           vel = obj.velocity;
%           acc = obj.targetRate;

            % If we are at or beyond our destinationRamp, exit now.
            if (obj.posY >= obj.destinationRamp)
                % Exit by setting our lane to -1 and leaving.  On the next
                % go around, the VM will not put us on the highway.
                obj.lane = -1;
                % Save the distance travelled (just in case)
                obj.distanceTraveled = obj.posY;
                return;
            end

            if obj.moveToMergeLane == true
                % if we are not alread in the merger lane,
                % ask vm if we can move to the left safely %TODO
                mergeLane = vm.lanes -1 ;
                if highway(highwayIndex,2) == mergeLane %merge lane?
                    obj.moveToMergeLane = false;
                else
                    obj.lane = obj.lane + 1;
                    VehicleMgr.LaneChange(highwayIndex);
                end
            elseif obj.moveToCaravanLane == true
                %TODO account for lateral velocity 
                caravanLane = vm.lanes  ;
                if highway(highwayIndex,2) == caravanLane %caravan lane?
                    obj.moveToCaravanLane = false;
                else
                    obj.lane = caravanLane;
                    VehicleMgr.LaneChange(highwayIndex);
                end
            end
            
            
            % Now search for cars forward from our position and see if we
            % can go there.
            % Once we find the next one in our lane, we need to see where
            % it is.
            closest = ClosestInLane (obj, obj.lane, highway, highwayIndex);

            %If we don't have one, just advance to the calculated position.
            if (closest < 0)
                obj.posY = newPos;
                inFrontPos = -1; %for mpg calculation
            else
               
                    
                % Now that we have the closest in our lane, see how far we can
                % advance.
                inFrontPos = highway(closest, 3) - obj.length; %for now hardcode a car length TODO
                
                %if we are in a caravan, we can only move as far as the
                %tailend of the car in front of us minus the caravan
                %spacing
                if obj.caravanNumber ~= 0 || obj.joiningCaravan
                    %if we are the car that has something inserted in front
                    %of it, we need to follow a little further behind
                    if obj.insertMode == true
                        followDistance = 27/5280.0;
                    else
                        followDistance = obj.minCaravanDistance;
                    end
                    if obj.id == 11 && ~obj.joiningCaravan
                        obj.id = 11; %for making a breakpoint after car joins caravan
                    end
                    obj.posY = min(newPos, inFrontPos - followDistance);
                    if newPos > inFrontPos - followDistance
                        %todo should adjust velocity here.
                        obj.velocity = obj.velocity * (inFrontPos - followDistance) / newPos;
                        %TODO Add closing the gap to follow distance
                    end
                elseif (inFrontPos > (newPos + obj.minNonCaravanDistance))
                    % We can advance the entire way
                    obj.posY = newPos;
                else
                    %Don't let cars in caravan automatically change lanes
                    if obj.caravanNumber == 0 
                        % See if we can change lanes and still advance as far
                        % as we want.
                        newPosThisLane = inFrontPos - obj.minNonCaravanDistance;
                        [posInNewLane, newLane] = ChangeLanes(obj, highway, highwayIndex, newPos);
                        if ((newPosThisLane < posInNewLane) && (newLane > 0))
                            % We are changing lanes.  This means that we can
                            % advance the distance returned
                            if (newLane > 3)
                                fprintf(1, 'Car %d in lane %d\n', obj.id, newLane);
                            end
                            obj.lane = newLane;
                            obj.posY = posInNewLane;
                            VehicleMgr.LaneChange(highwayIndex);
                        else
                            % Can only advance so far this time in this lane.
                            % let's figure out how far
                            if  newPosThisLane < 0
                                newPosThisLane = 0;
                            end                    
                            % Complain if we backup
%                             if (newPosThisLane <obj.posY)
%                                 fprintf(1, 'posY: %f, inFrontPos: %f\n', obj.posY, inFrontPos);
%                                 fprintf(1, 'highwayIndex is: %d\n', highwayIndex);
%                                 fprintf(1, 'OBJ in highway (index: %d, lane: %d, dist: %f)\n',...
%                                         highway(highwayIndex, 1), highway(highwayIndex, 2), highway(highwayIndex, 3));
%                                 fprintf(1, 'closest is: %d\n', closest);
%                                 fprintf(1, 'closest in highway (index: %d, lane: %d, dist: %f)\n',...
%                                         highway(closest, 1), highway(closest, 2), highway(closest, 3));
%                                 fprintf(1, 'newLane: %d\n', newLane);
%                                 fprintf(1, 'posInNewLane: %f\n', posInNewLane);
%                                 for i=highwayIndex-3:closest+3
%                                     fprintf(1, 'Highway(%d) = (%d, %d, %f)\n', i, highway(i, 1), highway(i, 2), highway(i, 3));
%                                 end
%                             end
%                            assert (newPosThisLane >= obj.posY, 'Car did NOT advance [oldPos: %f, newPos: %f, minDistance: %f, newPosThisLane: %f, inFrontPos = %f(back), inFrontPos: %f(front)',...
%                                    obj.posY, newPos, obj.minNonCaravanDistance, newPosThisLane, inFrontPos, inFrontPos + obj.length);
                            obj.posY = newPosThisLane;
                            % Need to adjust current speed here?
                        end
                    end
                end
            end
%             obj.drv.Agent(obj);

            % Calculate fuel economy
            CalculateMPG(obj, inFrontPos);
            
            % update drive time.
            obj.driveTime = obj.driveTime + deltaTinSeconds;
            % Save the distance travelled (just in case)
            obj.distanceTraveled = obj.posY;
        end
        
        % See if we can change lanes and how far we could advance in that
        % lane.
        function [posInLane, newLane] = ChangeLanes(obj, highway, highwayIndex, newPos)
            leftLane = obj.lane + 1;
            rightLane = obj.lane - 1;

            posInLeftLane = 0.0;
            posInRightLane = 0.0;
            % Lets look at moving left first.
            % First make sure we are not trying to move into the caravan lane.
            if ~VehicleMgr.IsCaravanLane (leftLane) && VehicleMgr.IsTravelLane(leftLane)
                % Look in left lane and see how far we can advance there
                
                closest = ClosestInLane (obj, leftLane, highway, highwayIndex);  
                if (closest > 0)
                    % There is a possibility we will move.  See how far we
                    % can advance in that lane.
                    inFrontPos = highway(closest, 3);
                    if (inFrontPos > (newPos + obj.minNonCaravanDistance))
                        % We can advance the entire way
                        posInLeftLane = newPos;
                    else
                        posInLeftLane = inFrontPos - obj.minNonCaravanDistance;
                    end
                else
                    % Nothing in front in that lane.
                    posInLeftLane = newPos;
                end
            else
                leftLane = 0;
            end
            
            % Now try moving to the right.
            % But only if there is a right lane.
            if (VehicleMgr.IsTravelLane(rightLane))
                % Look in right lane and see how far we can advance there
                closest = ClosestInLane (obj, rightLane, highway, highwayIndex);  
                if (closest > 0)
                    % There is a possibility we will move.  See how far we
                    % can advance in that lane.
                    inFrontPos = highway(closest, 3);
                    if (inFrontPos > (newPos + obj.minNonCaravanDistance))
                        % We can advance the entire way
                        posInRightLane = newPos;
                    else
                        posInRightLane = inFrontPos - obj.minNonCaravanDistance;
                    end
                else
                    % Nothing in front in that lane.
                    posInRightLane = newPos;
                end
            else
                rightLane = 0;
            end
            
            if (posInLeftLane >= posInRightLane)
                posInLane = posInLeftLane;
                newLane = leftLane;
            else
                if(rightLane > 0)
                    posInLane = posInRightLane;
                    newLane = rightLane;
                else
                    posInLane = 0;
                    newLane = 0;
                end
            end
            
        end
        
        
        function  obj = SlowDown(obj,howHard)
            maxDelta = howHard * obj.deceleration *3600 / 5280; %convert from ft/s/s to m/h/s
            %maxDelta = howHard * obj.deceleration *3600 / 5280 *deltaTinSeconds; %convert from ft/s/s to m/h/s
            obj.velocity = min(max( obj.targetVelocity,obj.velocity-maxDelta),obj.velocity+maxDelta) ;
        end
        
        
        function obj = Enter(obj,deltaTinSeconds, highway, highwayIndex)
           % Get the closest car in lane 1 and see if we can enter.
            entryPoint = obj.posY;
            newPos = GetNewPos(obj, deltaTinSeconds);
            closest = ClosestInLane (obj,1, highway, highwayIndex);
            if (closest < 0)
                obj.lane = 1;
            else
                inFrontPos = highway(closest, 3);
                if (inFrontPos > (newPos + obj.minNonCaravanDistance))
                    obj.posY = newPos;
                    obj.lane = 1;
                else
                    % Can only advance so far this time.
                    newPos = inFrontPos - obj.minNonCaravanDistance;
                    if  newPos < 0
                        newPos = 0;
                    end
                    % if we can't advance at all (newPos <= current), stay
                    % in 0.
                    if (newPos > obj.posY)
                        obj.posY = newPos;
                        obj.lane = 1;
                    end
                end
            end
        end
        
        function obj = CalculateMPG(obj, leadCarPos)
            % http://www.omninerd.com/articles/Improve_MPG_The_Factors_Affecting_Fuel_Efficiency
            
            %http://en.wikipedia.org/wiki/Drag_power#Drag_at_high_velocity
            %F = .5*pv^2CA
            %F = force of drag (kg*m/s^2) = newtons
            %p = density of fluid (1.29 for atmospheric air) (kg/m^3)
            %v = speed of the object (m/s)
            %C = drag coefficient
            %A = reference area (m^2)
            
            % http://en.wikipedia.org/wiki/Automobile_drag_coefficient#Drag_area
            % drag area = C * A (m^2)
            
            % 1 mph = 0.44704 meters / second
            
            trailingDistance = leadCarPos - obj.posY;
            
            slipStreamRegion = 4 * obj.length;
            
            if trailingDistance <= 0 || trailingDistance > slipStreamRegion
                % nobody in front of me or too far away to care
                density = 1.29;
            else
                % modify density as a ratio of trailingDistance
                density = 1.29 - .65 * ...
                    ((slipStreamRegion - trailingDistance) / slipStreamRegion);
            end
            
            forceOfDrag=.5 * density * (obj.velocity * 0.44704) ^ 2 ...
                * obj.dragArea;
            
            % TODO incorporate acceleration
            % TODO incorporate velocity
            % TODO calculate work
            
            % TODO calculate fuel economy based on work
            obj.fuelEconomy = obj.baseFuelEconomy;
        end
        
    end

        
   methods (Static)
%       function num = getEmpNumber
%          num = queryDB('LastEmpNumber') + 1;
%       end
   end
    
end

