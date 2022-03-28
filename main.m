clearvars; clc; close all;

nb_patients = 1;
nb_measures = 6;

% fileID = fopen('res.txt', 'a');

results = zeros(nb_patients,nb_measures);
par = EEGData.empty(3,0);
c = 1;

for j=["cc", "corr_cc", "wPLI"]
    for i=1:nb_patients
        if i < 10
            file_name = "Files/0" + i + "/";
        else
            file_name = "Files/" + i + "/";
        end
    
        par(c) = predict(file_name, 8, j, "treshold");
    end
    c = c + 1;
end

disp("DENSITY")
h = ttest2(par(1).Density,par(2).Density);
if h == 0
    disp("From cc and corrected cc come from the same distribution")
else
    disp("From cc and corrected cc come from different distributions")
end
h = ttest2(par(1).Density,par(3).Density);
if h == 0
    disp("From cc and wPLI come from the same distribution")
else
    disp("From cc and wPLI come from different distributions")
end
h = ttest2(par(3).Density,par(2).Density);
if h == 0
    disp("From corrected cc and wPLI come from the same distribution")
else
    disp("From corrected cc and wPLI come from different distributions")
end

disp("CLUSTERING COEFFICIENT")
h = ttest2(par(1).Clustering_coeff,par(2).Clustering_coeff);
if h == 0
    disp("From cc and corrected cc come from the same distribution")
else
    disp("From cc and corrected cc come from different distributions")
end
h = ttest2(par(1).Clustering_coeff,par(3).Clustering_coeff);
if h == 0
    disp("From cc and wPLI come from the same distribution")
else
    disp("From cc and wPLI come from different distributions")
end
h = ttest2(par(3).Clustering_coeff,par(2).Clustering_coeff);
if h == 0
    disp("From corrected cc and wPLI come from the same distribution")
else
    disp("From corrected cc and wPLI come from different distributions")
end

disp("CHARACTERISTIC PATH LENGTH")
h = ttest2(par(1).Char_path_length,par(2).Char_path_length);
if h == 0
    disp("From cc and corrected cc come from the same distribution")
else
    disp("From cc and corrected cc come from different distributions")
end
h = ttest2(par(1).Char_path_length,par(3).Char_path_length);
if h == 0
    disp("From cc and wPLI come from the same distribution")
else
    disp("From cc and wPLI come from different distributions")
end
h = ttest2(par(3).Char_path_length,par(2).Char_path_length);
if h == 0
    disp("From corrected cc and wPLI come from the same distribution")
else
    disp("From corrected cc and wPLI come from different distributions")
end

disp("SIZE OF THE LARGEST COMPONENT")
h = ttest2(par(1).Size_larg_comp,par(2).Size_larg_comp);
if h == 0
    disp("From cc and corrected cc come from the same distribution")
else
    disp("From cc and corrected cc come from different distributions")
end
h = ttest2(par(1).Size_larg_comp,par(3).Size_larg_comp);
if h == 0
    disp("From cc and wPLI come from the same distribution")
else
    disp("From cc and wPLI come from different distributions")
end
h = ttest2(par(3).Size_larg_comp,par(2).Size_larg_comp);
if h == 0
    disp("From corrected cc and wPLI come from the same distribution")
else
    disp("From corrected cc and wPLI come from different distributions")
end

disp("CHARACTERISTIC PATH LENGTH OF THE LARGEST COMPONENT")
h = ttest2(par(1).Char_path_length_lc,par(2).Char_path_length_lc);
if h == 0
    disp("From cc and corrected cc come from the same distribution")
else
    disp("From cc and corrected cc come from different distributions")
end
h = ttest2(par(1).Char_path_length_lc,par(3).Char_path_length_lc);
if h == 0
    disp("From cc and wPLI come from the same distribution")
else
    disp("From cc and wPLI come from different distributions")
end
h = ttest2(par(3).Char_path_length_lc,par(2).Char_path_length_lc);
if h == 0
    disp("From corrected cc and wPLI come from the same distribution")
else
    disp("From corrected cc and wPLI come from different distributions")
end

disp("NUMBER OF INDEPENDENT COMPONENTS")
h = ttest2(par(1).Nb_ind_comp,par(2).Nb_ind_comp);
if h == 0
    disp("From cc and corrected cc come from the same distribution")
else
    disp("From cc and corrected cc come from different distributions")
end
h = ttest2(par(1).Nb_ind_comp,par(3).Nb_ind_comp);
if h == 0
    disp("From cc and wPLI come from the same distribution")
else
    disp("From cc and wPLI come from different distributions")
end
h = ttest2(par(3).Nb_ind_comp,par(2).Nb_ind_comp);
if h == 0
    disp("From corrected cc and wPLI come from the same distribution")
else
    disp("From corrected cc and wPLI come from different distributions")
end

av_cc = [par(1).Av_density, par(1).Av_clustering_coeff, par(1).Av_char_path_length, par(1).Av_size_larg_comp, par(1).Av_char_path_length_lc, par(1).Av_nb_ind_comp];
av_corr = [par(2).Av_density, par(2).Av_clustering_coeff, par(2).Av_char_path_length, par(2).Av_size_larg_comp, par(2).Av_char_path_length_lc, par(2).Av_nb_ind_comp];
av_wpli = [par(3).Av_density, par(3).Av_clustering_coeff, par(3).Av_char_path_length, par(3).Av_size_larg_comp, par(3).Av_char_path_length_lc, par(3).Av_nb_ind_comp];

figure();
plot(av_cc)
hold on
plot(av_corr)
hold on
plot(av_wpli)
xlabel("Measure of association")
title("Average parameters of the brain network")

cc = [par(1).Density, par(1).Clustering_coeff, par(1).Char_path_length, par(1).Size_larg_comp, par(1).Char_path_length_lc, par(1).Nb_ind_comp];
corr = [par(2).Density, par(2).Clustering_coeff, par(2).Char_path_length, par(2).Size_larg_comp, par(2).Char_path_length_lc, par(2).Nb_ind_comp];
wpli = [par(3).Density, par(3).Clustering_coeff, par(3).Char_path_length, par(3).Size_larg_comp, par(3).Char_path_length_lc, par(3).Nb_ind_comp];

time = 1:1800;
figure();
subplot(3,2,1)
plot(time, par(1).Density)
hold on
plot(time, par(2).Density)
hold on
plot(time, par(3).Density)
xlabel('Time (in ms)')
title('Density')
subplot(3,2,2)
plot(time, par(1).Clustering_coeff)
hold on
plot(time, par(2).Clustering_coeff)
hold on
plot(time, par(3).Clustering_coeff)
xlabel('Time (in ms)')
title('Clustering coefficient')
subplot(3,2,3)
plot(time, par(1).Char_path_length)
hold on
plot(time, par(2).Char_path_length)
hold on
plot(time, par(3).Char_path_length)
xlabel('Time (in ms)')
title('Characteristic path length')
subplot(3,2,4)
plot(time, par(1).Size_larg_comp)
hold on
plot(time, par(2).Size_larg_comp)
hold on
plot(time, par(3).Size_larg_comp)
xlabel('Time (in ms)')
title('Size of the largest component')
subplot(3,2,5)
plot(time, par(1).Char_path_length_lc)
hold on
plot(time, par(2).Char_path_length_lc)
hold on
plot(time, par(3).Char_path_length_lc)
xlabel('Time (in ms)')
title('Characteristic path length of the largest component')
subplot(3,2,6)
plot(time, par(1).Nb_ind_comp)
hold on
plot(time, par(2).Nb_ind_comp)
hold on
plot(time, par(3).Nb_ind_comp)
xlabel('Time (in ms)')
title('Number of independent components')
set(gcf, 'units','normalized','outerposition',[0 0 1 1])

% fprintf(fileID, results)


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
    if assoc_measure == 'corr_cc'
        assoc = correctedCrossCorrelation();
    elseif assoc_measure == 'wPLI'
        assoc = wPLI();
    else
        assoc = crossCorrelation();
    end

    % By default: statistical test
    s_test = 'true';
    if matrix_constr == 'threshold'
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

    time = 1:1800;
    figure();
    subplot(3,2,1)
    plot(time, eeg.Density)
    xlabel('Time (in ms)')
    title('Density')
    subplot(3,2,2)
    plot(time, eeg.Clustering_coeff)
    xlabel('Time (in ms)')
    title('Clustering coefficient')
    subplot(3,2,3)
    plot(time, eeg.Char_path_length)
    xlabel('Time (in ms)')
    title('Characteristic path length')
    subplot(3,2,4)
    plot(time, eeg.Size_larg_comp)
    xlabel('Time (in ms)')
    title('Size of the largest component')
    subplot(3,2,5)
    plot(time, eeg.Char_path_length_lc)
    xlabel('Time (in ms)')
    title('Characteristic path length of the largest component')
    subplot(3,2,6)
    plot(time, eeg.Nb_ind_comp)
    xlabel('Time (in ms)')
    title('Number of independent components')
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])

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