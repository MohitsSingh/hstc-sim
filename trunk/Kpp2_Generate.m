%be careful to only clear the objects that we create each time so that 
%if this script is called from within the simulation program it doesn;t
%clear other peoples data

clear c;
clear VehicleMgr;
clear CaravanController;
clear allCars;
clear target;

c = Caravan;
cc = CaravanController.getInstance;
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
        allCars(i).posY = allCars(i-1).posY - allCars(i-1).length - c.minVehicleSpacing ;
    end
    
    if i == 4
        allCars(i).wantsOutOfCaravan = true;
    end
    
    %put all cars in caravan lane
    allCars(i).lane = 4;
    %add to caravan
    allCars(i).caravanNumber = 1;
    
    c.AddToVehicleList(allCars(i));
    
end

%give the caravan a place to go...all the way to the end
c.destination = 100;

%add caravan to caravan controller
cc.AddCaravan(c);

vm.AddVehicles(allCars);
