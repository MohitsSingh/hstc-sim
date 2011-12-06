function KPP4(hoursForTest)
% Function that runs the tests needed for KPP3
% input is the simulated number of hours to run.
% This will always use the same time step (.003 ~ 10 seconds)
%global guiHandle

tic;

% First lets perform a test WITHOUT a caravan lane
lanes = 5;
arrivalRate = 900;  % per hour in each travel lane.
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

% guiHandle = GUI;
% setappdata(guiHandle,'vm',vm);
% GUI('updateGUI');

while (currentTime < hoursForTest)
    %First generate the vehicles for this time step.
    [tg, vehicles] = TimeStep(tg);
    
    vm = AddVehicles(vm, vehicles);
    
    % Now have everyone advance.
    vm = TimeStep(vm, deltaT);
    
%     setappdata(guiHandle,'vm',vm);
%     GUI('updateGUI');
    
    currentTime = currentTime + timeStep;
    printOutCount = printOutCount + 1;
    if (printOutCount >= printOutTime)
        fprintf(1, 'Current time = %d\n', currentTime);
        fprintf(1, '\tCurrent Vehicle Count = %d\n', length(vm.currentVehicles));
        fprintf(1, '\tExited Vehicle Count = %d\n', length(vm.exitedVehicles));
        fprintf(1, '\tCurrent Caravan Count = %d\n', tg.lastCaravanId);
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
caravanDistance = 0.0;
ttlTime = 0.0;
caravanTime = 0.0;
travelLanes = lanes - 2;
caravanCount = 0;
for i = 1:length(vm.currentVehicles)
    v = vm.currentVehicles(i);
    if(v.distanceTraveled ~= 0)
        if (v.caravanNumber > 0)
            caravanDistance = caravanDistance + v.distanceTraveled;
            caravanTime = caravanTime + v.driveTime;
            caravanCount = caravanCount + 1;
        else
            ttlDistance = ttlDistance + v.distanceTraveled;
            ttlTime = ttlTime + v.driveTime;
        end
    end
end
for i = 1:length(vm.exitedVehicles)
    v = vm.exitedVehicles(i);
    if(v.distanceTraveled ~= 0)
        if (v.caravanNumber > 0)
            caravanDistance = caravanDistance + v.distanceTraveled;
            caravanTime = caravanTime + v.driveTime;
            caravanCount = caravanCount + 1;
        else
            ttlDistance = ttlDistance + v.distanceTraveled;
            ttlTime = ttlTime + v.driveTime;
        end
    end
end

fprintf(1, 'Total Distance traveled: %f\n', ttlDistance);
fprintf(1, 'Total travel time (hours): %f\n', ttlTime/60/60);
fprintf(1, 'Average non-caravan MPH: %f\n', ttlDistance/(ttlTime/60/60));
fprintf(1, 'Caravan Distance traveled: %f\n', caravanDistance);
fprintf(1, 'Caravan travel time (hours): %f\n', caravanTime/60/60);
fprintf(1, 'Average caravan MPH: %f\n', caravanDistance/(caravanTime/60/60));
fprintf(1, 'Total number of vehicles: %d\n', length(vm.currentVehicles) + length(vm.exitedVehicles));
fprintf(1, 'Caravan vehicles: %d\n', caravanCount);

toc
end

