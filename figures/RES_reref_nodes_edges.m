% Code to generate illustrations of steps 1 to 3 (pre-processing, network
% nodes and edges) on patient n°1 - CHAPTER: RESULTS

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

% Processing
for m = ["cc", "corr_cc", "wPLI"]
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
        if m == "wPLI"
            measure = wPLI();
        elseif m == "corr_cc"
            measure = correctedCrossCorrelation();
        else
            measure = crossCorrelation();
        end
    
        net = net.edges(measure,eeg,wind);
    
        % Display network
        % adds column and row of zeros for channel 8, to account for the
        % zero voltage initial reference
        netw = zeros(19);
        netw(1:7,1:7) = net.Edges(1:7,1:7);
        netw(1:7,9:19) = net.Edges(1:7,8:18);
        netw(9:19,9:19) = net.Edges(8:18,8:18);
        aij = threshold_proportional(netw, 0.5);
        ijw = adj2edgeL(triu(aij));        

        figure();
        f_PlotEEG_BrainNetwork(19, ijw, 'w_intact');
    end
end