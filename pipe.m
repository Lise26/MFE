clearvars; clc; close all;

nb_patients = 40;

results = zeros(nb_patients, 1799);
param = EEGData.empty(nb_patients,0);
c = 1;

for i=1:nb_patients
% for i=[1, 2, 21, 22]
    if i < 10
        file_name = "Files/0" + i + "/";
    else
        file_name = "Files/" + i + "/";
    end

    param(i) = predict(file_name, 8, "cc", "threshold");
    %results(c, :) = par(1).Density;
    %c = c + 1;
end

density_ep = zeros(nb_patients, 1);
cluster_ep = zeros(nb_patients, 1);
charpath_ep = zeros(nb_patients, 1);
largcomp_ep = zeros(nb_patients, 1);
charpathlc_ep = zeros(nb_patients, 1);
indcomp_ep = zeros(nb_patients, 1);

% Vectors of parameters for epilpetic patients
for i=1:20
    density_ep(i) = param(i).Av_density;
    cluster_ep(i) = param(i).Av_clustering_coeff;
    charpath_ep(i) = param(i).Av_char_path_length;
    largcomp_ep(i) = param(i).Av_size_larg_comp;
    charpathlc_ep(i) = param(i).Av_char_path_length_lc;
    indcomp_ep(i) = param(i).Av_nb_ind_comp;
end

density_h = zeros(nb_patients, 1);
cluster_h = zeros(nb_patients, 1);
charpath_h = zeros(nb_patients, 1);
largcomp_h = zeros(nb_patients, 1);
charpathlc_h = zeros(nb_patients, 1);
indcomp_h = zeros(nb_patients, 1);

% Vectors of parameters for healthy patients
for i=21:40
    density_h(i) = param(i).Av_density;
    cluster_h(i) = param(i).Av_clustering_coeff;
    charpath_h(i) = param(i).Av_char_path_length;
    largcomp_h(i) = param(i).Av_size_larg_comp;
    charpathlc_h(i) = param(i).Av_char_path_length_lc;
    indcomp_h(i) = param(i).Av_nb_ind_comp;
end


disp("DENSITY")
h = ttest2(density_ep,density_h);
if h == 0
    disp("From epileptic and healthy come from the same distribution")
else
    disp("From epileptic and healthy come from different distributions")
end
disp("CLUSTERING COEFFICIENT")
h = ttest2(cluster_ep,cluster_h);
if h == 0
    disp("From epileptic and healthy come from the same distribution")
else
    disp("From epileptic and healthy come from different distributions")
end
disp("CHAR PATH LENGTH")
h = ttest2(charpath_ep,charpath_h);
if h == 0
    disp("From epileptic and healthy come from the same distribution")
else
    disp("From epileptic and healthy come from different distributions")
end
disp("SIZE OF LC")
h = ttest2(largcomp_ep,larg_comp_h);
if h == 0
    disp("From epileptic and healthy come from the same distribution")
else
    disp("From epileptic and healthy come from different distributions")
end
disp("CHAR PATH LENGTH OF LC")
h = ttest2(charpathlc_ep,charpathlc_h);
if h == 0
    disp("From epileptic and healthy come from the same distribution")
else
    disp("From epileptic and healthy come from different distributions")
end
disp("NUMBER OF INDEPENDENT COMPONENTS")
h = ttest2(indcomp_ep,indcomp_h);
if h == 0
    disp("From epileptic and healthy come from the same distribution")
else
    disp("From epileptic and healthy come from different distributions")
end

%{
disp("DENSITY")
h = ttest2(results(1,:),results(2,:));
if h == 0
    disp("From 1 and 2 come from the same distribution")
else
    disp("From 1 and 2 come from different distributions")
end
h = ttest2(results(1,:),results(3,:));
if h == 0
    disp("From 1 and 21 come from the same distribution")
else
    disp("From 1 and 21 come from different distributions")
end
h = ttest2(results(1,:),results(4,:));
if h == 0
    disp("From 1 and 22 come from the same distribution")
else
    disp("From 1 and 22 come from different distributions")
end
h = ttest2(results(2,:),results(3,:));
if h == 0
    disp("From 2 and 21 come from the same distribution")
else
    disp("From 2 and 21 come from different distributions")
end
h = ttest2(results(2,:),results(4,:));
if h == 0
    disp("From 2 and 22 come from the same distribution")
else
    disp("From 2 and 22 come from different distributions")
end
h = ttest2(results(3,:),results(4,:));
if h == 0
    disp("From 21 and 22 come from the same distribution")
else
    disp("From 21 and 22 come from different distributions")
end

figure();
plot(results(1,:))
hold on
plot(results(2,:))
hold on
plot(results(3,:))
hold on
plot(results(4,:))
xlabel('Time (in ms)')
title('Clustering coefficients')
set(gcf, 'units','normalized','outerposition',[0 0 1 1])
%}


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
        wind = wind.network(eeg.Data, w, assoc, s_test);

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

    disp ("----- Brain connectivity parameters -----")
    disp(eeg.Av_density)
    disp(eeg.Av_clustering_coeff)
    disp(eeg.Av_char_path_length)
    disp(eeg.Av_size_larg_comp)
    disp(eeg.Av_char_path_length_lc)
    disp(eeg.Av_nb_ind_comp)

    % av = [eeg.Av_density, eeg.Av_clustering_coeff, eeg.Av_char_path_length, eeg.Av_size_larg_comp, eeg.Av_char_path_length_lc, eeg.Av_nb_ind_comp];
    % params = [eeg.Density, eeg.Clustering_coeff, eeg.Char_path_length, eeg.Size_larg_comp, eeg.Char_path_length_lc, eeg.Nb_ind_comp];

    % save('params', params)

end