%% Varying BCL and plot APD90
clear
ignoreFirst = 0;

%% 800 ms for 50 beats
param.bcl = 800;

%param.Vuni_Multiplier = 10; 

% HF conditions
param.VNaCa_Multiplier = 1.3;
param.ICaL_Multiplier = 1.2;
param.Jup_Multiplier = 0.23;
param.Ito_Multiplier = 0.5;
param.IKr_Multiplier = 0.5;
param.IKs_Multiplier = 0.5;
param.IK1_Multiplier = 0.5;
param.IKb_Multiplier = 0.5;

beats = 50;
options = [];
X0 = getStartingState('Torord_endo');
[time, X] = modelRunner(X0, options, param, beats, ignoreFirst);
currents1 = getCurrentsStructure(time, X, param, 0);

for n = 1:1:beats
    ind1 = find(currents1.time >= (n-1)*param.bcl,1,'first');
    ind2 = find(currents1.time >= n*param.bcl,1,'first');
    time = currents1.time(ind1:ind2);
    V = currents1.V(ind1:ind2);
    [APD,t90] = APD90(time,V);
    t_90(n) = APD;
    t(n) = t90;
end

%% 500 ms for 50 beats
lastX_cell=X(end); lastX = cell2mat(lastX_cell); X02 = lastX(end,:);
param2 = param;
param2.bcl = 500;
beats2 = 50; 
[time2, X2] = modelRunner(X02, options, param2, beats2, ignoreFirst);
currents2 = getCurrentsStructure(time2,X2,param2,0);

for n = 1:1:beats2
    ind1 = find(currents2.time >= (n-1)*param2.bcl,1,'first');
    ind2 = find(currents2.time >= n*param2.bcl,1,'first');
    time = currents2.time(ind1:ind2)+currents1.time(end);
    V = currents2.V(ind1:ind2);
    [APD,t90] = APD90(time,V);
    t_90(n+beats) = APD;
    t(n+beats) = t90;
end

%% 300 ms for 50 beats
lastX2_cell = X2(end); lastX2 = cell2mat(lastX2_cell); X03 = lastX2(end,:);
param3 = param;
param3.bcl = 300;
beats3 = 50;
[time3, X3] = modelRunner(X03,options,param3,beats3,ignoreFirst);
currents3 = getCurrentsStructure(time3,X3,param3,0);

for n = 1:1:beats3
    ind1 = find(currents3.time >= (n-1)*param3.bcl,1,'first');
    ind2 = find(currents3.time >= n*param3.bcl,1,'first');
    time = currents3.time(ind1:ind2)+currents1.time(end)+currents2.time(end);
    V = currents3.V(ind1:ind2);
    [APD,t90] = APD90(time,V);
    t_90(n+beats+beats2) = APD;
    t(n+beats+beats2) = t90;
end

%% 800 ms for 50 beats
lastX3_cell = X3(end); lastX3 = cell2mat(lastX3_cell); X04 = lastX3(end,:);
param4 = param;
param4.bcl = 800;
beats4 = 50;
[time4,X4] = modelRunner(X04,options,param4,beats4,ignoreFirst);
currents4 = getCurrentsStructure(time4,X4,param4,0);

for n = 1:1:beats4
    ind1 = find(currents4.time >= (n-1)*param4.bcl,1,'first');
    ind2 = find(currents4.time >= n*param4.bcl,1,'first');
    time = currents4.time(ind1:ind2)+currents1.time(end)+currents2.time(end)+currents3.time(end);
    V = currents4.V(ind1:ind2);
    [APD,t90] = APD90(time,V);
    t_90(n+beats+beats2+beats3) = APD;
    t(n+beats+beats2+beats3) = t90;
end

%% Plot APD90 and time
plot(t./1000,t_90);
xlabel('Time (s)');
ylabel('APD90 (ms)');
title('APD90 with Varying BCL');
%legend('WT','1/10 Vuni','10 Vuni');
legend('WT','HF');

hold on

%% APD90 calculator
function [y,t90] = APD90(time, V)
    for j = 1:length(time)-1
        diff(j,1) = (V(j+1)-V(j))/(time(j+1)-time(j));
    end
    maxdiff = max(diff);
    startind = 1+find(diff == maxdiff,1);
    value90 = max(V)-0.9*(max(V)-V(1));
    endind = find(V >= value90,1,'last');
    t90 = time(endind);
    y = time(endind) - time(startind);
end