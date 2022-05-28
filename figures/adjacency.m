% Parameters
patient = "Files/01/";
ref = 8;
low_freq = 1;         
high_freq = 30;
length_window = 2500;
overlap = 125;
reref = true;
mast = true;

%{
%%%%%%%%%%%%%%%%%%%%%% (Corrected) cross-correlation %%%%%%%%%%%%%%%%%%%%%%
for j = ["cc", "corr_cc"]
    eeg = EEGData(patient, ref);
    
    % Pre-processing
    [eeg, wind] = eeg.preprocessing(low_freq, high_freq, length_window, overlap, reref, mast);
    
    if j == "corr_cc"
        measure = correctedCrossCorrelation();
    else
        measure = crossCorrelation();
    end
    
    % Network nodes
    net = network(eeg.Channels);

    % Network edges
    net = net.edges(measure,eeg,wind);

    net = net.adjacency_stat_test(101, 0.05);

    % Adjacency
    nets = network.empty(6,0);
    it = 1;
    
    %{
    %for q=[0.05, 0.00005, 0.000000000005]
    for q = 1
    %for q =[0.016, 0.015]
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
    %}
    for t=0.05:0.05:0.3
        net = net.adjacency_stat_thres(wind.Length,t);
        
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
        disp(it)
        it = it + 1;
    end

    t05 = [nets(1).Density, nets(1).Clustering_coeff, nets(1).Char_path_length, nets(1).Size_larg_comp, nets(1).Char_path_length_lc, nets(1).Nb_ind_comp, nets(1).Small_world];
    t10 = [nets(2).Density, nets(2).Clustering_coeff, nets(2).Char_path_length, nets(2).Size_larg_comp, nets(2).Char_path_length_lc, nets(2).Nb_ind_comp, nets(2).Small_world];
    t15 = [nets(3).Density, nets(3).Clustering_coeff, nets(3).Char_path_length, nets(3).Size_larg_comp, nets(3).Char_path_length_lc, nets(3).Nb_ind_comp, nets(3).Small_world];
    t20 = [nets(4).Density, nets(4).Clustering_coeff, nets(4).Char_path_length, nets(4).Size_larg_comp, nets(4).Char_path_length_lc, nets(4).Nb_ind_comp, nets(4).Small_world];
    t25 = [nets(5).Density, nets(5).Clustering_coeff, nets(5).Char_path_length, nets(5).Size_larg_comp, nets(5).Char_path_length_lc, nets(5).Nb_ind_comp, nets(5).Small_world];
    t30 = [nets(6).Density, nets(6).Clustering_coeff, nets(6).Char_path_length, nets(6).Size_larg_comp, nets(6).Char_path_length_lc, nets(6).Nb_ind_comp, nets(6).Small_world];
    
    x = 1:7;
    measures = {'Density', 'Clustering coefficient', 'Path length', 'Largest component', 'Path length of largest component', 'Number of components', 'Small-world'};
    figure();
    plot(x,t05,"*")
    hold on
    plot(x,t10,"*")
    hold on
    plot(x,t15,"*")
    hold on
    plot(x,t20,"*")
    hold on
    plot(x, t25,"*")
    hold on
    plot(x,t30,"*")
    hold off
    set(gca,'XTick',1:7,'XTickLabel',measures)
    ylabel("Parameters values")
    legend("Threshold = 5%", "Threshold = 10%", "Threshold = 15%", "Threshold = 20%", "Threshold = 25%", "Threshold = 30%")
    title("Network parameters depending on the threshold")
    xlim([0 8])
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])
end

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% wPLI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eeg = EEGData(patient, ref);
    
% Pre-processing
[eeg, wind] = eeg.preprocessing(low_freq, high_freq, length_window, overlap, true, true);

% Network nodes
net = network(eeg.Channels);

% Network edges
measure = correctedCrossCorrelation();
net = net.edges(measure,eeg,wind);

% Adjacency matrix
nets = network.empty(4,0);
it = 1;
for t=0.2:0.05:0.35
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

%{
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
plot(x,density)
hold on
plot(x,cluster)
hold on
plot(x, char_path)
hold on
plot(x,larg_comp)
hold on
plot(x,char_path_lc)
hold on
plot(x, nb_comp)
hold on
plot(x, small)
hold off
set(gca,'XTick',1:4,'XTickLabel',thresholds)
ylabel("Parameters values")
legend('Density', 'Clustering coefficient', 'Path length', 'Largest component', 'Path length of largest component', 'Number of components', 'Small-world')
title("Evolution of the network parameters with the threshold for the wPLI")
xlim([0 5])
set(gcf, 'units','normalized','outerposition',[0 0 1 1])

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