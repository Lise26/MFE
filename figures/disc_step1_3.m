patients = [5,9,26,31];

for k = patients
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