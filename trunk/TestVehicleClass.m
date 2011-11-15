


%% Scenario 3
%make two cars, have the lead car have a slower max speed, make sure the
%second car follows at a safe distance
%Start the car1 at pos 1.  
%Start the car2 at pos 0.  
% Accelerate to desired speed
% Travel to desired distance
% stop simulation when pos >= destination
% Collect and plot time, speed, and distance information
clear;
clear vehicle;
clc;
disp('Scenario 3');
global car1;
global car2;
dest = 50;

car1 = Vehicle;
car1.id = 'car1';
car1.preferredSpeed = 45;
ds = car1.preferredSpeed;
car1.targetVelocity = ds;
car1.destination = dest; %miles
acc = car1.acceleration;
car1.targetRate = acc;
pos1     = 20/5280;
car1.posY = pos1; %miles

car2 = Vehicle;
car2.id = 'car2';
car2.preferredSpeed = 55;
ds = car2.preferredSpeed;
car2.targetVelocity = ds;
car2.destination = dest; %miles
acc = car2.acceleration;
car2.targetRate = acc;
pos2     = 0;
car2.posY = pos2; %miles

done    = false;

vm=VehicleManager.getInstance;
vm.AddCar(car1);
vm.AddCar(car2);

car3 = car2;
car3.id = 'car3';
pos3 = (car1.posY + car2.posY)/2;
car3.posY = pos3;
vm.AddCar(car3);

n       = 1; %array index
t       = 0; %seconds
tinc    = 1; %seconds
while( done == false )
    
    if pos1 < dest
        [pos1,vel1,acc1] = car1.Advance(tinc); % step in 60 second increments
    end
    if pos2 < dest
        [pos2,vel2,acc2] = car2.Advance(tinc); % step in 60 second increments
    end
    if pos3 < dest
        [pos3,vel3,acc3] = car3.Advance(tinc); % step in 60 second increments
    end    
    if pos1 >= dest && pos2 >= dest && pos3 >= dest
        done = true;
    else
   
        %fprintf('t=%d, p=%f, v=%f, a=%f, p=%f, v=%f, a=%f\n',t,pos1, vel1, acc1,pos2, vel2, acc2);

        %collect results for plots
        x(n) = t;
        p1(n) = pos1;
        s1(n) = vel1;
        a1(n) = acc1;

        p2(n) = pos2;
        s2(n) = vel2;
        a2(n) = acc2;

        p3(n) = pos3;
        s3(n) = vel3;
        a3(n) = acc3;

        n=n+1;

        t=t+tinc;
    end
end

%% Scenario 1
%travel in a straight line, accelerating to max speed, for desired distance
%Start the car at pos 0.  
% Accelerate to desired speed
% Travel to desired distance
% stop simulation when pos >= destination
% Collect and plot time, speed, and distance information
clear;
clc;

v = Vehicle;
ds = get(v,'preferredSpeed');
set(v,'targetVelocity', ds);

dest = 30;
set(v,'destination', dest); %miles

acc = get(v,'acceleration');
set(v,'targetRate', acc);

pos     = 0;
set(v,'posY', pos); %miles
n       = 1; %array index
t       = 0; %seconds
tinc    = 1; %seconds
while( pos < dest )
    [pos,vel,acc] = v.Advance(tinc); % step in 60 second increments
    fprintf('t=%d, p=%f, v=%f. a=%f\n',t,pos, vel, acc);
    
    %collect results for plots
    x(n) = t;
    p(n) = pos;
    s(n) = vel;
    a(n) = acc;
    n=n+1;
    
    t=t+tinc;
    
end

%% Scenario 2
%travel in a straight line, accelerating to max speed, for desired distance
%then decelerate
%Start the car at pos 0.  
% Accelerate to desired speed
% Travel to desired distance
% stop simulation when pos >= destination
% Collect and plot time, speed, and distance information
clear;
clc;

v = Vehicle;
ds = get(v,'preferredSpeed');
set(v,'targetVelocity', ds);

dest = 30;
set(v,'destination', dest); %miles

acc = get(v,'acceleration');
set(v,'targetRate', acc);

pos     = 0;
set(v,'posY', pos); %miles
n       = 1; %array index
t       = 0; %seconds
tinc    = 1; %seconds
while( pos < dest )
    [pos,vel,acc] = v.Advance(tinc); % step in 60 second increments
    fprintf('t=%d, p=%f, v=%f. a=%f\n',t,pos, vel, acc);
    
    %collect results for plots
    x(n) = t;
    p(n) = pos;
    s(n) = vel;
    a(n) = acc;
    n=n+1;
    
    t=t+tinc;
end

%switch over to stopping mode by decelerating
acc = get(v,'deceleration');
set(v,'targetRate', acc);

while( vel > 0 ) %wait for car to stop
    [pos,vel,acc] = v.Advance(tinc); % step in 60 second increments
    fprintf('t=%d, p=%f, v=%f. a=%f\n',t,pos, vel, acc);
    
    %collect results for plots
    x(n) = t;
    p(n) = pos;
    s(n) = vel;
    a(n) = acc;
    n=n+1;
    
    t=t+tinc;
end
