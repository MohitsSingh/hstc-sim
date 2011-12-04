function KPP4(hoursForTest)
% Function that runs the tests needed for KPP3
% input is the simulated number of hours to run.
% This will always use the same time step (.003 ~ 10 seconds)

% First lets perform a test WITHOUT a caravan lane
lanes = 4;
arrivalRate = 900;  % per hour in each travel lane.
deltaT = 10;        % in seconds
timeStep = 1/(60/deltaT)/60;    % in units of an hour.

tg = TrafficGen;
tg = InitTraffic (tg, lanes, arrivalRate, hoursForTest, timeStep, false);

vm = VehicleMgr.getInstance;

currentTime = 0;
printOutTime = 60/deltaT;       % Print out a marker every simulated minute.
printOutCount = 0;
while (currentTime < hoursForTest)
    %First generate the vehicles for this time step.
    [tg, vehicles] = TimeStep(tg);
    
    vm = AddVehicles(vm, vehicles);
    
    % Now have everyone advance.
    vm = TimeStep(vm, deltaT);
    
    currentTime = currentTime + timeStep;
    printOutCount = printOutCount + 1;
    if (printOutCount >= printOutTime)
        fprintf(1, 'Current time = %d\n', currentTime);
        fprintf(1, '\tCurrent Vehicle Count = %d\n', length(vm.currentVehicles));
        fprintf(1, '\tExited Vehicle Count = %d\n', length(vm.exitedVehicles));
        printOutCount = 0;
    end
end

% Now loop through and cars and gather the stats
ttlDistance = 0.0;
ttlTime = 0.0;
for i = 1:length(vm.currentVehicles)
    ttlDistance = ttlDistance + vm.currentVehicles(i).distanceTraveled;
    ttlTime = ttlTime + vm.currentVehicles(i).driveTime;
end
for i = 1:length(vm.exitedVehicles)
    ttlDistance = ttlDistance + vm.exitedVehicles(i).distanceTraveled;
    ttlTime = ttlTime + vm.exitedVehicles(i).driveTime;
end
ttlDistance
ttlTime/60/60
    
length(vm.currentVehicles) + length(vn.exitedVehicles)

end

