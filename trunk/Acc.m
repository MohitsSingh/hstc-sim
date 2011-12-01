classdef Acc < hgsetget % subclass hgsetget
    %ACC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mode                    =   'off';  %acc operating mode
        caravanFollowDistance   =   3.0 / 5280.0;   %in miles
        %in run time the ACC will use the X-second rule to maintain a safe
        %distance when in 'avoid' mode.   THe default value of 750 is an
        %approx 5 second rule at 100 miles per hour.
        howManySecondRule       =   2.0;    %seconds
        avoidingDistance        =   750.0 / 5280.0; % a dummy default value in miles

        prevSpeedDelta          =   0;
        prevDistanceAhead       =   1.0;  %an arbitrarily large value in miles

        mph2mps                 =   1.0 / 3600.0; %conversion miles per hour to miles per second
    end
    
    methods
        function obj = Acc()
            obj.mode = 'off';
        end
        function obj = SetOff(obj)
            obj.mode = 'follow';
        end
        function obj = SetFollowMode(obj)
            obj.mode = 'follow';
        end
        function obj = SetAvoidMode(obj)
            obj.mode = 'avoid';
        end
        
        function isSystemGood = Diagnostics()
            isSystemGood = true;
        end
        %in real life, the acc will use it's radar to determine distance to
        %car in front of us.   For the purpose of simulation, the distance
        %to the car in front of us 
        
        function [isThereAProblem,speedDelta] = Advance(obj, currentSpeed, distanceAhead)
            isAccHealthy = obj.Diagnostics();
            if isAccHealthy
                isThereAProblem = false;
                if obj.mode == 'avoid'
                    %determine distance, and rate change of distance to
                    %car in front of us
                    %if we are getting too close, slow down to get to 
                    %safe distance
                    %if we are getting to close too fast, slow down FAST
                    
                    %calculate safe following distance
                    obj.avoidingDistance = obj.howManySecondRule * currentSpeed * obj.mph2mps;
                    if distanceAhead < obj.avoidingDistance
                        %slow down
                        % -1 decelerate by coasting
                        % -2 use brakes to decel 25%
                        % -3 use brakes to decel 50%
                        % -4 use brakes to decel 75%
                        % -5 brake like hell
                        speedDelta = -1; 
                        
                        %use previous speed delta and a calculation based
                        %rate of change of distance to decide if we should
                        %brake harder
                        
                        %TODO
                        
                        %save distance ahead for next time
                        obj.prevSpeedDelta = speedDelta;
                        obj.prevDistanceAhead = distanceAhead;
                    else
                        %no problem
                    end
                    
                elseif obj.mode == 'follow'
                    %maintain the following distance by accelerating or 
                    %decelerating
                end
            else
                obj.mode = 'off';
                isThereAProblem = true;
            end
        end
        
    end
    
end

