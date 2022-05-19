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
assoc = "wPLI";

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
    [eeg, wind] = eeg.preprocessing(low_freq, high_freq, length_window, overlap);
    eeg = eeg.rereferencing(reref, mastoids);

    % Network nodes
    net = network(eeg.Channels);

    % Network edges
    if assoc == "wPLI"
        net = net.wpli_edges(eeg, wind);
        disp(net.Edges)
    
    else
        if assoc == "corr_cc"
            measure = correctedCrossCorrelation();
        else
            measure = crossCorrelation();
        end
        matrix = zeros(eeg.Channels, eeg.Channels, eeg.Num_window);
        n = 1;
        for w=wind.Length-wind.Overlap:wind.Length-wind.Overlap:eeg.Points+wind.Overlap-2*wind.Length
            wind.Data = eeg.Data(w-measure.Max_lag:w+wind.Length+measure.Max_lag,:);
            net = net.cc_corr_edges(measure, wind);
            matrix(:,:,n) = net.Edges;
            n = n+1;
        end
        net.Edges = mean(matrix,3);
    end

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