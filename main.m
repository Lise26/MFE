
% INPUT: file, asociation measure, threshold/stat test
% OUTPUT: indicator

clearvars; clc; close all;
load Files/01/EEG.mat;

%%%%%%%%%%%%%%%%%%
% PRE PROCESSING %
%%%%%%%%%%%%%%%%%%

chan = 19;
points = 225250; % 225000 for file 05
low_freq = 0.5;         
high_freq = 30;
fs = 250;
ref = 8;

eeg = EEGData(EEG, chan, points, low_freq, high_freq, fs, ref);
eeg = eeg.preprocessing();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NETWORK CONSTRUCTION and PARAMETERS EXTRACTION %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

length_window = 250;
overlap = 125;
max_lag = 50;

wind = window(length_window, overlap, max_lag);

cross = crossCorrelation;
param_cross = eeg.EEG_parameters(eeg.Data, wind, cross, false);
param_corr = eeg.EEG_parameters(eeg.Data, wind, cross, true);

disp ("----- Cross correlation -----")
disp(param_cross.Density)
disp(param_cross.Clustering_coeff)
disp(param_cross.Char_path_length)
disp(param_cross.Size_larg_comp)
disp(param_cross.Char_path_length_lc)
disp(param_cross.Nb_ind_comp)

disp ("----- Corrected cross correlation -----")
disp(param_corr.Density)
disp(param_corr.Clustering_coeff)
disp(param_corr.Char_path_length)
disp(param_corr.Size_larg_comp)
disp(param_corr.Char_path_length_lc)
disp(param_corr.Nb_ind_comp)