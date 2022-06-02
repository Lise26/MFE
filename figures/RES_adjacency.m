% Code to generate illustrations of the adjacency matrix construction -
% CHAPTER: RESULTS

clearvars; clc; close all;

% Parameters
nb_patients = 40;
ref = 8;
low_freq = 1;         
high_freq = 30;
length_window = 2500;
overlap = 125;
reref = true;
mast = true;

%%%%%%%%%%%%%%%%%%%%%%%%%% Statistical test %%%%%%%%%%%%%%%%%%%%%%%%%%
density = zeros(nb_patients,1);

for p=1:nb_patients
    fprintf("Patient n° %d\n", p)
    if p < 10
        patient = "Files/0" + p + "/"; 
    else
        patient = "Files/" + p + "/";
    end

    eeg = EEGData(patient, ref);
        
    % Pre-processing
    [eeg, wind] = eeg.preprocessing(low_freq, high_freq, length_window, overlap, reref, mast);

    % Network nodes
    net = network(eeg.Channels);

    % Network edges
    measure = crossCorrelation();
    net = net.edges(measure,eeg,wind);
    
    % Tries FDR
    for q = [0.05, 0.5]
        fprintf("Is it possible to use q = %.2f ?\n",q)
        net = net.adjacency_stat_test((2*measure.Max_lag)+1, q);
        if sum(net.Graph, "all") < 10
            disp("Not satisfying q value")
        else
            disp("Found an acceptable q value!")
            break
        end
    end

    % As FDR is unsuccessful for evey patient, threshold on the p-values
    net = net.adjacency_p_val((2*measure.Max_lag)+1, 0.05);

    % Network parameters
    net = net.parameters(false);

    density(p,1) = net.Density;
end

x = 1:nb_patients;
figure();
bar(density)
xlabel("Patients (number)")
ylabel("Density")
title("Network densities for patients")
set(gca,'XTick',x);
set(gcf, 'units','normalized','outerposition',[0 0 1 1])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Threshold %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
patient = "Files/01/";

for j = ["cc", "corr_cc", "wPLI"]
    eeg = EEGData(patient, ref);
    
    % Pre-processing
    [eeg, wind] = eeg.preprocessing(low_freq, high_freq, length_window, overlap, reref, mast);
    
    % Network nodes
    net = network(eeg.Channels);

    % Network edges
    if j == "wPLI"
        measure = wPLI();
    elseif j == "corr_cc"
        measure = correctedCrossCorrelation();
    else
        measure = crossCorrelation();
    end
    net = net.edges(measure,eeg,wind);

    % Adjacency matrix
    nets = network.empty(4,0);
    it = 1;
    
    for t=0.2:0.05:0.35
        net = net.adjacency_threshold(t);

        % Display network
        % adds column and row of zeros for channel 8, to account for the
        % zero voltage initial reference
        netw = zeros(19);
        netw(1:7,1:7) = net.Edges(1:7,1:7);
        netw(1:7,9:19) = net.Edges(1:7,8:18);
        netw(9:19,9:19) = net.Edges(8:18,8:18);
        ijw = adj2edgeL(triu(netw));        

        figure();
        f_PlotEEG_BrainNetwork(19, ijw, 'w_intact');
        
        % Network parameters
        net = net.parameters(false);
        
        nets(it) = net;
        it = it + 1;
    end

    density = [nets(1).Density, nets(2).Density, nets(3).Density, nets(4).Density];
    cluster = [nets(1).Clustering_coeff, nets(2).Clustering_coeff, nets(3).Clustering_coeff, nets(4).Clustering_coeff];
    char_path = [nets(1).Char_path_length, nets(2).Char_path_length, nets(3).Char_path_length, nets(4).Char_path_length];
    larg_comp = [nets(1).Size_larg_comp, nets(2).Size_larg_comp, nets(3).Size_larg_comp, nets(4).Size_larg_comp];
    char_path_lc = [nets(1).Char_path_length_lc, nets(2).Char_path_length_lc, nets(3).Char_path_length_lc, nets(4).Char_path_length_lc];
    nb_comp = [nets(1).Nb_ind_comp, nets(2).Nb_ind_comp, nets(3).Nb_ind_comp, nets(4).Nb_ind_comp];
    small = [nets(1).Small_world, nets(2).Small_world, nets(3).Small_world, nets(4).Small_world];
    
    x = 1:4;
    thresholds = {'20%', '25%', '30%', '35%'};
    
    figure();
    subplot(2,1,1)
    plot(x,density)
    hold on
    plot(x,cluster)
    hold on
    plot(x, char_path)
    hold on
    plot(x,small)
    hold on
    plot(x,char_path_lc)
    hold off
    set(gca,'XTick',1:4,'XTickLabel',thresholds)
    ylabel("Parameters values")
    xlabel("Thresholds")
    legend('Density', 'Clustering coefficient', 'Path length', 'Small-world', 'Path length of largest component')
    title("Evolution of the network parameters with the threshold")
    xlim([0 5])
    
    subplot(2,1,2)
    plot(x, nb_comp)
    hold on
    plot(x,larg_comp)
    hold off
    set(gca,'XTick',1:4,'XTickLabel',thresholds)
    ylabel("Parameters values")
    legend('Number of components', 'Largest component')
    xlabel("Thresholds")
    title("Evolution of the network parameters with the threshold")
    xlim([0 5])
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])
end