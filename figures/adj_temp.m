clc; clearvars;

% Parameters
ref = 8;
low_freq = 1;         
high_freq = 30;
length_window = 2500;
overlap = 125;
reref = true;
mast = true;

%%%%%%%%%%%%%%%%%%%%%% (Corrected) cross-correlation %%%%%%%%%%%%%%%%%%%%%%
for p=1:40
    if p < 10
        patient = "Files/0" + p + "/"; 
    else
        patient = "Files/" + p + "/";
    end

    fprintf("Patient n° %d\n", p)

    for j = "corr_cc"
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
        
        %{
        disp("Is it possible to use q ?")
        for q = [0.05, 0.5]
            net = net.adjacency_stat_test(101, q);
        end
        %}
        
        net = net.adjacency_p_val(101, 0.05);

        if sum(net.Graph, 'all') == 0
            continue
        else
            net = net.parameters(false);
            disp(net.Density)
            %disp(net.Clustering_coeff)
            %disp(net.Char_path_length)
            %disp(net.Size_larg_comp)
            %disp(net.Char_path_length_lc)
            %disp(net.Nb_ind_comp)
            %disp(net.Small_world)
        end

    end
end