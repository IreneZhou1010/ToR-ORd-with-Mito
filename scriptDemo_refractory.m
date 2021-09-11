%% Refractory period curve
clear

%% 
param.bcl = 1000;
beats = 50;

options = [];
X0 = getStartingState('Torord_endo');
ignoreFirst = 0;
[time, X] = modelRunner(X0, options, param, beats, ignoreFirst);
currents = getCurrentsStructure(time, X, param, 0);

%% 
plot(currents.time, currents.V);