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
clear
clear all

global CaravanControllerSetup
global SimulationSetup
global guiHandle
% Initialize variables
turnNumber = 1;
selection = 0;
simulationOver = false;
startSimulation = false;

tinc    = 2; %seconds

%load default simulation setups
CaravanControllerSetup.VehicleSpacing       = 3;
CaravanControllerSetup.MaxCaravanSize       = 33;
CaravanControllerSetup.MaxCaravanSpeed      = 133;
CaravanControllerSetup.MinCaravanDistance   = 10;
CaravanControllerSetup.MaxCaravanDistance   = 100;

SimulationSetup.TrafficDensityModel     = 'normal';
SimulationSetup.SimulationRunLength     = 180;
SimulationSetup.SimulationRunUnits      = 'Seconds';
SimulationSetup.Pause                   = false;
SimulationSetup.End                   = false;

while ~startSimulation
    selection = menu('Main Menu',...
                    'Run KPP1 Scenario',...
                    'Run KPP2 Scenario',...
                    'Run KPP3 Scenario',...
                    'Run KPP4 Scenario',...
                    'Run KPP5 Scenario',...
                    'Run Interactive Simulation',...
                    'Run Batched Simulations',...
                    'Edit Simulation Parameters',...
                    'Exit');
    switch selection
        case 1
            Kpp1_Generate;
            startSimulation = true;
        case 2
            Kpp2_Generate;
            startSimulation = true;
        case 3
            Kpp3_Generate;
            startSimulation = true;
        case 4
            Kpp4_Generate;
            startSimulation = true;
        case 5
            Kpp5_Generate;
            startSimulation = true;
        case 6
            startSimulation = true;
        case 7  
            startSimulation = true;
        case 8
            EditSimulationParameters;
        case 9
            close all
            return
    end
end

close all;

%do some setups

simulationOver = false;

% Note - if the user selected Play game from the GUI Menu,
% the flow of the program will fall through to here.   Once
% in this loop, we will stay in this loop until the user chooses to 
% exit the game

%capture start time
startTime = clock;  
t = 0;

guiHandle = GUI;
setappdata(guiHandle,'vm',vm);
GUI('updateGUI')

while ~simulationOver
    tic
    if SimulationSetup.End == true
        break;
    end
    
    if SimulationSetup.Pause == true
        pause(1);
        GUI('updateGUI')
        continue;
    end
        
    vm.TimeStep(tinc);
    cv.Update();
    
    %check for exit conditions
    if SimulationSetup.SimulationRunUnits == 'Seconds'
        if etime(clock, startTime) > SimulationSetup.SimulationRunLength
            simulationOver = True;
        end
    else
    end
    turnNumber = turnNumber+ 1;
    t = t + tinc;
    
    setappdata(guiHandle,'vm',vm);
    GUI('updateGUI')
    
    %for Kpp1 and 2, follow caravan
    gh=guihandles(guiHandle);
    step = str2double(get(gh.edit1,'String'));
    range = str2double(get(gh.edit2,'String'));
    xlim([step*fix(vm.currentVehicles(1).posY/step)-range/2 step*fix(vm.currentVehicles(1).posY/step)+range/2]);

    elapsedTime=toc;
    %pause(tinc-elapsedTime);
    
end

GUI;
disp('End of simulation');
    