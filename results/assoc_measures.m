clearvars; clc;

% Parameters
patient = "Files/01/";
ref = 8;
low_freq = 1;         
high_freq = 30;
length_window = 250;
overlap = 125;

% Results
nets = network.empty(3,0);
c = 1;

for j=["cc", "corr_cc", "wPLI"]
    eeg = EEGData(patient, ref);
    
    % Pre-processing
    [eeg, wind] = eeg.preprocessing(low_freq, high_freq, length_window, overlap);
    
    % Network nodes
    net = network(eeg.Channels-2);

    % Network edges
    if j == "wPLI"
        eeg = eeg.rereferencing(true, false);
        net = net.wpli_edges(eeg, wind);
    
    else
        if j == "corr_cc"
            measure = correctedCrossCorrelation();
            eeg = eeg.rereferencing(true, false);
        else
            measure = crossCorrelation();
            eeg = eeg.rereferencing(true, true);
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

    % Adjacency matrix
    net = net.adjacency_threshold(0.15);

    % Network parameters
    net = net.parameters(false);
    disp(net.Density);
    disp(net.Clustering_coeff);
    disp(net.Char_path_length);
    disp(net.Size_larg_comp);
    disp(net.Char_path_length_lc);
    disp(net.Nb_ind_comp);
    disp(net.Small_world)

    nets(c) = net;
    c = c + 1;
end

cc = [nets(1).Density, nets(1).Clustering_coeff, nets(1).Char_path_length, nets(1).Size_larg_comp, nets(1).Char_path_length_lc, nets(1).Nb_ind_comp, nets(1).Small_world];
corr_cc = [nets(2).Density, nets(2).Clustering_coeff, nets(2).Char_path_length, nets(2).Size_larg_comp, nets(2).Char_path_length_lc, nets(2).Nb_ind_comp, nets(2).Small_world];
wpli = [nets(3).Density, nets(3).Clustering_coeff, nets(3).Char_path_length, nets(3).Size_larg_comp, nets(3).Char_path_length_lc, nets(3).Nb_ind_comp, nets(3).Small_world];

x = 1:7;
measures = {'Density', 'Clustering coefficient', 'Path length', 'Largest component', 'Path length of largest component', 'Number of components', 'Small-world'};
figure();
plot(x,cc, "*")
hold on
plot(x,corr_cc, "x")
hold on
plot(x, wpli, "o")
hold off
set(gca,'XTick',1:7,'XTickLabel',measures)
ylabel("Parameters values")
legend("Cross-correlation", "Corrected cross-correlation", "wPLI")
title("Network parameters depending on the association measure")
xlim([0 8])
set(gcf, 'units','normalized','outerposition',[0 0 1 1])

%{
cc = [par(1).Density, par(1).Clustering_coeff, par(1).Char_path_length, par(1).Size_larg_comp, par(1).Char_path_length_lc, par(1).Nb_ind_comp];
corr = [par(2).Density, par(2).Clustering_coeff, par(2).Char_path_length, par(2).Size_larg_comp, par(2).Char_path_length_lc, par(2).Nb_ind_comp];

figure();
subplot(3,2,1)
plot(par(1).Density)
hold on
plot(par(2).Density)
xlabel('Time (in ms)')
title('Density')
subplot(3,2,2)
plot(par(1).Clustering_coeff)
hold on
plot(par(2).Clustering_coeff)
xlabel('Time (in ms)')
title('Clustering coefficient')
subplot(3,2,3)
plot(par(1).Char_path_length)
hold on
plot(par(2).Char_path_length)
xlabel('Time (in ms)')
title('Characteristic path length')
subplot(3,2,4)
plot(par(1).Size_larg_comp)
hold on
plot(par(2).Size_larg_comp)
xlabel('Time (in ms)')
title('Size of the largest component')
subplot(3,2,5)
plot(par(1).Char_path_length_lc)
hold on
plot(par(2).Char_path_length_lc)
xlabel('Time (in ms)')
title('Characteristic path length of the largest component')
subplot(3,2,6)
plot(par(1).Nb_ind_comp)
hold on
plot(par(2).Nb_ind_comp)
xlabel('Time (in ms)')
title('Number of independent components')
set(gcf, 'units','normalized','outerposition',[0 0 1 1])
%}