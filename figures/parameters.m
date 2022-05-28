clearvars; clc; close all;

nb_patients = 40;
nb_params = 7;
window_size = 250;
if window_size == 250
    nb_windows = 1799;
else
    nb_windows = 92;
end

%for m = ["cc", "corr_cc", "wPLI"]
for m = ["cc", "corr_cc"]
window_size = 250;
    %m = "cc";
    params_ep = zeros(nb_patients/2, nb_params);
    params_h = zeros(nb_patients/2, nb_params);
    w_params_ep = zeros(nb_patients/2, nb_params, nb_windows);
    w_params_h = zeros(nb_patients/2, nb_params, nb_windows);
    
    for i=1:nb_patients
        if i < 10
            file = "Files/0" + i + "/"; 
        else
            file = "Files/" + i + "/";
        end
        eeg = EEGData(file, 8);
        eeg = eeg.process_data(m, window_size);
        param = eeg.Network;
    
        % Average values for the parameters
        %{
        fprintf("------- Parameters for patient n° %d\n", i);
        fprintf("Network density: %12.8f\n", param.Density)
        fprintf("Clustering coefficient: %12.8f\n", param.Clustering_coeff)
        fprintf("Path length: %12.8f\n", param.Char_path_length)
        fprintf("Size of largest component: %12.8f\n", param.Size_larg_comp)
        fprintf("Path length of largest component: %12.8f\n", param.Char_path_length_lc)
        fprintf("Independent components: %12.8f\n", param.Nb_ind_comp)
        fprintf("Small world configuration: %12.8f\n", param.Small_world)
        %}
    
        % Keep the patient's parameters in memory
        if i < 21
           params_ep(i,:) = [param.Density, param.Clustering_coeff, ...
               param.Char_path_length, param.Size_larg_comp, ...
               param.Char_path_length_lc, param.Nb_ind_comp, ...
               param.Small_world];
        else
            params_h(i-20,:) = [param.Density, param.Clustering_coeff, ...
               param.Char_path_length, param.Size_larg_comp, ...
               param.Char_path_length_lc, param.Nb_ind_comp, ...
               param.Small_world];
        end
    end  
    
    outcome = {'Epileptic', 'Control'};
    density = horzcat(params_ep(:,1), params_h(:,1));
    cluster = horzcat(params_ep(:,2), params_h(:,2));
    char = horzcat(params_ep(:,3), params_h(:,3));
    sizlc = horzcat(params_ep(:,4), params_h(:,4));
    charlc = horzcat(params_ep(:,5), params_h(:,5));
    nbcomp = horzcat(params_ep(:,6), params_h(:,6));
    small_world = horzcat(params_ep(:,7), params_h(:,7));

    dens = vertcat(density(:,1), density(:,2));
    x = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40];
    figure();
    bar(dens)
    xlabel("Patients (number)")
    ylabel("Density")
    title("Network densities for patients")
    set(gca,'XTick',x);
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])
    
    x = 1:2;
    figure();
    subplot(4,2,1)
    plot(x, density, "*")
    title("Density")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    subplot(4,2,2)
    plot(x, cluster, "*")
    title("Mean Clustering Coefficient")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    subplot(4,2,3)
    plot(x,char,'*')
    title("Characteristic Path Length")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    subplot(4,2,4)
    plot(x,sizlc,'*')
    title("Size of the Largest Component")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    subplot(4,2,5)
    plot(x,charlc,'*')
    title("Characteristic Path Length of the Largest Component")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    subplot(4,2,6)
    plot(x,nbcomp,'*')
    title("Number of components")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    subplot(4,2,7)
    plot(x,small_world,'*')
    title("Small-world configuration")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])
    
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
            vec_Wtest = zeros(40,2);
            vec_w(1:20,1) = params_ep(:,i);
            vec_w(21:40,1) = params_h(:,i);
            vec_w(1:20,2) = ones(20,1);
            vec_w(21:40,2) = 2.*ones(20,1);
            Wtest(vec_w);
        end
    end
    
    figure();
    subplot(4,2,1)
    boxplot(density)
    ylabel('Density')
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(4,2,2)
    boxplot(cluster)
    ylabel('Mean Clustering Coefficient')
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(4,2,3)
    boxplot(char)
    ylabel('Characteristic Path Length')
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(4,2,4)
    boxplot(sizlc)
    ylabel('Size of the Largest Component')
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(4,2,5)
    boxplot(charlc)
    ylabel('Characteristic Path Length of the Largest Component')
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(4,2,6)
    boxplot(nbcomp)
    ylabel('Number of Components')
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(4,2,7)
    boxplot(small_world)
    ylabel('Small-world configuration')
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])
end