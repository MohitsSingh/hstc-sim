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

global CaravanControllerSetup
global SimulationSetup
% Initialize variables
turnNumber = 1;
    
selection = 0;
simulationOver = false;
startSimulation = false;
% DisplayOptions.ShowCommsRange = false;      %show radius for commmunications
% DisplayOptions.ShowVisualRange = false;     %show radius for visibility
% DisplayOptions.ShowCombatRange = false;     %show radius for combat range
% DisplayOptions.ShowEnemyTroops = false;     %show lcoation of enemy troops
% DisplayOptions.toolbar = 0;                 %initialize toolbar to null

while ~startSimulation
    selection = menu('Main Menu',...
                    'Run Interactive Simulation',...
                    'Run Batched Simulations',...
                    'Edit Simulation Parameters',...
                    'Exit');
    switch selection
        case 1
            startSimulation = true;
        case 2
            startSimulation = true;
        case 3  %Setup
            EditSimulationParameters;
        case 4
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

while ~simulationOver

    %check for end condition
    if SimulationSetup.SimulationRunUnits == 'Seconds'
        if etime(clock, startTime) > SimulationSetup.SimulationRunLength
            simulationOver = True;
        end
    else
    end
    turnNumber = turnNumber+ 1;
end

disp('End of simulation');
    