clearvars; clc; close all;

nb_patients = 40;
nb_params = 6;
window_size = 2500;
if window_size == 250
    nb_windows = 1799;
else
    nb_windows = 92;
end

%for m = ["cc", "corr_cc", "wPLI"]
for window_size = 2500 
    m = "corr_cc";
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
        param = eeg.process_data(m, window_size);
    
        if m == "cc" || m == "corr_cc"
            % Parameters values in function of the windows
            figure();
            subplot(6,1,1)
            plot(param.Clustering_coeff)
            title("Mean Clustering Coefficient across windows")
            xlabel("Windows")
            subplot(6,1,2)
            plot(param.Char_path_length)
            title("Characteristic Path Length across windows")
            xlabel("Windows")
            subplot(6,1,3)
            plot(param.Size_larg_comp)
            title("Size of the Largest Component across windows")
            xlabel("Windows")
            subplot(6,1,4)
            plot(param.Char_path_length_lc)
            title("Characteristic Path Length of the Largest Component across windows")
            xlabel("Windows")
            subplot(6,1,5)
            plot(param.Nb_ind_comp)
            title("Number of Independent Components across windows")
            xlabel("Windows")
            subplot(6,1,6)
            plot(param.Small_world)
            title("Small-world Configuration across windows")
            xlabel("Windows")
            set(gcf, 'units','normalized','outerposition',[0 0 1 1])

            disp("IS size ok ??")
            disp(size(param.Density))
        
            % Patients that have longer recordings are cut for display purposes
            if window_size == 250
                if i == 19 || i == 20
                    param.Density(end-1: end) = [];
                    param.Clustering_coeff(end-1: end) = [];
                    param.Char_path_length(end-1: end) = [];
                    param.Size_larg_comp(end-1: end) = [];
                    param.Char_path_length_lc(end-1: end) = [];
                    param.Nb_ind_comp(end-1: end) = [];
                    param.Small_world(end-1: end) = [];
                end
            end
        end
    
        % Average values for the parameters
        fprintf("------- Parameters for patient n° %d\n", i);
        fprintf("Network density: %12.8f\n", param.Av_density)
        fprintf("Clustering coefficient: %12.8f\n", param.Av_clustering_coeff)
        fprintf("Path length: %12.8f\n", param.Av_char_path_length)
        fprintf("Size of largest component: %12.8f\n", param.Av_size_larg_comp)
        fprintf("Path length of largest component: %12.8f\n", param.Av_char_path_length_lc)
        fprintf("Independent components: %12.8f\n", param.Av_nb_ind_comp)
        fprintf("Small world configuration: %12.8f\n", param.Av_small_world)
    
        % Keep the patient's parameters in memory
        if i < 21
           params_ep(i,:) = [param.Av_clustering_coeff, ...
               param.Av_char_path_length, param.Av_size_larg_comp, ...
               param.Av_char_path_length_lc, param.Av_nb_ind_comp, ...
               param.Av_small_world];
    
           if m == "cc" || m == "corr_cc"
               w_params_ep(i,:,1:nb_windows) = [param.Clustering_coeff; ...
                   param.Char_path_length; param.Size_larg_comp; ...
                   param.Char_path_length_lc; param.Nb_ind_comp; ...
                   param.Small_world];
           end
        else
            params_h(i-20,:) = [param.Av_clustering_coeff, ...
               param.Av_char_path_length, param.Av_size_larg_comp, ...
               param.Av_char_path_length_lc, param.Av_nb_ind_comp, ...
               param.Av_small_world];
            
            if m == "cc" || m == "corr_cc"
                w_params_h(i-20,:,:) = [param.Clustering_coeff; ...
                   param.Char_path_length; param.Size_larg_comp; ...
                   param.Char_path_length_lc; param.Nb_ind_comp; param.Small_world];
            end
        end
    end  
    
    outcome = {'Epileptic', 'Healthy'};
    disp(size(params_ep()))
    disp(size(params_h()))
    cluster = horzcat(params_ep(:,1), params_h(:,1));
    char = horzcat(params_ep(:,2), params_h(:,2));
    sizlc = horzcat(params_ep(:,3), params_h(:,3));
    charlc = horzcat(params_ep(:,4), params_h(:,4));
    nbcomp = horzcat(params_ep(:,5), params_h(:,5));
    small_world = horzcat(params_ep(:,6), params_h(:,6));
    
    x = 1:2;
    figure();
    subplot(3,2,1)
    plot(x, cluster, "x")
    title("Mean Clustering Coefficient")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    subplot(3,2,2)
    plot(x,char,'*')
    title("Characteristic Path Length")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    subplot(3,2,3)
    plot(x,sizlc,'*')
    title("Size of the Largest Component")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    subplot(3,2,4)
    plot(x,charlc,'*')
    title("Characteristic Path Length of the Largest Component")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    subplot(3,2,5)
    plot(x,nbcomp,'*')
    title("Number of components")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    subplot(3,2,6)
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
    
    figure(43);
    subplot(3,2,1)
    boxplot(cluster)
    ylabel('Mean Clustering Coefficient')
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(3,2,2)
    boxplot(char)
    ylabel('Characteristic Path Length')
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(3,2,3)
    boxplot(sizlc)
    ylabel('Size of the Largest Component')
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(3,2,4)
    boxplot(charlc)
    ylabel('Characteristic Path Length of the Largest Component')
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(3,2,5)
    boxplot(nbcomp)
    ylabel('Number of Components')
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(3,2,6)
    boxplot(small_world)
    ylabel('Small-world configuration')
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])

    if m == "cc" || m == "corr_cc"        
        figure();
        subplot(3,2,1)
        plot_areaerrorbar(squeeze(w_params_ep(:,1,:)));
        hold on;
        plot_areaerrorbar(squeeze(w_params_h(:,1,:)), "orange");
        title("Mean Clustering Coefficient")
        subplot(3,2,2)
        plot_areaerrorbar(squeeze(w_params_ep(:,2,:)));
        hold on;
        plot_areaerrorbar(squeeze(w_params_h(:,2,:)), "orange");
        title("Characteristic Path Length")
        subplot(3,2,3)
        plot_areaerrorbar(squeeze(w_params_ep(:,3,:)));
        hold on;
        plot_areaerrorbar(squeeze(w_params_h(:,3,:)), "orange");
        title("Size of the Largest Component")
        subplot(3,2,4)
        plot_areaerrorbar(squeeze(w_params_ep(:,4,:)));
        hold on;
        plot_areaerrorbar(squeeze(w_params_h(:,4,:)), "orange");
        title("Characteristic Path Length of the Largest Component")
        subplot(3,2,5)
        plot_areaerrorbar(squeeze(w_params_ep(:,5,:)));
        hold on;
        plot_areaerrorbar(squeeze(w_params_h(:,5,:)), "orange");
        title("Number of components")
        subplot(3,2,6)
        plot_areaerrorbar(squeeze(w_params_ep(:,6,:)));
        hold on;
        plot_areaerrorbar(squeeze(w_params_h(:,6,:)), "orange");
        title("Small-world configuration")
        set(gcf, 'units','normalized','outerposition',[0 0 1 1])
    end
end