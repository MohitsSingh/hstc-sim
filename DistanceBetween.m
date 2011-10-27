function [ distance ] = DistanceBetween( obj )
%DISTANCEBETWEEN Summary of this function goes here
%   Detailed explanation goes here
global car1;
global car2;

    if obj == car1 
        distance = 9999;
    else
        distance = car1.posY - car2.posY;    
    end
    
end

