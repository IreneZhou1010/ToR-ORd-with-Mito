% This is a simple script which runs the control endocardial model for 100
% beats and plots membrane potential and calcium transient.

%% Setting parameters
clear 

% Param is the structure of model parameters that the user may wish to
% change compared to default simulation. The full list is given in the
% function ORdRunner, and it mainly includes cell type, current
% multipliers, extracellular ionic concentrations, or fraction of NCX and ICaL
% localisation in junctional subspace.

param.stimAmp = 0;


%param.INa_fractionSS2 = 0.1;
%param.INaCa_fractionSS2 = 0.35;
%param.Vuni_Multiplier = 0.1; 
%param.VNaCa_Multiplier = 10;

%% Changes for Heart Failure (HF)
% param.VNaCa_Multiplier = 1.3;
% param.ICaL_Multiplier = 1.2;
% param.Jup_Multiplier = 0.23;
% param.Ito_Multiplier = 0.5;
% param.IKr_Multiplier = 0.5;
% param.IKs_Multiplier = 0.5;
% param.IK1_Multiplier = 0.5;
% param.IKb_Multiplier = 0.5;
%%

param.bcl = 1000; % basic cycle length in ms
param.model = @model_Torord; % which model is to be used - right now, use @model_Torord. In general, any model with the same format of inputs/outputs as @model_Torord may be simulated, which is useful when current formulations are changed within the model code, etc.
param.verbose = true; % printing numbers of beats simulated.

options = []; % parameters for ode15s - usually empty
beats = 1; % number of beats
ignoreFirst = beats - 1; % this many beats at the start of the simulations are ignored when extracting the structure of simulation outputs (i.e., beats - 1 keeps the last beat).

X0 = getStartingState('Torord_endo'); % starting state - can be also Torord_mid or Torord_epi for midmyocardial or epicardial cells respectively.

%% Simulation and extraction of outputs

% The structure param and other variables are passed to modelRunner, which is
% an interface between user and the simulation code itself (which is in
% model_Torord.m). The modelRunner unpacks the structure of parameters given by
% the users, sets undefined parameters to default, and sends all that to
% @model_Torord.

% time, X are cell arrays corresponding to stored beats (if 1 beat is
% simulated, this is 1-by-1 cell still), giving time vectors and state
% variable values at corresponding time points.
[time, X] = modelRunner(X0, options, param, beats, ignoreFirst);

% A structure of currents is computed from the state variables (see the
% function code for a list of properties extracted - also, hitting Tab
% following typing 'currents.' lists all the fields of the structure). Some
% state variables are also stored in a named way (time, V, Cai, Cass) so
% that the user can do most of necessary plotting simply via accessing the
% structure currents as shown below. 
currents = getCurrentsStructure(time, X, param, 0);


%% Plotting Vhe, Vhu, Vant
figure(1)
plot(currents.time, currents.Vhe);
ylabel('Flux (mM/ms)')
xlabel('time (ms)')
hold on

%figure(2)
plot(currents.time, currents.Vhu);
%title('Vhu')

%figure(3)
plot(currents.time, currents.Vant);
%title('Vant')

legend('Vhe','Vhu','Vant')

%% Plotting AP, IK, ICaL
% figure(1)
% plot(currents.time, currents.V);
% xlabel('Time (ms)');
% ylabel('Voltage (mV)');
% title('Cell Membrane Potential');
% legend('Normal','HF');
% hold on
% 
% figure(2)
% plot(currents.time, currents.ICaL_i);
% xlabel('Time (ms)');
% ylabel('Current (pA/pF)');
% title('ICaL_i');
% legend('Normal','HF');
% hold on
% 
% figure(3)
% plot(currents.time, currents.IKr);
% xlabel('Time (ms)');
% ylabel('Current (pA/pF)');
% title('IKr');
% legend('Normal','HF');
% hold on

%% Plotting membrane potential and calcium transient
% figure(1);
% plot(currents.time, currents.V);
% xlabel('Time (ms)');
% ylabel('Voltage (mV)');
% title('Cell Membrane Potential');
% %xlim([0 500]);
% %legend('Normal','1/10 Vuni');
% legend('Normal','HF');
% hold on
% 
% figure(2);
% plot(currents.time, currents.Cai.*1000);
% xlabel('Time (ms)');
% ylabel('Ca_i (uM)');
% title('Intracellular Calcium Conc');
% %xlim([0 500]);
% %legend('Normal','1/10 Vuni');
% legend('Normal','HF');
% hold on
% 
% figure(3);
% plot(currents.time, currents.INaCamit.*10^6);
% title('Mitochondria NCLX Flux');
% xlabel('Time (ms)');
% ylabel('VNaCa (nM/ms)');
% %legend('Normal','1/10 Vuni');
% legend('Normal','HF');
% hold on
% 
% figure(4)
% plot(currents.time, currents.ICauni.*10^6);
% title('MCU Flux');
% ylabel('Vuni (nM/ms)');
% xlabel('Time (ms)');
% %legend('Normal','1/10 Vuni');
% legend('Normal','HF');
% hold on
% 
% figure(2)
% plot(currents.time, currents.camit.*10^6);
% title('Mitochondria Ca Concentration');
% xlabel('Time (ms)');
% ylabel('Ca_m_i_t (nM)');
% legend('Normal','1/10 Vuni');
% legend('Normal','HF');
% hold on
% 
% figure(6)
% plot(currents.time, currents.CaJSR);
% title('CaJSR');
% xlabel('Time (ms)');
% ylabel('CaJSR (mM)');
% %legend('Normal','1/10 Vuni');
% legend('Normal','HF');
% hold on