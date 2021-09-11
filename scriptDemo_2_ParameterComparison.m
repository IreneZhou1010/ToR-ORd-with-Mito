% A script showing a common-case use of the model's functions when multiple
% simulations are to be run. In this case, we plot simulation outputs for 5
% different multipliers of IKr (corresponding to 80, 90, 100, 110, and 120
% percent availability).
%% Setting parameters
clear 
% param is the default model parametrization here
param.bcl = 1000;
param.model = @model_Torord;
param.Vuni_Multiplier = 0.3; 

% A list of multipliers
%ICaLMultiplier = [0.5 1 2];
VuniMultiplier = [0.1 0.5 1 5 10];

% Here, we make an array of parameter structures
params(1:length(VuniMultiplier)) = param; % These are initially all the default parametrisation

% And then each is assigned a different IKr_Multiplier
for iParam = 1:length(VuniMultiplier)
    params(iParam).Vuni_Multiplier = VuniMultiplier(iParam); % because of this line, the default parametrisation needs to have IKr_Multiplier defined (otherwise Matlab complains about different structure type).
end


options = [];
beats = 50;
ignoreFirst = beats - 1;

%% Simulation and output extraction

% Now, the structure of parameters is used to run multiple models in a
% parallel-for loop.
parfor i = 1:length(params) 
    X0 = getStartingState('Torord_endo');
    [time{i}, X{i}] = modelRunner(X0, options, params(i), beats, ignoreFirst);
    currents{i} = getCurrentsStructure(time{i}, X{i}, params(i), 0);
end


%% Calculate APD90 for WT
t90 = APD90(params,currents);

%% Simulating HF
% param2.model = @model_Torord;
% 
% % param2.Vuni_Multiplier = 0.1; % reduced Vuni
% 
% % HF
% param2.VNaCa_Multiplier = 1.3;
% param2.ICaL_Multiplier = 1.2;
% param2.Jup_Multiplier = 0.23;
% param2.Ito_Multiplier = 0.5;
% param2.IKr_Multiplier = 0.5;
% param2.IKs_Multiplier = 0.5;
% param2.IK1_Multiplier = 0.5;
% param2.IKb_Multiplier = 0.5;
% 
% % A list of multipliers
% %ICaLMultiplier = [0.5 1 2];
% bcl = [200 300 500 800 1000 1200 1500 2000];
% 
% % Here, we make an array of parameter structures
% params2(1:length(bcl)) = param2; % These are initially all the default parametrisation
% 
% % And then each is assigned a different IKr_Multiplier
% for iParam = 1:length(bcl)
%     params2(iParam).bcl = bcl(iParam); % because of this line, the default parametrisation needs to have IKr_Multiplier defined (otherwise Matlab complains about different structure type).
% end
% 
% options = [];
% beats = 50;
% ignoreFirst = beats - 1;
% 
% parfor i = 1:length(params2) 
%     X0 = getStartingState('Torord_endo');
%     [time{i}, X{i}] = modelRunner(X0, options, params2(i), beats, ignoreFirst);
%     currents2{i} = getCurrentsStructure(time{i}, X{i}, params2(i), 0);
% end
% 
% %% Calculate APD90 for HF
% t90_HF = APD90(params2,currents2);
% 
% %% Restitution
% plot(bcl,t90);
% hold on
% plot(bcl,t90_HF);
% xlabel('BCL (ms)');
% ylabel('APD90 (ms)');
% title('Restitution Curve');
% legend('WT','HF');

%% Plotting APs
%figure(1); clf
for i = 1:length(params)
    hold on
    figure(1)
    plot(currents{i}.time, currents{i}.V);
    title('Exploration of Vuni Multiplier');
    legend('0.1', '0.5', '1', '5', '10');
    xlabel('Time (ms)');
    ylabel('Membrane potential (mV)');
    xlim([0 1000]);

    
%     hold on
%     figure(2)
%     plot(currents{i}.time, currents{i}.camit.*10^3);
%     title('Exploration of I_{CaL} multiplier');
%     legend('0.5', '1', '2');
%     xlabel('Time (ms)');
%     ylabel('[Ca]_{mit} (uM)');
%     xlim([0 500]);
%     
    hold on
    figure(2)
    plot(currents{i}.time, currents{i}.INaCamit.*10^6);
    title('Exploration of Vuni Multiplier');
    legend('0.1', '0.5', '1', '5', '10');
    xlabel('Time (ms)');
    ylabel('VNaCa_{mit} (nM/ms)');
    xlim([0 500]);
%     
%     hold on
%     figure(4)
%     plot(currents{i}.time, currents{i}.ICauni.*10^3);
%     title('Exploration of I_{CaL} multiplier');
%     legend('0.5', '1', '2');
%     xlabel('Time (ms)');
%     ylabel('Vuni_{mit} (uM/ms)');
%     xlim([0 500]);
% 
%     %hold off
end

function y = APD90(params,currents)
for i = 1:length(params)
    for j = 1:length(currents{i}.time)-1
        diff(j,1) = (currents{i}.V(j+1)-currents{i}.V(j))/(currents{i}.time(j+1)-currents{i}.time(j));
    end
    maxdiff = max(diff);
    startind = 1+find(diff == maxdiff,1);
    value90 = max(currents{i}.V)-0.9*(max(currents{i}.V)-currents{i}.V(1));
    endind = find(currents{i}.V >= value90,1,'last');
    y(i,1) = currents{i}.time(endind) - currents{i}.time(startind);
end
end
