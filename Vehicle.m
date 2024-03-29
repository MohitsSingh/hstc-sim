classdef Vehicle < hgsetget % subclass hgsetget
    %VECHICLE Summary of this class goes here
    %   Detailed explanation goes here
    %TODO if my destination is x miles away, I will want out of caravan
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
% starting      0.30.5         0.50.9 	1.7             < 0.2
% braking       0.81.0         1.01.3 	2               ~ 0.6
% cornering 	0.70.9         0.91.0 	3               ??        

        entryRamp               = 0;
        destinationRamp         = 10000.0;       % Set to high value by default.
        
        destination             = 0;    %in miles.
        
        dragArea                = 0.75;
        wantsCaravan            = false;
        joiningCaravan          = false;
        leavingCaravan          = false;
        wantsOutOfCaravan       = false;
        moveToCaravanLane       = false;
        moveDelay               = 0;
        moveToMergeLane         = false;    %the caravan controller will tell us when to move
        gapMode                 = false;
        closingRanks            = false;
        caravanNumber           = 0;  %might be redundant...can lookup in caravan
        caravanPosition         = 0;
        caravanSpeed            = 0;
        fuelEconomy             = 20.0; %mpg
        avgMPG                  = 0.0;  % Running average of fuel economy
        avgMPGCounter           = 0;
        weight                  = 1360.77; % kg (~3000 lbs)
        
        lastAdjustment          = 0;
        %john variables
        preferredSpeed          = 55;    %45, 55, 65 +-5mph gaussian
                                        %randomize for 1/2/3
                                        %randomize for spread
        initialVelocity         = 0;    %may be set to desired speed +- if
                                        %we are populating a roadway for initial
                                        %conditions
        targetVelocity          = 0;    % how fast do we want to be going
        targetRate              = 0;    % how fast do we want to change our speed
        
        drv                     = Driver; %simulator of human agent
        accModule               = Acc;      %the computerized driver (no steering, though)
        
        % Statitics to collect for KPP4
        driveTime               = 0.0;        % Time from entry to exit in seconds
        distanceTraveled        = 0.0; % How far have we gone?  In miles
        
        %Minimum distance between cars NOT in caravan
        minNonCaravanDistance   = 0.005681 % 30 feet in miles.
        
        %Minimum distance between cars in caravan
        minCaravanDistance      = 0.0005681 % 3 feet in miles.
                                        
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
                    if highway(highwayIndex,2) > mergeLane
                        obj.lane = obj.lane - 1;
                        newPos = obj.posY; %move only laterally this turn
                        %TODO bug...move doesn't get updated into highway
                    else
                        obj.lane = obj.lane + 1;
                    end
                    VehicleMgr.LaneChange(highwayIndex);
                end
            elseif obj.moveToCaravanLane == true
                %TODO account for lateral velocity 
                caravanLane = vm.lanes  ;
                obj.moveDelay = obj.moveDelay + 1;
                if obj.moveDelay > 12
                    if highway(highwayIndex,2) == caravanLane %caravan lane?
                        obj.moveToCaravanLane = false;
                        obj.moveDelay = 0 ;
                    else
                        obj.lane = caravanLane;
                        obj.posY = obj.caravanPosition ;
                        newPos = obj.posY;
                        highway(highwayIndex,3) = obj.posY;
                        VehicleMgr.LaneChange(highwayIndex);
                    end
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
                    if obj.gapMode == true
%                         followDistance = 27/5280.0; %TODO
                        followDistance = obj.minCaravanDistance + 2* obj.length;
                    else
                        followDistance = obj.minCaravanDistance;
                    end
                    
                    % We are in follow mode, so we can't get too close
                    % but we do have a little slack on being a little too 
                    % far away (twice follow distance)
                    obj.posY        = newPos;
                    distanceBehind  = inFrontPos - newPos;
                    closestAllowed  = followDistance;
                    farthestAllowed = 2* followDistance;
                    if obj.gapMode == true || obj.joiningCaravan
                        farthestAllowed = 27/5280.0; %TODO
                    end

                    error           = followDistance - distanceBehind ; 
                    deltaTinHours   = deltaTinSeconds /3600.0;
                    
                    %Distance travelled would have been V0*t,
                    %but ifwe are either too close or to far,
                    %we need to adjust our speed to account for the error
                    %So instead of going V0*t distance, we want to go
                    %that distance offset by the error.  Use
                    %V1*t = V0*t + error to solve for V1
                    %V1 = (V0*t + error) / t
                    %Then underdamp the response by using only 10% of that
                    %change
                    
% % %                     if distanceBehind < closestAllowed
% % %                         %predict new velocity
% % %                         adjustment = (( (obj.velocity*deltaTinHours) - error) / deltaTinHours ) - obj.velocity ;
% % %                         adjustment = adjustment * 0.10; % only take 10% of adjustment
% % %                         if obj.lastAdjustment ~= 0
% % %                             %if the sign is the same then we are good, let
% % %                             %it ride, else zero it
% % %                             if ( (adjustment > 0) && (obj.lastAdjustment > 0) ...
% % %                                ||(adjustment < 0) && (obj.lastAdjustment < 0))
% % %                            %let the previous adjust ride
% % %                             else
% % %                                 obj.lastAdjustment = 0; %sign changed
% % %                             end
% % %                         else
% % %                             obj.targetVelocity = obj.targetVelocity + adjustment;
% % %                             obj.lastAdjustment = adjustment;
% % %                         end
% % %                     elseif distanceBehind > farthestAllowed
% % %                         %predict new velocity
% % %                         adjustment = (( (obj.velocity*deltaTinHours) - error) / deltaTinHours ) - obj.velocity ;
% % %                         adjustment = adjustment * 0.90; % only take 10% of adjustment
% % %                         if obj.lastAdjustment ~= 0
% % %                             %if the sign is the same then we are good, let
% % %                             %it ride, else zero it
% % %                             if ( (adjustment > 0) && (obj.lastAdjustment > 0) ...
% % %                                ||(adjustment < 0) && (obj.lastAdjustment < 0))
% % %                            %let the previous adjust ride
% % %                             else
% % %                                 obj.lastAdjustment = 0; %sign changed
% % %                             end
% % %                         else
% % %                             obj.targetVelocity = obj.targetVelocity + adjustment;
% % %                             obj.lastAdjustment = adjustment;
% % %                         end
% % %                     else
% % %                         %velocity is cool, we are in the band
% % %                         %restore velocity to previous unadjusted value
% % %                         if obj.lastAdjustment ~= 0
% % %                             obj.targetVelocity  = obj.targetVelocity-obj.lastAdjustment;
% % %                             obj.lastAdjustment = 0;
% % %                         end
% % %                     end
                    obj.posY = min(newPos, inFrontPos - followDistance);
                    if newPos > inFrontPos - followDistance
%                         if obj.closingRanks
%                             obj.velocity = obj.velocity * (inFrontPos - followDistance) / newPos;
%                         else
                            error = newPos - (inFrontPos - followDistance);
                           adjustment = (( (obj.velocity*deltaTinHours) - error) / deltaTinHours ) - obj.velocity ;
                           adjustment = adjustment * 1.0; % only take 10% of adjustment

                           obj.velocity = obj.velocity + adjustment;
%                         end
                    elseif newPos < inFrontPos - 2 *followDistance
                        %TODO Add closing the gap to follow distance
                        error = newPos - (inFrontPos - followDistance);
                        adjustment = (( (obj.velocity*deltaTinHours) - error) / deltaTinHours ) - obj.velocity ;
                        adjustment = adjustment * 1.0; % only take 10% of adjustment
                        
                        obj.targetVelocity = obj.velocity + adjustment;
                    elseif obj.closingRanks
                        %our position is good, so turn this off
                        obj.closingRanks = false;
                    end
                    if obj.closingRanks 
                        error = newPos - (inFrontPos - followDistance);
                        if error <6.0/5280
                            obj.closingRanks = false;
                        end
                        disp(error);
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
            
            % update our stats.
            obj.driveTime = obj.driveTime + deltaTinSeconds;
            obj.avgMPG = (obj.avgMPG * obj.avgMPGCounter + obj.fuelEconomy)/(obj.avgMPGCounter + 1);
            obj.avgMPGCounter = obj.avgMPGCounter + 1;
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
            
            slipStreamRegion = 5 * obj.length;
            
            if trailingDistance <= 0 || trailingDistance > slipStreamRegion
                % nobody in front of me or too far away to care
                density = 1.22;
            else
                % modify density as a ratio of trailingDistance
                density = 1.22 * (1 - .14 * ...
                    ((slipStreamRegion - trailingDistance) / slipStreamRegion));
            end
            
            forceOfDrag=.5 * density * (obj.velocity * 0.44704) ^ 2 ...
                * obj.dragArea;
            
            powerOfDrag = forceOfDrag * (obj.velocity * 0.44704); % watts
            
            % Rolling resistance formula: Crr * WeightKG * Gravitational acceleration
            % Crr = coefficient of rolling resistance ~= .01 for a car
            
            rollingResistance = obj.weight * .01 * 9.8 * (obj.velocity * 0.44704); % watts
            
            %convert to horsepower, and figure out weight of gas consumed
            % 1 hp = 746 W = 746 (kg·m/s2)·(m/s)
%             powerOfDragHP = powerOfDrag / 746; % hp
            
            %http://ecomodder.com/wiki/index.php/Simulation_and_calculations
            % Fuel energy density (Wh/US gal.): 33557 
            % Engine efficiency: .22 
            % Drivetrain efficiency: .95 
            mpgRequired = obj.velocity * 33557 * .22 * .95 / ...
                (powerOfDrag + rollingResistance);
            
            
            obj.fuelEconomy = mpgRequired;

            
            %convert the weight to gallons
            %divide gallons into miles travelled for mpg
            
            % http://www.valentintechnologies.com/fuel-consumption/default.asp
            % In addition, the free-piston engine has inherently fewer 
            % losses (friction, heat) and is significantly lighter, thus 
            % reducing the weight of the car. Best current engines have a 
            % specific fuel consumption of 0.310 lb/hp?h but operate at 
            % an average of about 0.450 lb/hp?h. 
            
            
            
            % powerOfDragHP * 0.45   == lb/h
            % "" / 6.073 = g/h
            % 1 / "" = h/g
            % velocity * "" = m/g
            
%             mpgLossDueToDrag = obj.velocity / (powerOfDragHP * 0.45 / 6.073);
            
            % http://wiki.answers.com/Q/How_much_does_a_gallon_of_gasoline_weigh
            % 6.073 pounds per US Gallon. 

            % http://en.wikipedia.org/wiki/Gallon
            % This gallon is defined as 231 cubic inches,[1] and is 
            % equal to exactly 3.785411784 litres or about 0.13368 cubic 
            % feet. This is the most common definition of a gallon 
            % in the United States. 
        end
        
    end

        
   methods (Static)
%       function num = getEmpNumber
%          num = queryDB('LastEmpNumber') + 1;
%       end
   end
    
end

