function KPP4()
% Function that runs the tests needed for KPP3
% This will always use the same time step (.003 ~ 10 seconds)

tic;

lanes = 5;
arrivalRate = 500;  % per hour in each travel lane.
deltaT = 10;        % in seconds
timeStep = 1/(60/deltaT)/60;    % in units of an hour.
useCaravan = true;
fillHours = 1;
trackId = -999;
numberTests = 3;

tg = TrafficGen;
tg = InitTraffic (tg, lanes, arrivalRate, 100, timeStep, useCaravan);
fprintf(1, 'Have traffic arrival times\n');

%clear Vehicle;
%clear VehicleMgr;

vm = VehicleMgr.getInstance(lanes);

currentTime = 0;
printOutTime = 10*60/deltaT;       % Print out a marker every simulated minute.
printOutCount = 0;

while (currentTime < fillHours)
    % First generate the vehicles for this time step and add them
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
        fprintf(1, '\tCurrent Caravan Count = %d\n', tg.lastCaravanId);
        printOutCount = 0;
    end
end
toc
fprintf(1, 'Highway filled\n');

numTestsRun = 5;


caravanMPG = zeros(1, numberTests);
nonCaravanMPG = zeros(1, numberTests);
caravanDistance = zeros(1, numberTests);
nonCaravanDistance = zeros(1, numberTests);
caravanTime = zeros(1, numberTests);
nonCaravanTime = zeros(1, numberTests);
caravanCount =zeros(1, numberTests);
nonCaravanCount = zeros(1, numberTests);
trackedDistance = zeros(1, numberTests);
trackedMPG = zeros(1, numberTests);
trackedTime = zeros(1, numberTests);

while (numTestsRun < numberTests)
    numTestsRun = numTestsRun + 1;
    % Now create a vehicle that we will track and use it to terminate the
    % simulation
    % First get a lane, then create the vehicle and insert it into the highway
    trackLane = round(1 + ((lanes - 2) - 1) * rand());
    v = TrafficGen.NewVehicle (trackLane, trackId, 0, false);

    vehicles = [v];
    vm = AddVehicles(vm, vehicles);
    vm = TimeStep(vm, deltaT);
    currentTime = currentTime + timeStep;

    % Now, run more time steps until the vehicle we are tracking leaves the
    % highway.

    while (any(any(vm.highway == -999)) == 1)
        % First generate the vehicles for this time step and add them
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
            fprintf(1, '\tCurrent Caravan Count = %d\n', tg.lastCaravanId);
            printOutCount = 0;
        end

        % Now see if vehicle exited by sorting the highway on the index and
        % seeing if it is the first one or not.
    end

    % Now loop through and cars and gather the stats
    fprintf(1, '\n\nAt end:\n');
    fprintf(1, '\tCurrent Vehicle Count = %d\n', length(vm.currentVehicles));
    fprintf(1, '\tExited Vehicle Count = %d\n', length(vm.exitedVehicles));
    trackedV = Vehicle.empty;
    for i = 1:length(vm.currentVehicles)
        v = vm.currentVehicles(i);
        if(v.distanceTraveled ~= 0)
            if (v.caravanNumber > 0)
                caravanDistance(numTestsRun) = caravanDistance(numTestsRun) + v.distanceTraveled;
                caravanTime(numTestsRun) = caravanTime(numTestsRun) + v.driveTime;
                caravanCount(numTestsRun) = caravanCount(numTestsRun) + 1;
                caravanMPG(numTestsRun) = caravanMPG(numTestsRun) + v.avgMPG;
            else
                nonCaravanDistance(numTestsRun) = nonCaravanDistance(numTestsRun) + v.distanceTraveled;
                nonCaravanTime(numTestsRun) = nonCaravanTime(numTestsRun) + v.driveTime;
                nonCaravanCount(numTestsRun) = nonCaravanCount(numTestsRun) + 1;
                nonCaravanMPG(numTestsRun) = nonCaravanMPG(numTestsRun) + v.avgMPG;
            end
            if (v.id == trackId)
                trackedDistance(numTestsRun) = v.distanceTraveled;
                trackedMPG(numTestsRun) = v.avgMPG;
                trackedTime(numTestsRun) = v.driveTime;
            end
            v.distanceTraveled = 0.0;
            v.driveTime = 0.0;
            v.avgMPG = 0.0;
            v.avgMPGCounter = 0;
        end
    end
    for i = 1:length(vm.exitedVehicles)
        v = vm.exitedVehicles(i);
        if(v.distanceTraveled ~= 0)
            if (v.caravanNumber > 0)
                caravanDistance(numTestsRun) = caravanDistance(numTestsRun) + v.distanceTraveled;
                caravanTime(numTestsRun) = caravanTime(numTestsRun) + v.driveTime;
                caravanCount(numTestsRun) = caravanCount(numTestsRun) + 1;
                caravanMPG(numTestsRun) = caravanMPG(numTestsRun) + v.avgMPG;
            else
                nonCaravanDistance(numTestsRun) = nonCaravanDistance(numTestsRun) + v.distanceTraveled;
                nonCaravanTime(numTestsRun) = nonCaravanTime(numTestsRun) + v.driveTime;
                nonCaravanCount(numTestsRun) = nonCaravanCount(numTestsRun) + 1;
                nonCaravanMPG(numTestsRun) = nonCaravanMPG(numTestsRun) + v.avgMPG;
            end
            if (v.id == trackId)
                trackedDistance(numTestsRun) = v.distanceTraveled;
                trackedMPG(numTestsRun) = v.avgMPG;
                trackedTime(numTestsRun) = v.driveTime;
            end
            v.distanceTraveled = 0.0;
            v.driveTime = 0.0;
            v.avgMPG = 0.0;
            v.avgMPGCounter = 0;
        end
    end

    fprintf(1, 'Non Caravan Distance traveled: %f\n', nonCaravanDistance(numTestsRun));
    fprintf(1, 'Non Caravan travel time (hours): %f\n', nonCaravanTime(numTestsRun)/60/60);
    fprintf(1, 'Average non-caravan MPH: %f\n', nonCaravanDistance(numTestsRun)/(nonCaravanTime(numTestsRun)/60/60));
    fprintf(1, 'Average non-caravan MPG; %f\n', nonCaravanMPG(numTestsRun)/nonCaravanCount(numTestsRun));
    
    fprintf(1, 'Caravan Distance traveled: %f\n', caravanDistance(numTestsRun));
    fprintf(1, 'Caravan travel time (hours): %f\n', caravanTime(numTestsRun)/60/60);
    fprintf(1, 'Average caravan MPH: %f\n', caravanDistance(numTestsRun)/(caravanTime(numTestsRun)/60/60));
    fprintf(1, 'Average caravan MPG; %f\n', caravanMPG(numTestsRun)/caravanCount(numTestsRun));
    
    fprintf(1, 'Total number of vehicles: %d\n', length(vm.currentVehicles) + length(vm.exitedVehicles));
    fprintf(1, 'Caravan vehicles: %d\n', caravanCount(numTestsRun));
    
%     caravanMpg = mean(nonzeros(([vm.currentVehicles.caravanNumber] > 0) .* [vm.currentVehicles.fuelEconomy]))
%     nonCaravanMpg = mean(nonzeros(([vm.currentVehicles.caravanNumber] <= 0) .* [vm.currentVehicles.fuelEconomy]))
%     avgMpg = mean([vm.currentVehicles.fuelEconomy])

    fprintf(1, 'Tracked vehicle went %f\n', trackedDistance(numTestsRun));
    fprintf(1, 'Tracked vehicle travel time (hours) %f\n', trackedTime(numTestsRun)/60/60);
    fprintf(1, 'Tracked vehicle MPH: %f\n', trackedDistance(numTestsRun)/(trackedTime(numTestsRun)/60/60));
    fprintf(1, 'Tracked Vehicle avg MPG = %f\n', trackedTime(numTestsRun));
end

fprintf(1, 'caravanMPG: ');
for i=1:numTestsRun
    fprintf(1, '%f, ', caravanMPG(i));
end
fprintf(1, '\n\n');

fprintf(1, 'nonCaravanMPG: ');
for i=1:numTestsRun
    fprintf(1, '%f, ', nonCaravanMPG(i));
end
fprintf(1, '\n\n');


fprintf(1, 'caravanDistance: ');
for i=1:numTestsRun
    fprintf(1, '%f, ', caravanDistance(i));
end
fprintf(1, '\n\n');


fprintf(1, 'nonCaravanDistance: ');
for i=1:numTestsRun
    fprintf(1, '%f, ', nonCaravanDistance(i));
end
fprintf(1, '\n\n');


fprintf(1, 'caravanTime: ');
for i=1:numTestsRun
    fprintf(1, '%f, ', caravanTime(i));
end
fprintf(1, '\n\n');


fprintf(1, 'nonCaravanTime: ');
for i=1:numTestsRun
    fprintf(1, '%f, ', nonCaravanTime(i));
end
fprintf(1, '\n\n');


fprintf(1, 'caravanCount: ');
for i=1:numTestsRun
    fprintf(1, '%f, ', caravanCount(i));
end
fprintf(1, '\n\n');


fprintf(1, 'nonCaravanCount: ');
for i=1:numTestsRun
    fprintf(1, '%f, ', nonCaravanCount(i));
end
fprintf(1, '\n\n');


fprintf(1, 'trackedDistance: ');
for i=1:numTestsRun
    fprintf(1, '%f, ', trackedDistance(i));
end
fprintf(1, '\n\n');


fprintf(1, 'trackedMPG: ');
for i=1:numTestsRun
    fprintf(1, '%f, ', trackedMPG(i));
end
fprintf(1, '\n\n');


fprintf(1, 'trackedTime: ');
for i=1:numTestsRun
    fprintf(1, '%f, ', trackedTime(i));
end
fprintf(1, '\n\n');

toc
end

