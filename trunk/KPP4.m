function KPP4(hoursForTest)
% Function that runs the tests needed for KPP3
% input is the simulated number of hours to run.
% This will always use the same time step (.003 ~ 10 seconds)
global guiHandle


% First lets perform a test WITHOUT a caravan lane
lanes = 5;
arrivalRate = 500;  % per hour in each travel lane.
deltaT = 10;        % in seconds
timeStep = 1/(60/deltaT)/60;    % in units of an hour.
useCaravan = true;

tg = TrafficGen;
tg = InitTraffic (tg, lanes, arrivalRate, hoursForTest, timeStep, useCaravan);

clear Vehicle;
clear VehicleMgr;

vm = VehicleMgr.getInstance(lanes);

currentTime = 0;
printOutTime = 10*60/deltaT;       % Print out a marker every simulated minute.
printOutCount = 0;

guiHandle = GUI;
setappdata(guiHandle,'vm',vm);
GUI('updateGUI');

while (currentTime < hoursForTest)
    %First generate the vehicles for this time step.
    [tg, vehicles] = TimeStep(tg);
    
    vm = AddVehicles(vm, vehicles);
    
    % Now have everyone advance.
    vm = TimeStep(vm, deltaT);
    
    setappdata(guiHandle,'vm',vm);
    GUI('updateGUI');
    
    currentTime = currentTime + timeStep;
    printOutCount = printOutCount + 1;
    if (printOutCount >= printOutTime)
        fprintf(1, 'Current time = %d\n', currentTime);
        fprintf(1, '\tCurrent Vehicle Count = %d\n', length(vm.currentVehicles));
        fprintf(1, '\tExited Vehicle Count = %d\n', length(vm.exitedVehicles));
        printOutCount = 0;
    end
end

% Now empty out the complete highway.
% while (~isempty(vm.currentVehicles))
%     vm = TimeStep(vm, deltaT);
%     currentTime = currentTime + timeStep;
%     printOutCount = printOutCount + 1;
%     if (printOutCount >= printOutTime)
%         fprintf(1, 'Current time = %d\n', currentTime);
%         fprintf(1, '\tCurrent Vehicle Count = %d\n', length(vm.currentVehicles));
%         fprintf(1, '\tExited Vehicle Count = %d\n', length(vm.exitedVehicles));
%         printOutCount = 0;
%     end
% end

% Now loop through and cars and gather the stats
fprintf(1, '\n\nAt end:\n');
fprintf(1, '\tCurrent Vehicle Count = %d\n', length(vm.currentVehicles));
fprintf(1, '\tExited Vehicle Count = %d\n', length(vm.exitedVehicles));
ttlDistance = 0.0;
ttlTime = 0.0;
z = 0;
travelLanes = lanes - 2;
for i = 1:length(vm.currentVehicles)
    if(vm.currentVehicles(i).distanceTraveled == 0)
        z = z + 1;
    else
        ttlDistance = ttlDistance + vm.currentVehicles(i).distanceTraveled;
        ttlTime = ttlTime + vm.currentVehicles(i).driveTime;
    end
    
    if (vm.currentVehicles(i).lane > travelLanes)
        fprintf(1, '*');
    end
end
for i = 1:length(vm.exitedVehicles)
    ttlDistance = ttlDistance + vm.exitedVehicles(i).distanceTraveled;
    ttlTime = ttlTime + vm.exitedVehicles(i).driveTime;
end

fprintf(1, 'Total Distance traveled: %f\n', ttlDistance);
fprintf(1, 'Total travel time (hours): %f\n', ttlTime/60/60);
fprintf(1, 'Average MPH: %f\n', ttlDistance/(ttlTime/60/60));

fprintf(1, 'Number of waiting vehicles: %d\n', z);
fprintf(1, 'Total number of vehicles: %d\n', length(vm.currentVehicles) + length(vm.exitedVehicles));

end

