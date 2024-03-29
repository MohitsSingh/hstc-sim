% (Shamelessly taken, and then modified, from Scenario 3 of TestVehicleClass)
%make two cars, have the lead car have a slower max speed, make sure the
%second car follows at a safe distance
%Start the car1 at pos 1.  
%Start the car2 at pos 0.  
% Accelerate to desired speed
% Travel to desired distance
% stop simulation when pos >= destination
% Collect and plot time, speed, and distance information
clear all;
clear vehicle;
clc;
disp('Scenario 3');
global car1;
global car2;
dest = 10;

car1 = Vehicle;
car1.id = 1;
car1.wantsCaravan = true;
car1.preferredSpeed = 45;
ds = car1.preferredSpeed;
car1.targetVelocity = ds;
car1.destination = dest; %miles
acc = car1.acceleration;
car1.targetRate = acc;
car1.lane = 1;
pos1     = 1;
car1.posY = pos1; %miles

car2 = Vehicle;
car2.id = 2 ;
car2.preferredSpeed = 55;
ds = car2.preferredSpeed;
car2.targetVelocity = ds;
car2.destination = dest; %miles
acc = car2.acceleration;
car2.targetRate = acc;
car2.lane = 2;
pos2     = 0;
car2.posY = pos2; %miles

done    = false;

n       = 1; %array index
t       = 0; %seconds
tinc    = 2; %seconds


%vm = VehicleMgr(3);
vm = VehicleMgr.getInstance;
vm = AddVehicles(vm, [car1, car2]);

guiHandle = GUI;
setappdata(guiHandle,'vm',vm);
GUI('updateGUI')

while( done == false )

%     if pos1 < dest
% %         [pos1,vel1,acc1] = car1.Advance(tinc); % step in 60 second increments
%         car1.Advance(tinc, vm.highway, car1.lane);
%     end
%     if pos2 < dest
% %         [pos2,vel2,acc2] = car2.Advance(tinc); % step in 60 second increments
%         car2.Advance(tinc, vm.highway, car2.lane);
%     end
    vm.TimeStep(tinc);

    pos1=car1.posY;
    vel1=car1.velocity;
    acc1=car1.acceleration;
    pos2=car2.posY;
    vel2=car2.velocity;
    acc2=car2.acceleration;
    
    if pos1 >= dest && pos2 >= dest
        done = true;
    end
    
    fprintf('t=%d, p=%f, v=%f, a=%f, p=%f, v=%f, a=%f\n',t,pos1, vel1, acc1,pos2, vel2, acc2);

    %collect results for plots
    x(n) = t;
    p(n) = pos1;
    s(n) = vel1;
    a(n) = acc1;
    n=n+1;

    t=t+tinc;
    
    setappdata(guiHandle,'vm',vm);
    GUI('updateGUI')
end

GUI