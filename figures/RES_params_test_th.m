% Code to generate illustrations of steps 5 and 6 (network parameters and
% condition classification) when use of a threshold - CHAPTER: RESULTS

clearvars; clc; close all;

nb_patients = 40;
nb_params = 6;
window_size = 2500;
if window_size == 250
    nb_windows = 1799;
else
    nb_windows = 92;
end

for m = ["cc", "corr_cc", "wPLI"]
    if m == "cc"
        measure = crossCorrelation();
    elseif m == "corr_cc"
        measure = correctedCrossCorrelation();
    else
        measure = wPLI();
    end

    nets1 = network.empty(0,40);
    nets2 = network.empty(0,40);
    nets3 = network.empty(0,40);
    nets4 = network.empty(0,40);
    
    params_ep = zeros(nb_patients/2, nb_params);
    params_h = zeros(nb_patients/2, nb_params);
    w_params_ep = zeros(nb_patients/2, nb_params, nb_windows);
    w_params_h = zeros(nb_patients/2, nb_params, nb_windows);
    
    % TREATMENT OF EEG PATIENT PER PATIENT
    for i=1:nb_patients
        if i < 10
            file = "Files/0" + i + "/"; 
        else
            file = "Files/" + i + "/";
        end
        eeg = EEGData(file, 8);
    
        low_freq = 1;         
        high_freq = 30;
        length_window = window_size;
        overlap = 125;
        reref = true;
        mast = true;
        [eeg, wind] = eeg.preprocessing(low_freq, high_freq, length_window, overlap, reref, mast);
    
        eeg.Network = network(eeg.Channels);
        eeg.Network = eeg.Network.edges(measure,eeg,wind);
    
        % APPLY THE VARIOUS THRESHOLDS
        it = 1;
        for t=0.2:0.05:0.35
            eeg.Network = eeg.Network.adjacency_threshold(t);
            eeg.Network = eeg.Network.parameters(false);
    
            if it == 1
                nets1(i) = eeg.Network;
            elseif it == 2
                nets2(i) = eeg.Network;
            elseif it == 3
                nets3(i) = eeg.Network;
            elseif it == 4
                nets4(i) = eeg.Network;
            end
            it = it + 1;
        end
    end  
    
    nets = vertcat(nets1,nets2,nets3,nets4);
    
    % FOR EACH THRESHOLD, DISPLAY THE RESULTS FOR STEPS 5 AND 6
    for a=1:4
        fprintf("---------------- Threshold n°%d --------------\n", a)
        for b=1:nb_patients
            if b < 21
               params_ep(b,:) = [nets(a,b).Clustering_coeff, ...
                   nets(a,b).Char_path_length, nets(a,b).Size_larg_comp, ...
                   nets(a,b).Char_path_length_lc, nets(a,b).Nb_ind_comp, ...
                   nets(a,b).Small_world];
            else
                params_h(b-20,:) = [nets(a,b).Clustering_coeff, ...
                   nets(a,b).Char_path_length, nets(a,b).Size_larg_comp, ...
                   nets(a,b).Char_path_length_lc, nets(a,b).Nb_ind_comp, ...
                   nets(a,b).Small_world];
            end
        end
    
        outcome = {'Epileptic', 'Control'};
        cluster = horzcat(params_ep(:,1), params_h(:,1));
        char = horzcat(params_ep(:,2), params_h(:,2));
        sizlc = horzcat(params_ep(:,3), params_h(:,3));
        charlc = horzcat(params_ep(:,4), params_h(:,4));
        nbcomp = horzcat(params_ep(:,5), params_h(:,5));
        small_world = horzcat(params_ep(:,6), params_h(:,6));

        % Dispaly the parameters distributions
        x = 1:2;
        figure();
        subplot(3,2,1)
        plot(x, cluster, "*")
        title("Mean Clustering Coefficient")
        set(gca,"FontSize",16,'XTick',1:2,'XTickLabel',outcome)
        xlim([0 3])
        subplot(3,2,2)
        plot(x,char,'*')
        title("Characteristic Path Length")
        set(gca,"FontSize",16,'XTick',1:2,'XTickLabel',outcome)
        xlim([0 3])
        subplot(3,2,3)
        plot(x,sizlc,'*')
        title("Size of the Largest Component")
        set(gca,"FontSize",16,'XTick',1:2,'XTickLabel',outcome)
        xlim([0 3])
        subplot(3,2,4)
        plot(x,charlc,'*')
        title("Characteristic Path Length of the Largest Component")
        set(gca,"FontSize",16,'XTick',1:2,'XTickLabel',outcome)
        xlim([0 3])
        subplot(3,2,5)
        plot(x,nbcomp,'*')
        title("Number of components")
        set(gca,"FontSize",16,'XTick',1:2,'XTickLabel',outcome)
        xlim([0 3])
        subplot(3,2,6)
        plot(x,small_world,'*')
        title("Small-world configuration")
        set(gca,"FontSize",16,'XTick',1:2,'XTickLabel',outcome)
        xlim([0 3])
        set(gcf, 'units','normalized','outerposition',[0 0 1 1])
    
        % Compute the statistical tests
        p = zeros(nb_params,1);
        for i=1:nb_params
            fprintf("------- Statistical test for parameter n° %d\n", i);
            h1 = kstest(params_ep(:,i));
            h2 = kstest(params_h(:,i));
            if h1 == 0 || h2 == 0
                [h_d, p_d] = ttest2(params_ep(:,i),params_h(:,i));
                disp("Normally distributed samples")
                disp(h_d)
                disp(p_d)
            else
                disp("Not normally distributed samples")
                [p_val, h] = ranksum(params_ep(:,i),params_h(:,i));
                disp(p_val)
                disp(h)
                p(i,1) = p_val;
            end
        end
        
        % Display the boxplots
        figure();
        subplot(3,2,1)
        boxplot(cluster)
        ylabel({'Mean Clustering','Coefficient'})
        title("P = " + p(1,1))
        set(gca,"FontSize",16,'XTick',1:2,'XTickLabel',outcome)
        subplot(3,2,2)
        boxplot(char)
        ylabel({'Characteristic Path', 'Length'})
        title("P = " + p(2,1))
        set(gca,"FontSize",16,'XTick',1:2,'XTickLabel',outcome)
        pos = get(gcf, 'Position');
        set(gcf, 'Position',pos+[-700 0 500 0])
        subplot(3,2,3);
        boxplot(sizlc)
        ylabel({'Size of the Largest','Component'})
        title("P = " + p(3,1))
        set(gca,"FontSize",16,'XTick',1:2,'XTickLabel',outcome)
        subplot(3,2,4)
        boxplot(charlc)
        ylabel({'Characteristic Path Length';'of the Largest Component'})
        title("P = " + p(4,1))
        set(gca,"FontSize",16,'XTick',1:2,'XTickLabel',outcome)
        subplot(3,2,5)
        boxplot(nbcomp)
        ylabel({'Number of','Components'})
        title("P = " + p(5,1))
        set(gca,"FontSize",16,'XTick',1:2,'XTickLabel',outcome)
        subplot(3,2,6)
        boxplot(small_world)
        ylabel({'Small-world','configuration'})
        title("P = " + p(6,1))
        set(gca,"FontSize",16,'XTick',1:2,'XTickLabel',outcome)
        set(gcf, 'units','normalized','outerposition',[0 0 1 1])
    end
end