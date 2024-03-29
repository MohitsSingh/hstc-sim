%be careful to only clear the objects that we create each time so that 
%if this script is called from within the simulation program it doesn;t
%clear other peoples data

clear c;
clear VehicleMgr;
clear CaravanController;
clear allCars;
clear target;

% global cc
% global vm

c = Caravan;
cc = CaravanController.getInstance;
vm = VehicleMgr.getInstance;

%createa a caravan of ten cars
for i = 1:10
    allCars(i)                  = Vehicle;
    allCars(i).id               = i;
    allCars(i).velocity         = c.maxSpeed;
    allCars(i).targetVelocity   = c.maxSpeed;
    allCars(i).caravanSpeed     = c.maxSpeed;
    allCars(i).targetRate       = allCars(i).acceleration / 2.0;
    %space cars out
    if i == 1
        allCars(i).posY = 10.0; %starting location        
    else
        allCars(i).posY = allCars(i-1).posY - allCars(i-1).length - c.minVehicleSpacing ;
    end
    
    %put all cars in caravan lane
    allCars(i).lane = vm.lanes;
    allCars(i).caravanNumber = 1; % non-zero caravan number
    
    c.AddToVehicleList(allCars(i));
    
end

cc.AddCaravan(c);
vm.AddVehicles(allCars);

%give the caravan a place to go...all the way to the end
c.destination = 100;

%add caravan to caravan controller


%createa a target vehicle to get into caravan
target                      = Vehicle;
target.id                   = 11;
target.posY                 = 10+21;    %put it 10 miles ahead of caravan
target.destination          = 31.4159;
target.velocity             = 60.0;
target.targetVelocity       = 60.0;
target.lane                 = 2;
target.targetRate           = target.acceleration / 2.0;
target.wantsCaravan         = true;
vm.AddVehicles(target);
