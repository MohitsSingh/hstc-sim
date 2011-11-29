%be careful to only clear the objects that we create each time so that 
%if this script is called from within the simulation program it doesn;t
%clear other peoples data

clear c;
clear vm;
clear allCars;
clear target;

c = Caravan.getInstance;
vm = VehicleMgr.getInstance;

%createa a caravan of ten cars
for i = 1:10
    allCars(i) = Vehicle;
    allCars(i).id = i;
    allCars(i).velocity = c.maxSpeed;
    
    %space cars out
    if i == 1
        allCars(i).posY = 10.0; %starting location        
    else
        allCars(i).posY = allCars(i-1).posY - c.minVehicleSpacing ;
    end
    
    %put all cars in caravan lane
    allCars(i).lane = 3;
    
    c.AddToVehicleList(allCars(i).id);
    
end


vm.AddVehicles(allCars);

%give the caravan a place to go...all the way to the end
c.destination = 50;

%add caravan to caravan controller


%createa a target vehicle to get into caravan
target              = Vehicle;
target.id           = 11;
target.posY         = 10+10;    %put it 10 miles ahead of caravan
target.destination  = 31.4159;
target.velocity     = 60.0;
target.wantsCaravan = true;

vm.AddVehicles(target);
