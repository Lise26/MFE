clearvars; clc; close all;

% Parameters
patient = "Files/01/";
ref = 8;
low_freq = 1;         
high_freq = 30;
reref = false;
mastoids = false;
length_window = 2500; %10 sec
overlap = 125;
max_lag = 50;
assoc = crossCorrelation;

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
    eeg = eeg.preprocessing(low_freq, high_freq, reref, mastoids);
    wind = window(length_window, overlap, max_lag);

    % Network nodes
    wind.Network = network(eeg.Channels);

    % Network edges
    matrix = zeros(wind.Network.Nodes,wind.Network.Nodes,5);
    for i=1:wind.Network.Nodes
        for j=i+1:wind.Network.Nodes
            x_ep = zeros(eeg.Num_window,wind.Length); 
            y_ep = zeros(eeg.Num_window,wind.Length);
            n = 1;
            for w=wind.Length-wind.Overlap:wind.Length-wind.Overlap:eeg.Points-(wind.Overlap+wind.Length)
                wind.Data = eeg.Data(w-wind.Max_lag:w+wind.Length+wind.Max_lag,:);
                wind = wind.normalize();

                x_ep(n,:) = hann(wind.Length).'.*wind.Data(:,i);
                y_ep(n,:) = hann(wind.Length).'.*wind.Data(:,j);
                [S_ep(n,:),f_ep] = cpsd(x_ep(n,:),y_ep(n,:),[],[],[],250);
                n = n+1;
            end

            num = abs(mean(imag(S_ep),1));
            den = mean(abs(imag(S_ep)),1);
            wpli_cpsdVinck = num./den ;

            [delta,~] = find(f_ep>0.5 & f_ep<4);
            [theta,~] = find(f_ep>4 & f_ep<8);
            [alpha,~] = find(f_ep>8 & f_ep<13);
            [beta,~]  = find(f_ep>13 & f_ep<30);
            [gamma,~] = find(f_ep>30 & f_ep<40);
        
            matrix(i,j,:) = deal([mean(wpli_cpsdVinck(delta),'omitnan'),mean(wpli_cpsdVinck(theta),'omitnan'),...
                               mean(wpli_cpsdVinck(alpha),'omitnan'),mean(wpli_cpsdVinck(beta),'omitnan'),...
                               mean(wpli_cpsdVinck(gamma),'omitnan')]);
            
        end
    end

    net = mean(matrix,3) ;

    netw = zeros(19);
    netw(1:7,1:7) = net(1:7,1:7);
    netw(1:7,9:19) = net(1:7,8:18);
    netw(9:19,9:19) = net(8:18,8:18);
    netw = (netw+netw');
    aij = threshold_proportional(netw, 0.5);
    ijw = adj2edgeL(triu(aij));        
    
    % Display network
    figure();
    f_PlotEEG_BrainNetwork(19, ijw, 'w_intact');

    % Binary network
    aij(aij>0) = 1;
    aij(:,8) = [];
    aij(8,:) = [];
    wind.Network.Graph = aij;

    % Network parameters
    net = wind.Network.parameters(false);
    disp(net.Density);
    disp(net.Clustering_coeff);
    disp(net.Char_path_length);
    disp(net.Size_larg_comp);
    disp(net.Char_path_length_lc);
    disp(net.Nb_ind_comp);
    disp(net.Small_world)

    nets(r) = net;
end

no_ref = [nets(1).Density, nets(1).Clustering_coeff, nets(1).Char_path_length, nets(1).Size_larg_comp, nets(1).Char_path_length_lc, nets(1).Nb_ind_comp, nets(1).Small_world];
av = [nets(2).Density, nets(2).Clustering_coeff, nets(2).Char_path_length, nets(2).Size_larg_comp, nets(2).Char_path_length_lc, nets(2).Nb_ind_comp, nets(2).Small_world];
mast = [nets(3).Density, nets(3).Clustering_coeff, nets(3).Char_path_length, nets(3).Size_larg_comp, nets(3).Char_path_length_lc, nets(3).Nb_ind_comp, nets(3).Small_world];

x = 1:7;
measures = {'Density', 'Clustering coefficient', 'Path length', 'Largest component', 'Path length of largest component', 'Number of components', 'Small-world'};
figure();
plot(x,no_ref, "*")
hold on
plot(x,av, "x")
hold on
plot(x,mast, "o")
hold off
set(gca,'XTick',1:7,'XTickLabel',measures)
ylabel("Parameters values")
legend("No re-referencing", "Re-referencing to average", "Re-referencing to average mastoids")
title("Average parameters of the brain network depending of the re-referencing")
xlim([0 8])
set(gcf, 'units','normalized','outerposition',[0 0 1 1])