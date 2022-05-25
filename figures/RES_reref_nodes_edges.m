clearvars; clc; close all;

% Parameters
patient = "Files/01/";
ref = 8;
low_freq = 1;         
high_freq = 30;
reref = false;
mastoids = false;
length_window = 2500;
overlap = 125;
assoc = "cc";

% Results
nets = network.empty(3,0);

for r=1:3
    eeg = EEGData(patient, ref);
    % Re-referencing to common average
    if r == 2
        reref = true;
    % Re-referencing to average of mastoids
    elseif r == 3
        mastoids = true;
    end
    % Pre-processing
    [eeg, wind] = eeg.preprocessing(low_freq, high_freq, length_window, overlap, reref, mastoids);

    % Network nodes
    net = network(eeg.Channels);

    % Network edges
    if assoc == "wPLI"
        measure = wPLI();
    elseif assoc == "corr_cc"
        measure = correctedCrossCorrelation();
    else
        measure = crossCorrelation();
    end

    net = net.edges(measure,eeg,wind);

    netw = zeros(19);
    netw(1:7,1:7) = net.Edges(1:7,1:7);
    netw(1:7,9:19) = net.Edges(1:7,8:18);
    netw(9:19,9:19) = net.Edges(8:18,8:18);
    netw = (netw+netw');
    aij = threshold_proportional(netw, 0.5);
    ijw = adj2edgeL(triu(aij));        
    
    % Display network
    figure();
    f_PlotEEG_BrainNetwork(19, ijw, 'w_intact');
end