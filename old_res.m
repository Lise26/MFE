clearvars; clc; close all;

file = "Files/40/"; 
param = predict(file, 8, "cc", "stat");

figure();
subplot(6,1,1)
plot(param.Density)
title("Network Density")

subplot(6,1,2)
plot(param.Clustering_coeff)
title("Mean Clustering Coefficient")

subplot(6,1,3)
plot(param.Char_path_length)
title("Characteristic Path Length")

subplot(6,1,4)
plot(param.Size_larg_comp)
title("Size of the Largest Component")

subplot(6,1,5)
plot(param.Char_path_length_lc)
title("Characteristic Path Length of the Largest Component")

subplot(6,1,6)
plot(param.Nb_ind_comp)
title("Number of components")

set(gcf, 'units','normalized','outerposition',[0 0 1 1])

disp(param.Av_density)
disp(param.Av_clustering_coeff)
disp(param.Av_char_path_length)
disp(param.Av_size_larg_comp)
disp(param.Av_char_path_length_lc)
disp(param.Av_nb_ind_comp)
disp(param.Av_degree)
disp(param.Small_world)  

% MAIN FUNCTION
% Inputs: 
%   - EEG_file: EEG of the patient for which the indicator is asked
%       format: folder with 2 files: EEG.mat and Header.mat
%               EEG with 24 channels
%   - asociation measure: the choice of association measure between nodes
%       can be: "cc", "corr_cc" or "wPLI"
%       REM: put the best one by default
%   - matrix: the choice of association matrix construction method
% Output: 
%   - indicator: number between 1 and 100 indicating the probability of 
%       the patient to face epileptic seizure(s)

function eeg = predict(EEG_folder, ref, assoc_measure, matrix_constr)
    
    % Creation of the eeg object
    EEG_file = EEG_folder + "EEG.mat";
    EEG_header = EEG_folder + "Header.mat";
    
    load(EEG_file);
    load(EEG_header);

    chan = size(EEG, 2) - 5; % have something more reusable ?
    points = size(EEG, 1);
    fs = Header.Fs;
    eeg = EEGData(EEG, chan, points, fs, ref);

    % Options
    % By default: cross-correlation
    if assoc_measure == "corr_cc"
        assoc = correctedCrossCorrelation();
    elseif assoc_measure == "wPLI"
        assoc = wPLI();
    else
        assoc = crossCorrelation();
    end

    % By default: statistical test
    s_test = true;
    if matrix_constr == "threshold"
        s_test = false;
    end

    %%%%%%%%%%%%%%%%%%
    % PRE PROCESSING %
    %%%%%%%%%%%%%%%%%%

    low_freq = 0.5;         
    high_freq = 30;
    eeg = eeg.preprocessing(low_freq, high_freq);
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    % NETWORK CONSTRUCTION %
    %%%%%%%%%%%%%%%%%%%%%%%%  
    
    % Windowing - Creation of the window object
    length_window = 250;
    overlap = 125;
    max_lag = 50;
    wind = window(length_window, overlap, max_lag);
    eeg = eeg.init_parameters(wind);
    c = 1;

    for w=wind.Length-wind.Overlap:wind.Overlap:eeg.Points-(wind.Overlap+wind.Length)
        wind = wind.network(eeg.Data, w, assoc, s_test, false);

        %%%%%%%%%%%%%%%%%%%%%%%%%
        % PARAMETERS EXTRACTION %
        %%%%%%%%%%%%%%%%%%%%%%%%%

        % compute the network parameters of the window
        wind = wind.parameters();
        % keep track of the parameters of each window
        eeg = eeg.WIND_parameters(wind, c);
        c = c+1;
    end

    % Average of the parameters on all windows
    eeg = eeg.EEG_parameters();

end