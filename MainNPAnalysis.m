%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% MAIN NEUROPIXEL ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Analysis and Figures for Kilosort Data output %%%%%%%%%%%%%%%%
%%%%%%%%% Authors: Salif Komi 
%%%%%%%%% Last Edition : 22.2.2022
clear all           
close all
clc
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% SET ANALYSIS PARAMETERS HERE %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Generate Data Option Structure
Ops = struct();
%%%% Options Regarding the trial to analyse

Ops.TotTrial = 1;
Ops.Trial = [1]; % Format this as [the recordings ref# to include]

%%%% Flags for Loading %%%
%%% Flag Neurpixel Related %%%
Ops.flagspike = 1; % Flag to load and process spiking data. MUST BE 1
Ops.flaglfp = 0;
%%% Flag Intan Related %%%
Ops.flagrec = 0;
Ops.flagstim = 0; % Flag to load and process kinematic data. is 1 if kin csv
Ops.flagacc = 0;
Ops.flagneural = 0; % Data recorded on ADC of intan
%%% Other Flags %%%
Ops.flagusecombined = 0;
Ops.flagvid = 0;
Ops.flagkin = 0;

%%%%%% Dataset Parameters %%%%%%
Ops.fs = 30000; % Neural + Stim + Acc Data Acquisition Sampling Rate 
Ops.vfr = 25; % Video Sampling FrameRate
Ops.kfs = 150; % Kinematic Sampling Rate

%%%% Spatial Analysis Param %%%%
Ops.s_min = 0; % lower bound on spatial percentage of the probe
Ops.s_max = 100; % upper bound on spatial percentage of the probe

%%%% Temporal Analysis Param %%%
Ops.t_min = 0; %100*(min(Ops.Trial)-1)/Ops.TotTrial; % ALWAYS SPECIFY TEMPORAL BOUNDARIES (What part of the file will be processed
Ops.t_max = 100;%100*(max(Ops.Trial))/Ops.TotTrial;

%%% Kinematcic Analysis Param %%
Ops.Koffset = 254044; % Realignement Offset For Kinematic

%%% Spiking PreProcessing Parameters
Ops.Thresh =  20; % Minimum Firing Rate to Analyse In pulse/s
Ops.PhaseSortingMethod = 'Correlation'; % Method to use to sort unit phase
Ops.GaussianSmoothness = 50; % Width of gaussian filter in ms;
Ops.screensize = get(groot,'ScreenSize');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LOAD DATASET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Load Data Set - Open Dialog Box and search for data for interest %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Folder = uigetdir(); %% Always a recording 
[Data,Ops] = LoadData(Folder,Ops);

%% %%%%%%%%%%%%%%%%%%%%%%%% PreProcess Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
[Data,Ops] = PreProcessDataset(Data,Ops);
%% %%%%%%%%%%%%%%%%%%%%%%%%% Sanity checks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PlotOrderedRaster(Data,Ops,'Mode','Channels','Save',0)
%PlotSanityCheck
%% %%%%%%%%%%%%%%%%%%%%%%%%% START ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%  Plot Spatial
%AnalysisSpatial

%%% Plot Autocorrelogram 

%%% Per Cycles
%AnalysisPerCycles

%%% Per Stim 
%AnalysisPerStim

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAKE VIDEO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MakeThetaVideo 