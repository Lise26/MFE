% Code to generate the illustrations of step 4 in the final review of the
% method that compares several patients - CHAPTER: RESULTS

pat = [1,5,9,13,21,24,26,31];

for k = pat
    fprintf("PATIENT %d\n", k)
    if k < 10
        file = "Files/0" + k + "/"; 
    else
        file = "Files/" + k + "/";
    end
    
    eeg = EEGData(file, 8);

    % Pre-processing
    low_freq = 1;         
    high_freq = 30;
    length_window = 250;
    overlap = 125;
    [eeg, wind] = eeg.preprocessing(low_freq, high_freq, length_window, overlap, true, true);

    % Network nodes
    net = network(eeg.Channels);

    % Network edges
    measure = wPLI();
    net = net.edges(measure,eeg,wind); 

    % Adjacency matrix
    net = net.adjacency_threshold(0.25);

    % Display network
    netw = zeros(19);
    netw(1:7,1:7) = net.Graph(1:7,1:7);
    netw(1:7,9:19) = net.Graph(1:7,8:18);
    netw(9:19,9:19) = net.Graph(8:18,8:18);
    ijw = adj2edgeL(triu(netw));  

    figure();
    f_PlotEEG_BrainNetwork(19, ijw, 'w_intact');
end