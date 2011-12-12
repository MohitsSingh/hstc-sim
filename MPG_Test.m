%Can check against values from:
%http://ecomodder.com/forum/tool-aero-rolling-resistance.php

xlabel('Velocity (mph)');
ylabel('Fuel economy (mpg)');
hold on;
for i=5:5:120
   v = Vehicle;
   v.velocity = i;
   CalculateMPG(v, -1);
   mpg = v.fuelEconomy;
   
   scatter(v.velocity, mpg,3,[.5 0 0],'filled');
   hold on;
   
   disp([num2str(i), ' ', num2str(v.fuelEconomy)])
end