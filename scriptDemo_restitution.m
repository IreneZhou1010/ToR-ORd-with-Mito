%% Diastolic interval vs. APD90
clear

%% Baseline run: 100 beats with BCL = 1000 ms
param.bcl = 1000; % basic cycle length in ms
param.model = @model_Torord; % which model is to be used - right now, use @model_Torord. In general, any model with the same format of inputs/outputs as @model_Torord may be simulated, which is useful when current formulations are changed within the model code, etc.
param.verbose = true; % printing numbers of beats simulated.

%param.Vuni_Multiplier = 10;
%param.VNaCa_Multiplier = 10;

% HF conditions
% param.VNaCa_Multiplier = 1.3;
% param.ICaL_Multiplier = 1.2;
% param.Jup_Multiplier = 0.23;
% param.Ito_Multiplier = 0.5;
% param.IKr_Multiplier = 0.5;
% param.IKs_Multiplier = 0.5;
% param.IK1_Multiplier = 0.5;
% param.IKb_Multiplier = 0.5;

options = []; % parameters for ode15s - usually empty
beats = 100; % number of beats
ignoreFirst = beats - 1; % this many beats at the start of the simulations are ignored when extracting the structure of simulation outputs (i.e., beats - 1 keeps the last beat).

X0 = getStartingState('Torord_endo');
[time, X] = modelRunner(X0, options, param, beats, ignoreFirst);
currents = getCurrentsStructure(time, X, param, 0);

% Get new starting conditions
lastCell = cell2mat(X(end));
X02 = lastCell(end,:);

%% Varying DI
ind = 1;
for i = 400:10:1000 % varying BCL; 600:10:1200 for HF
    param2 = param;
    param2.bcl = i;
    beats2 = 1;
    ignoreFirst = beats2 - 1;
    
    [time2,X2] = modelRunner(X02,options,param2,beats2,ignoreFirst);
    currents2 = getCurrentsStructure(time2, X2, param2, 0);
    DI(ind) = i-APD90(currents2);
    
    lastCell = cell2mat(X2(end));
    X03 = lastCell(end,:);
    
    param3 = param;
    param3.bcl = 1000;
    beats3 = 1;
    ignoreFirst = beats3 - 1;
    [time3,X3] = modelRunner(X03,options,param3,beats3,ignoreFirst);
    currents3 = getCurrentsStructure(time3, X3, param3, 0);
    
    t90(ind) = APD90(currents3);
    
    ind = ind+1;
    
end

%% Plotting
figure(1)
plot(currents3.time, currents3.V);
xlabel('Time (ms)');
ylabel('Voltage (mV)');
title('Cell Membrane Potential');
legend('WT','1/10 Vuni','10 Vuni');
%legend('WT','HF');

hold on

figure(2)
plot(DI,t90);
xlabel('DI (ms)');
ylabel('APD90 (ms)');
title('Restitution Curve');
legend('WT','1/10 Vuni','10 Vuni');
%legend('WT','HF');

hold on

%% APD90 calculator
function y = APD90(currents)
    for j = 1:length(currents.time)-1
        diff(j,1) = (currents.V(j+1)-currents.V(j))/(currents.time(j+1)-currents.time(j));
    end
    maxdiff = max(diff);
    startind = 1+find(diff == maxdiff,1);
    value90 = max(currents.V)-0.9*(max(currents.V)-currents.V(1));
    endind = find(currents.V >= value90,1,'last');
    y = currents.time(endind) - currents.time(startind);
end
