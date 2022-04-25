clearvars; clc; close all;

nb_patients = 40;

density_ep = zeros(nb_patients, 1);
cluster_ep = zeros(nb_patients, 1);
charpath_ep = zeros(nb_patients, 1);
largcomp_ep = zeros(nb_patients, 1);
charpathlc_ep = zeros(nb_patients, 1);
indcomp_ep = zeros(nb_patients, 1);
degree_ep = zeros(nb_patients, 1);
small_ep = zeros(nb_patients, 1);
density_h = zeros(nb_patients, 1);
cluster_h = zeros(nb_patients, 1);
charpath_h = zeros(nb_patients, 1);
largcomp_h = zeros(nb_patients, 1);
charpathlc_h = zeros(nb_patients, 1);
indcomp_h = zeros(nb_patients, 1);
degree_h = zeros(nb_patients, 1);
small_h = zeros(nb_patients, 1);

for i=1:nb_patients
    if i < 10
        file = "Files/0" + i + "/"; 
    else
        file = "Files/" + i + "/";
    end
    param = predict(file, 8, "cc", "stat");

    % Parameters in function of the time
    figure();
    subplot(6,1,1)
    plot(param.Density)
    title("Network Density")
    subplot(6,1,2)
    plot(param.Clustering_coeff)
    title("Mean Clustering Coefficient")
    subplot(6,1,3)
    plot(param.Char_path_length)
    title("Characteristic Path Length")
    subplot(6,1,4)
    plot(param.Size_larg_comp)
    title("Size of the Largest Component")
    subplot(6,1,5)
    plot(param.Degree)
    title("Mean Degree")
    subplot(6,1,6)
    plot(param.Small_world)
    title("Small-world configuration")
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])

    % Average values for the parameters
    fprintf("------- Parameters for patient n° %d\n", i);
    fprintf("Network density: %12.8f\n", param.Av_density)
    fprintf("Clustering coefficient: %12.8f\n", param.Av_clustering_coeff)
    fprintf("Path length: %12.8f\n", param.Av_char_path_length)
    fprintf("Size of largest component: %12.8f\n", param.Av_size_larg_comp)
    fprintf("Path length of largest component: %12.8f\n", param.Av_char_path_length_lc)
    fprintf("Independent components: %12.8f\n", param.Av_nb_ind_comp)
    fprintf("Mean degree: %12.8f\n", param.Av_degree)
    fprintf("Small world configuration: %12.8f\n", param.Av_small_world)

    % Plot the averages per parameter
    if i < 21
        density_ep(i) = param.Av_density;
        cluster_ep(i) = param.Av_clustering_coeff;
        charpath_ep(i) = param.Av_char_path_length;
        largcomp_ep(i) = param.Av_size_larg_comp;
        charpathlc_ep(i) = param.Av_char_path_length_lc;
        indcomp_ep(i) = param.Av_nb_ind_comp;
        degree_ep(i) = param.Av_degree;
        small_ep(i) = param.Av_small_world;
    else
        density_h(i) = param.Av_density;
        cluster_h(i) = param.Av_clustering_coeff;
        charpath_h(i) = param.Av_char_path_length;
        largcomp_h(i) = param.Av_size_larg_comp;
        charpathlc_h(i) = param.Av_char_path_length_lc;
        indcomp_h(i) = param.Av_nb_ind_comp;
        degree_h(i) = param.Av_degree;
        small_h(i) = param.Av_small_world;
    end

    if i == 1
        density_mat_ep = param.Density;
        cluster_mat_ep = param.Clustering_coeff;
        path_mat_ep = param.Char_path_length;
        size_mat_ep = param.Size_larg_comp;
        pathlc_mat_ep = param.Char_path_length_lc;
        nbcomp_mat_ep = param.Nb_ind_comp;
        degree_mat_ep = param.Degree;
        small_mat_ep = param.Small_world;
    elseif i == 21
        density_mat_h = param.Density;
        cluster_mat_h = param.Clustering_coeff;
        path_mat_h = param.Char_path_length;
        size_mat_h = param.Size_larg_comp;
        pathlc_mat_h = param.Char_path_length_lc;
        nbcomp_mat_h = param.Nb_ind_comp;
        degree_mat_h = param.Degree;
        small_mat_h = param.Small_world;
    elseif i < 21
        if i == 5
            param.Density = [param.Density; 0];
            param.Clustering_coeff = [param.Clustering_coeff; 0];
            param.Char_path_length = [param.Char_path_length; 0];
            param.Size_larg_comp = [param.Size_larg_comp;0];
            param.Char_path_length_lc = [param.Char_path_length_lc;0];
            param.Nb_ind_comp = [param.Nb_ind_comp;0];
            param.Degree = [param.Degree;0];
            param.Small_world = [param.Small_world;0];
        end
        density_mat_ep = vertcat(density_mat_ep, param.Density);
        cluster_mat_ep = vertcat(cluster_mat_ep, param.Clustering_coeff);
        path_mat_ep = vertcat(path_mat_ep, param.Char_path_length);
        size_mat_ep = vertcat(size_mat_ep, param.Size_larg_comp);
        pathlc_mat_ep = vertcat(pathlc_mat_ep, param.Char_path_length_lc);
        nbcomp_mat_ep = vertcat(nbcomp_mat_ep, param.Nb_ind_comp);
        degree_mat_ep = vertcat(degree_mat_ep, param.Degree);
        small_mat_ep = vertcat(small_mat_ep, param.Small_world);
    
    else
        density_mat_h = vertcat(density_mat_h, param.Density);
        cluster_mat_h = vertcat(cluster_mat_h, param.Clustering_coeff);
        path_mat_h = vertcat(path_mat_h, param.Char_path_length);
        size_mat_h = vertcat(size_mat_h, param.Size_larg_comp);
        pathlc_mat_h = vertcat(pathlc_mat_h, param.Char_path_length_lc);
        nbcomp_mat_h = vertcat(nbcomp_mat_h, param.Nb_ind_comp);
        degree_mat_h = vertcat(degree_mat_h, param.Degree);
        small_mat_h = vertcat(small_mat_h, param.Small_world);
    end

end    

for i=1:20
    figure();
    subplot(4,2,1)
    plot_areaerrorbar(density_mat_ep);
    hold on;
    plot_areaerrorbar(density_mat_ep(:,i), options);
    title("Network Density")
    subplot(4,2,2)
    plot_areaerrorbar(cluster_mat_ep);
    hold on;
    plot_areaerrorbar(cluster_mat_ep(:,i), options);
    title("Mean Clustering Coefficient")
    subplot(4,2,3)
    plot_areaerrorbar(path_mat_ep);
    hold on;
    plot_areaerrorbar(path_mat_ep(:,i), options);
    title("Characteristic Path Length")
    subplot(4,2,4)
    plot_areaerrorbar(size_mat_ep);
    hold on;
    plot_areaerrorbar(size_mat_ep(:,i), options);
    title("Size of the Largest Component")
    subplot(4,2,5)
    plot_areaerrorbar(pathlc_mat_ep);
    hold on;
    plot_areaerrorbar(pathlc_mat_ep(:,i), options);
    title("Characteristic Path Length of the Largest Component")
    subplot(4,2,6)
    plot_areaerrorbar(nbcomp_mat_ep);
    hold on;
    plot_areaerrorbar(nbcomp_mat_ep(:,i), options);
    title("Number of components")
    subplot(4,2,7)
    plot_areaerrorbar(degree_mat_ep);
    hold on;
    plot_areaerrorbar(degree_mat_ep(:,i), options);
    title("Degree")
    subplot(4,2,8)
    plot_areaerrorbar(small_mat_ep);
    hold on;
    plot_areaerrorbar(small_mat_ep(:,i), options);
    title("Small-world configuration")
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])
end

for i=21:40
    figure();
    subplot(4,2,1)
    plot_areaerrorbar(density_mat_h(:,i), options);
    hold on;
    plot_areaerrorbar(density_mat_h);
    title("Network Density")
    subplot(4,2,2)
    plot_areaerrorbar(cluster_mat_h(:,i), options);
    hold on;
    plot_areaerrorbar(cluster_mat_h);
    title("Mean Clustering Coefficient")
    subplot(4,2,3)
    plot_areaerrorbar(path_mat_h(:,i), options);
    hold on;
    plot_areaerrorbar(path_mat_h);
    title("Characteristic Path Length")
    subplot(4,2,4)
    plot_areaerrorbar(size_mat_h(:,i), options);
    hold on;
    plot_areaerrorbar(size_mat_h);
    title("Size of the Largest Component")
    subplot(4,2,5)
    plot_areaerrorbar(pathlc_mat_h(:,i), options);
    hold on;
    plot_areaerrorbar(pathlc_mat_h);
    title("Characteristic Path Length of the Largest Component")
    subplot(4,2,6)
    plot_areaerrorbar(nbcomp_mat_h(:,i), options);
    hold on;
    plot_areaerrorbar(nbcomp_mat_h);
    title("Number of components")
    subplot(4,2,7)
    plot_areaerrorbar(degree_mat_h(:,i), options);
    hold on;
    plot_areaerrorbar(degree_mat_h);
    title("Degree")
    subplot(4,2,8)
    plot_areaerrorbar(small_mat_h(:,i), options);
    hold on;
    plot_areaerrorbar(small_mat_h);
    title("Small-world configuration")
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])
end

outcome = {'Epileptic', 'Healthy'};

s_ep = zeros(20,1);
s_h = zeros(20,1);
for j=1:20
    s_ep(j) = density_ep(j) + cluster_ep(j);
    s_h(j) = density_h(j) + cluster_h(j);
end
[m_ep,ind_ep] = sort(s_ep);
[m_h,ind_h] = sort(s_ep);
rem_ep = ind_ep(1:4);
rem_h = ind_h(1:4);

for i=1:5
    if i > 1
        for n=2:i-1
            if rem_ep(i-1) > rem_ep(n-1)
                rem_ep(i-1) = rem_ep(i-1) - 1;
            end
            if rem_h(i-1) > rem_h(n-1)
                rem_h(i-1) = rem_h(i-1) - 1;
            end
        end

        fprintf("We remove patients n° %d and n° %d\n", rem_ep(i-1), rem_h(i))
        density_ep(rem_ep(i-1)) = [];
        density_h(rem_h(i-1)) = [];
        charpath_ep(rem_ep(i-1)) = [];
        charpath_h(rem_h(i-1)) = [];
        largcomp_ep(rem_ep(i-1)) = [];
        largcomp_h(rem_h(i-1)) = [];
        charpathlc_ep(rem_ep(i-1)) = [];
        charpathlc_h(rem_h(i-1)) = [];
        indcomp_ep(rem_ep(i-1)) = [];
        indcomp_h(rem_h(i-1)) = [];
        degree_ep(rem_ep(i-1)) = [];
        degree_h(rem_h(i-1)) = [];
        small_ep(rem_ep(i-1)) = [];
        small_h(rem_h(i-1)) = [];
        cluster_ep(rem_ep(i-1)) = [];
        cluster_h(rem_h(i-1)) = [];
    end

    density = horzcat(density_ep, density_h);
    cluster = horzcat(cluster_ep, cluster_h);
    char = horzcat(charpath_ep, charpath_h);
    sizlc = horzcat(largcomp_ep, largcomp_h);
    charlc = horzcat(charpathlc_ep, charpathlc_h);
    nbcomp = horzcat(indcomp_ep, indcomp_h);
    degree = horzcat(degree_ep, degree_h);
    small_world = horzcat(small_ep, small_h);

    x = 1:2;
    figure();
    subplot(4,2,1)
    plot(x, density, '*')
    title("Network Density")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    subplot(4,2,2)
    plot(x, cluster, "x")
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
    plot(x,degree,'*')
    title("Degree")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    subplot(4,2,8)
    plot(x,small_world,'*')
    title("Small-world configuration")
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    xlim([0 3])
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])
    
    
    options.color_line = [236 112  22]./255;
    options.color_area = [243 169 114]./255;
    if ~isfield(options,'handle'); options.handle=figure(1);end 
    if ~isfield(options,'alpha'); options.alpha = 0.5; end 
    if ~isfield(options,'line_width'); options.line_width = 2; end 
    if ~isfield(options,'error'); options.error = 'std'; end
    plot_areaerrorbar(density_h, options);
    
    figure();
    subplot(4,2,1)
    plot_areaerrorbar(density_mat_ep);
    hold on;
    plot_areaerrorbar(density_mat_h, options);
    title("Network Density")
    subplot(4,2,2)
    plot_areaerrorbar(cluster_mat_ep);
    hold on;
    plot_areaerrorbar(cluster_mat_h, options);
    title("Mean Clustering Coefficient")
    subplot(4,2,3)
    plot_areaerrorbar(path_mat_ep);
    hold on;
    plot_areaerrorbar(path_mat_h, options);
    title("Characteristic Path Length")
    subplot(4,2,4)
    plot_areaerrorbar(size_mat_ep);
    hold on;
    plot_areaerrorbar(size_mat_h, options);
    title("Size of the Largest Component")
    subplot(4,2,5)
    plot_areaerrorbar(pathlc_mat_ep);
    hold on;
    plot_areaerrorbar(pathlc_mat_h, options);
    title("Characteristic Path Length of the Largest Component")
    subplot(4,2,6)
    plot_areaerrorbar(nbcomp_mat_ep);
    hold on;
    plot_areaerrorbar(nbcomp_mat_h, options);
    title("Number of components")
    subplot(4,2,7)
    plot_areaerrorbar(degree_mat_ep);
    hold on;
    plot_areaerrorbar(degree_mat_h, options);
    title("Degree")
    subplot(4,2,8)
    plot_areaerrorbar(small_mat_ep);
    hold on;
    plot_areaerrorbar(small_mat_h, options);
    title("Small-world configuration")
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])


    [h_d, p_d] = ttest2(density_ep,density_h);
    [h_cl, p_cl] = ttest2(cluster_ep,cluster_h);
    [h_ch, p_ch] = ttest2(charpath_ep,charpath_h);
    [h_lc, p_lc] = ttest2(largcomp_ep,largcomp_h);
    [h_cplc, p_cplc] = ttest2(charpathlc_ep,charpathlc_h);
    [h_nc, p_nc] = ttest2(indcomp_ep,indcomp_h);
    [h_deg, p_deg] = ttest2(degree_ep, degree_h);
    [h_sm, p_sm] = ttest2(small_ep, small_h);

    figure();
    subplot(4,2,1)
    boxplot(density)
    xlabel('Network Density')
    title(p_d)
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(4,2,2)
    boxplot(cluster)
    xlabel('Mean Clustering Coefficient')
    title(p_cl)
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(4,2,3)
    boxplot(char)
    xlabel('Characteristic Path Length')
    title(p_ch)
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(4,2,4)
    boxplot(sizlc)
    xlabel('Size of the Largest Component')
    title(p_lc)
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(4,2,5)
    boxplot(charlc)
    xlabel('Characteristic Path Length of the Largest Component')
    title(p_cplc)
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(4,2,6)
    boxplot(nbcomp)
    xlabel('Number of Components')
    title(p_nc)
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(4,2,7)
    boxplot(degree)
    xlabel('Degree')
    title(p_deg)
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    subplot(4,2,8)
    boxplot(small_world)
    xlabel('Small-world configuration')
    title(p_sm)
    set(gca,'XTick',1:2,'XTickLabel',outcome)
    set(gcf, 'units','normalized','outerposition',[0 0 1 1])

end


% MAIN FUNCTION
% Inputs: 
%   - EEG_file: EEG of the patient for which the indicator is asked
%       format: folder with 2 files: EEG.mat and Header.mat
%               EEG with 24 channels
%   - asociation measure: the choice of association measure between nodes
%       can be: "cc", "corr_cc" or "wPLI"
%       REM: put the best one by default
%   - matrix: the choice of association matrix construction method
% Output: 
%   - indicator: number between 1 and 100 indicating the probability of 
%       the patient to face epileptic seizure(s)

function eeg = predict(EEG_folder, ref, assoc_measure, matrix_constr)
    
    % Creation of the eeg object
    EEG_file = EEG_folder + "EEG.mat";
    EEG_header = EEG_folder + "Header.mat";
    
    load(EEG_file);
    load(EEG_header);

    chan = size(EEG, 2) - 5; % have something more reusable ?
    points = size(EEG, 1);
    fs = Header.Fs;
    eeg = EEGData(EEG, chan, points, fs, ref);

    % Options
    % By default: cross-correlation
    if assoc_measure == "corr_cc"
        assoc = correctedCrossCorrelation();
    elseif assoc_measure == "wPLI"
        assoc = wPLI();
    else
        assoc = crossCorrelation();
    end

    % By default: statistical test
    s_test = true;
    if matrix_constr == "threshold"
        s_test = false;
    end

    %%%%%%%%%%%%%%%%%%
    % PRE PROCESSING %
    %%%%%%%%%%%%%%%%%%

    low_freq = 0.5;         
    high_freq = 30;
    eeg = eeg.preprocessing(low_freq, high_freq);
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    % NETWORK CONSTRUCTION %
    %%%%%%%%%%%%%%%%%%%%%%%%  
    
    % Windowing - Creation of the window object
    length_window = 250;
    overlap = 125;
    max_lag = 50;
    wind = window(length_window, overlap, max_lag);
    eeg = eeg.init_parameters(wind);
    c = 1;

    for w=wind.Length-wind.Overlap:wind.Overlap:eeg.Points-(wind.Overlap+wind.Length)
        wind = wind.network(eeg.Data, w, assoc, s_test, false);

        %%%%%%%%%%%%%%%%%%%%%%%%%
        % PARAMETERS EXTRACTION %
        %%%%%%%%%%%%%%%%%%%%%%%%%

        % compute the network parameters of the window
        wind = wind.parameters();
        % keep track of the parameters of each window
        eeg = eeg.WIND_parameters(wind, c);
        c = c+1;
    end

    % Average of the parameters on all windows
    eeg = eeg.EEG_parameters();

end