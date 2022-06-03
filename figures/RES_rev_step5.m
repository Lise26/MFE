% Code to generate the illustrations of step 5 in the final review of the
% method that compares several patients - CHAPTER: RESULTS

pat = [1,5,9,13,21,24,26,31];
nets = network.empty(8,0);
p = 1;

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

    % Network parameters
    net = net.parameters(false);
    nets(p) = net;
    p = p+1;

end

% Get the parameters for each patient
cluster = [nets(1).Clustering_coeff,p1(2),p13(2),nets(2).Clustering_coeff,nets(4).Clustering_coeff,p24(2),nets(3).Clustering_coeff,p21(2)];
char = [nets(1).Char_path_length,p1(3),p13(3),nets(2).Char_path_length,nets(4).Char_path_length,p24(3),nets(3).Char_path_length,p21(3)];
sizlc = [nets(1).Size_larg_comp,p1(4),p13(4),nets(2).Size_larg_comp,nets(4).Size_larg_comp,p24(4),nets(3).Size_larg_comp,p21(4)];
charlc = [nets(1).Char_path_length_lc,p1(5),p13(5),nets(2).Char_path_length_lc,nets(4).Char_path_length_lc,p24(5),nets(3).Char_path_length_lc,p21(5)];
nbcomp = [nets(1).Nb_ind_comp,p1(6),p13(6),nets(2).Nb_ind_comp,nets(4).Nb_ind_comp,p24(6),nets(3).Nb_ind_comp,p21(6)];
small_world = [nets(1).Small_world,p1(7),p13(7),nets(2).Small_world,nets(4).Small_world,p24(7),nets(3).Small_world,p21(7)];

% Dispaly the values obtained by the patients for each parameter
patients = {'1', '5', '9', '13', '24', '31', '21', '26'};
x = 1:8;
figure();
subplot(3,2,1)
bar(cluster)
title("Mean Clustering Coefficient")
xlabel("Patients (number)")
set(gca,"FontSize",18,'XTick',x,'XTickLabel',patients)

subplot(3,2,2)
bar(char)
title("Characteristic Path Length")
xlabel("Patients (number)")
set(gca,"FontSize",18,'XTick',x,'XTickLabel',patients)

subplot(3,2,3)
bar(sizlc)
title("Size of the Largest Component")
xlabel("Patients (number)")
set(gca,"FontSize",18,'XTick',x,'XTickLabel',patients)

subplot(3,2,4)
bar(charlc)
title("Characteristic Path Length of the Largest Component")
xlabel("Patients (number)")
set(gca,"FontSize",18,'XTick',x,'XTickLabel',patients)

subplot(3,2,5)
bar(nbcomp)
title("Number of components")
xlabel("Patients (number)")
set(gca,"FontSize",18,'XTick',x,'XTickLabel',patients)

subplot(3,2,6)
bar(small_world)
title("Small-world configuration")
xlabel("Patients (number)")
set(gca,"FontSize",18,'XTick',x,'XTickLabel',patients)

set(gcf, 'units','normalized','outerposition',[0 0 1 1])
