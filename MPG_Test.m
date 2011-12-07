%Can check against values from:
%http://ecomodder.com/forum/tool-aero-rolling-resistance.php

for i=5:5:120
   v = Vehicle;
   v.velocity = i;
   CalculateMPG(v, -1);
   disp([num2str(i), ' ', num2str(v.fuelEconomy)])
end