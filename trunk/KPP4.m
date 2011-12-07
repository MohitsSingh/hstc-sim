function KPP4()
% Function that runs the tests needed for KPP3
% This will always use the same time step (.003 ~ 10 seconds)

tic;

disp('*******************************BAD VALUES*********************');
lanes = 5;
arrivalRate = 100; %500;  % per hour in each travel lane.
deltaT = 10;        % in seconds
timeStep = 1/(60/deltaT)/60;    % in units of an hour.
useCaravan = true;
fillHours = 1.0;
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

numTestsRun = 0;
disp ('***********BAD VALUES***********')

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
    trackLane = int32(1 + ((lanes - 2) - 1) * rand())
    v= TrafficGen.NewVehicle (trackLane, trackId, 0, false);

    disp ('***********BAD VALUES***********')
    v.destinationRamp = 10 + numTestsRun;

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
            v.distanceTraveled = 0.0;
            v.driveTime = 0.0;
            v.avgMPG = 0.0;
            v.avgMPGCounter = 0;
            if (v.id == trackId)
                trackedV = v;
            end
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
            v.distanceTraveled = 0.0;
            v.driveTime = 0.0;
            v.avgMPG = 0.0;
            v.avgMPGCounter = 0;
            if (v.id == trackId)
                trackedV = v;
            end
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

    fprintf(1, 'Tracked vehicle went %f\n', trackedV.distanceTraveled);
    fprintf(1, 'Tracked vehicle travel time (hours) %f\n', trackedV.driveTime/60/60);
    fprintf(1, 'Tracked vehicle MPH: %f\n', trackedV.distanceTraveled/(trackedV.driveTime/60/60));
    fprintf(1, 'Tracked vehicle target velocity = %f\n', trackedV.targetVelocity);
    fprintf(1, 'Tracked vehicle velocity = %f\n', trackedV.velocity);
    fprintf(1, 'Tracked Vehicle avg MPG = %f\n', trackedV.avgMPG);
    
    trackedDistance(numTestsRun) = trackedV.distanceTraveled;
    trackedMPG(numTestsRun) = trackedV.avgMPG;
    trackedTime(numTestsRun) = trackedV.driveTime;
end

caravanMPG
nonCaravanMPG
caravanDistance
nonCaravanDistance
caravanTime
nonCaravanTime
caravanCount
nonCaravanCount
trackedDistance
trackedMPG
trackedTime

toc
end

