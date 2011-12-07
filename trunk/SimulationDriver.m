% Script Name   : SimulationDriver.m
% Version       : Managed by SVN online
% Date          : 2011/11/27
% Author        : John McAninley
% Description   : THis script is the top level script for the HSTC
% simulation
%
%
%
% Ver   Date        Author      Description  

% Initialization
close all   %close all previously opended figures
clc
clear classes


global CaravanControllerSetup
global SimulationSetup
global guiHandle

cc = CaravanController.getInstance();
vm = VehicleMgr.getInstance(5);

% Initialize variables
turnNumber = 1;
selection = 0;
simulationOver = false;
startSimulation = false;

%load default simulation setups
CaravanControllerSetup.VehicleSpacing       = 3;
CaravanControllerSetup.MaxCaravanSize       = 33;
CaravanControllerSetup.MaxCaravanSpeed      = 133;
CaravanControllerSetup.MinCaravanDistance   = 10;
CaravanControllerSetup.MaxCaravanDistance   = 100;

SimulationSetup.TrafficDensityModel     = 'normal';
SimulationSetup.SimulationRunLength     = 180;
SimulationSetup.SimulationRunUnits      = 'forever';
SimulationSetup.SimTimeStep             = 2;
SimulationSetup.SlowLoop                = 0;
SimulationSetup.focusId                 = 0;
SimulationSetup.Pause                   = false;
SimulationSetup.End                     = false;
SimulationSetup.ShowGUI                 = true;

SimParams.genTraffic                    = false;
SimParams.numLanes                      = 5;
SimParams.trafficRate                   = 100;


while ~startSimulation
    selection = menu('Main Menu',...
                    'Run KPP 1 Scenario',...
                    'Run KPP 2 Scenario',...
                    'Run KPP 3 & 4 Scenario',...
                    'Run KPP 5 Scenario',...
                    'Run Interactive Simulation',...
                    'Run Batched Simulations',...
                    'Edit Simulation Parameters',...
                    'Exit');
    switch selection
        case 1
            Kpp1_Generate;
            SimulationSetup.SlowLoop    = 0;
            startSimulation             = true;
            SimulationSetup.focusId     = 1;
        case 2
            Kpp2_Generate;
            SimulationSetup.SlowLoop    = 1;
            SimulationSetup.SimTimeStep = 0.100;
            startSimulation             = true;
            SimulationSetup.focusId     = 1;
        case 3
            KPP4();
            startSimulation             = true;
            SimulationSetup.ShowGUI     = false;
        case 4
            Kpp5_Generate;
            SimulationSetup.SlowLoop    = 1;
            SimulationSetup.SimTimeStep = 0.100;
            startSimulation             = true;
            SimulationSetup.focusId     = 4;
            SimulationSetup.ShowGUI     = true;
            vm = VehicleMgr.getInstance(SimParams.numLanes);
        case 5
            startSimulation             = true;
            SimParams.genTraffic = true;
        case 6  
            startSimulation             = true;
            SimulationSetup.ShowGUI     = false;
            SimParams.genTraffic = true;
        case 7
%             EditSimulationParameters;
            prompt= {'Number of lanes:' ...
                'Traffic Arrival Rate (vehicles/hr/lane):' ...
                'Simulation Run Length (s):' ...
                'Simulation Time Step (s):'};
            answer = inputdlg(prompt, 'Edit Simulation Parameters');
            SimParams.numLanes = str2num(answer{1});
            SimParams.trafficRate = str2num(answer{2});
            SimulationSetup.SimulationRunLength = str2num(answer{3});
            SimulationSetup.SimTimeStep = str2num(answer{4});
            
            SimParams.genTraffic = true;
            
            vm = VehicleMgr.getInstance(SimParams.numLanes);
        case 8
            close all
            return
    end
end

close all;

%do some setups

if SimParams.genTraffic
    tg = TrafficGen;
    tg = InitTraffic (tg, SimParams.numLanes, SimParams.trafficRate, ...
        100, SimulationSetup.SimTimeStep, true);
end

simulationOver = false;

% Note - if the user selected Play game from the GUI Menu,
% the flow of the program will fall through to here.   Once
% in this loop, we will stay in this loop until the user chooses to 
% exit the game

%capture start time
startTime   = clock;  
t           = 0;
tinc        = SimulationSetup.SimTimeStep; %seconds

if SimulationSetup.ShowGUI
    guiHandle = GUI;
    setappdata(guiHandle,'vm',vm);
    GUI('updateGUI');
    
    gh=guihandles(guiHandle);

    if SimulationSetup.focusId > 0
       set(gh.focusCheckbox, 'Value', 1);
       set(gh.focusSelector, 'Value', SimulationSetup.focusId); 
    end
end

while ~simulationOver
    tic
    if SimulationSetup.End == true
        break;
    end
    
    if SimulationSetup.Pause == true
        pause(1);
        if SimulatioNSetup.ShowGUI
            GUI('updateGUI');
        end
        continue;
    end
    
    if SimParams.genTraffic
        [tg, newVehicles] = TimeStep(tg);
        vm = AddVehicles(vm, newVehicles);
    end
        
    vm.TimeStep(tinc);
    cc.Update();
    
    if sum([vm.currentVehicles.gapMode]) > 0
        tinc=2;
%         SimulationSetup.SlowLoop = 1;
    else
%         tinc=SimulationSetup.SimTimeStep;
    end
% %     fprintf('%d, ',sum([vm.currentVehicles.gapMode]) );
% %     for i= 1:10
% %         fprintf('%f, ', vm.currentVehicles(i).posY);
% %     end
% %     fprintf('\n');
    %check for exit conditions
    if strcmp(SimulationSetup.SimulationRunUnits, 'Seconds')
        if etime(clock, startTime) > SimulationSetup.SimulationRunLength
            disp('Time Expired...');
            simulationOver = true;
        end
    else
    end
    turnNumber = turnNumber+ 1;
    t = t + tinc;
    
    if SimulationSetup.ShowGUI
        setappdata(guiHandle,'vm',vm);
        GUI('updateGUI');
    end
    
    elapsedTime=toc;
    if SimulationSetup.SlowLoop
        pause(tinc-elapsedTime);
    end
    
end

disp('End of simulation');
    