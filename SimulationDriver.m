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
global StatisticsSetup

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
SimulationSetup.TimeElapsed             = 0;

StatisticsSetup.DisplayKpp1                  = false;
StatisticsSetup.DisplayKpp2                  = false;
StatisticsSetup.DisplayKpp5                  = false;
SimParams.genTraffic                    = false;
SimParams.numLanes                      = 5;
SimParams.trafficRate                   = 5;


while ~startSimulation
    selection = menu('Main Menu',...
                    'Run KPP1 Scenario',...
                    'Run KPP2 Scenario',...
                    'Run KPP 3 & 4 Scenario',...
                    'Run KPP5 Scenario',...
                    'Run Interactive Simulation',...
                    'Run Batched Simulations',...
                    'Edit Simulation Parameters',...
                    'Exit');
    switch selection
        case 1
            StatisticsSetup.DisplayKpp1  = true;
            Kpp1_Generate;
            SimulationSetup.SlowLoop    = 0;
            startSimulation             = true;
            SimulationSetup.focusId     = 1;
        case 2
            StatisticsSetup.DisplayKpp2  = true;
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
            StatisticsSetup.DisplayKpp5  = true;
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
            defaultanswer={num2str(SimParams.numLanes),...
                num2str(SimParams.trafficRate),...
                num2str(SimulationSetup.SimulationRunLength),...
                num2str(SimulationSetup.SimTimeStep)};
            answer = inputdlg(prompt, 'Edit Simulation Parameters',1,...
                defaultanswer);
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
        SimulationSetup.SimulationRunLength, SimulationSetup.SimTimeStep, true);
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

isStartedKpp5 = false;
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
    
    if StatisticsSetup.DisplayKpp5  
        if isStartedKpp5 == false
            isStartedKpp5 = true;
            fprintf('Kpp5 Start = %f\n', SimulationSetup.TimeElapsed);
        end
    end
        
    if SimParams.genTraffic
        [tg, newVehicles] = TimeStep(tg);
        vm = AddVehicles(vm, newVehicles);
    end
        
    vm.TimeStep(tinc);
    cc.Update();

    if StatisticsSetup.DisplayKpp5  
        numStopped = length(find([vm.currentVehicles.velocity] <= 0.5));
        if( numStopped == 30)
            fprintf('Kpp5 Stop = %f\n', SimulationSetup.TimeElapsed);
            SimulationSetup.End = true;
        end
    end
    
    
    if sum([vm.currentVehicles.gapMode]) > 0
        tinc=tinc;
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
    
    %maintain global time elapsed
    SimulationSetup.TimeElapsed = t;
    
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
    