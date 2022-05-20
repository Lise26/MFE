clearvars; clc;

% Parameters
patient = "Files/01/";
ref = 8;
low_freq = 1;         
high_freq = 30;
length_window = 250;
overlap = 125;

%%%%%%%%%%%%%%%%%%%%%% (Corrected) cross-correlation %%%%%%%%%%%%%%%%%%%%%%
for j=["cc", "corr_cc"]
    eeg = EEGData(patient, ref);
    
    % Pre-processing
    [eeg, wind] = eeg.preprocessing(low_freq, high_freq, length_window, overlap);
    if j == "corr_cc"
        measure = correctedCrossCorrelation();
        eeg = eeg.rereferencing(true, false);
    else
        measure = crossCorrelation();
        eeg = eeg.rereferencing(true, true);
    end
    
    % Network nodes
    net = network(eeg.Channels);

    % Network edges
    matrix = zeros(eeg.Channels, eeg.Channels, eeg.Num_window);
    n = 1;
    for w=wind.Length-wind.Overlap:wind.Length-wind.Overlap:eeg.Points+wind.Overlap-2*wind.Length
        wind.Data = eeg.Data(w-measure.Max_lag:w+wind.Length+measure.Max_lag,:);
        net = net.cc_corr_edges(measure, wind);
        matrix(:,:,n) = net.Edges;
        n = n+1;
    end
    net.Edges = mean(matrix,3);

    % Adjacency
    nets = network.empty(2,0);
    it = 1;
    %for q=[0.05, 0.00005, 0.000000000005]
    for q =[0.016, 0.015]
        net = net.adjacency_stat_test(wind.Length,q);
        % Network parameters
        net = net.parameters(false);
        disp(net.Density)
        disp(net.Clustering_coeff)
        disp(net.Char_path_length)
        disp(net.Size_larg_comp)
        disp(net.Char_path_length_lc)
        disp(net.Nb_ind_comp)
        disp(net.Small_world)
        
        nets(it) = net;
        it = it + 1;
    end
end

%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% wPLI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eeg = EEGData(patient, ref);
    
% Pre-processing
[eeg, wind] = eeg.preprocessing(low_freq, high_freq, length_window, overlap);
eeg = eeg.rereferencing(true, false);

% Network nodes
net = network(eeg.Channels);

% Network edges
net = net.wpli_edges(eeg, wind);

% Adjacency matrix
nets = network.empty(6,0);
it = 1;
for t=0.15:0.05:0.4
    net = net.adjacency_threshold(t);
    
    % Network parameters
    net = net.parameters(false);
    disp(net.Density)
    disp(net.Clustering_coeff)
    disp(net.Char_path_length)
    disp(net.Size_larg_comp)
    disp(net.Char_path_length_lc)
    disp(net.Nb_ind_comp)
    disp(net.Small_world)
    
    nets(it) = net;
    it = it + 1;
end

t15 = [nets(1).Density, nets(1).Clustering_coeff, nets(1).Char_path_length, nets(1).Size_larg_comp, nets(1).Char_path_length_lc, nets(1).Nb_ind_comp, nets(1).Small_world];
t20 = [nets(2).Density, nets(2).Clustering_coeff, nets(2).Char_path_length, nets(2).Size_larg_comp, nets(2).Char_path_length_lc, nets(2).Nb_ind_comp, nets(2).Small_world];
t25 = [nets(3).Density, nets(3).Clustering_coeff, nets(3).Char_path_length, nets(3).Size_larg_comp, nets(3).Char_path_length_lc, nets(3).Nb_ind_comp, nets(3).Small_world];
t30 = [nets(4).Density, nets(4).Clustering_coeff, nets(4).Char_path_length, nets(4).Size_larg_comp, nets(4).Char_path_length_lc, nets(4).Nb_ind_comp, nets(4).Small_world];
t35 = [nets(5).Density, nets(5).Clustering_coeff, nets(5).Char_path_length, nets(5).Size_larg_comp, nets(5).Char_path_length_lc, nets(5).Nb_ind_comp, nets(5).Small_world];
t40 = [nets(6).Density, nets(6).Clustering_coeff, nets(6).Char_path_length, nets(6).Size_larg_comp, nets(6).Char_path_length_lc, nets(6).Nb_ind_comp, nets(6).Small_world];

x = 1:7;
measures = {'Density', 'Clustering coefficient', 'Path length', 'Largest component', 'Path length of largest component', 'Number of components', 'Small-world'};
figure();
plot(x,t15,"*")
hold on
plot(x,t20,"*")
hold on
plot(x, t25,"*")
hold on
plot(x,t30,"*")
hold on
plot(x,t35,"*")
hold on
plot(x, t40,"*")
hold off
set(gca,'XTick',1:7,'XTickLabel',measures)
ylabel("Parameters values")
legend("Threshold = 15%", "Threshold = 20%", "Threshold = 25%", "Threshold = 30%", "Threshold = 35%", "Threshold = 40%")
title("Network parameters for the wPLI depending on the threshold")
xlim([0 8])
set(gcf, 'units','normalized','outerposition',[0 0 1 1])
%}