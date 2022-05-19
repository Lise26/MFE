classdef EEGData
    properties
        Data
        Channels {mustBeNumeric}
        Points {mustBeNumeric}
        Sample_frequency {mustBeNumeric}
        Reference {mustBeNumeric}
        Num_window {mustBeNumeric}

        Density
        Clustering_coeff
        Char_path_length
        Size_larg_comp
        Char_path_length_lc
        Nb_ind_comp
        Small_world

        Av_density {mustBeNumeric}
        Av_clustering_coeff {mustBeNumeric}
        Av_char_path_length {mustBeNumeric}
        Av_size_larg_comp {mustBeNumeric}
        Av_char_path_length_lc {mustBeNumeric}
        Av_nb_ind_comp {mustBeNumeric}
        Av_small_world {mustBeNumeric}
    end

    methods
        function obj = EEGData(EEG_folder, ref)
            EEG_file = EEG_folder + "EEG.mat";
            EEG_header = EEG_folder + "Header.mat";
            load(EEG_file);
            load(EEG_header);
        
            obj.Channels = size(EEG, 2)-3; % Remove ECG, RSO, LIO channels
            obj.Points = size(EEG, 1);
            obj.Sample_frequency = Header.Fs;
            obj.Reference = ref;
            obj.Data = EEG(:,1:obj.Channels);

            % Delete the reference
            obj.Data(:,obj.Reference) = [];
            obj.Channels = obj.Channels - 1;

            %obj = obj.process_data(assoc);
        end

        function [obj, wind] = preprocessing(obj, low_freq, high_freq, length_window, overlap)
            % Filter the frequency band between low_freq and high_freq 
            obj.Data = bandpass(obj.Data(:,1:obj.Channels),[low_freq high_freq], obj.Sample_frequency);
            wind = window(length_window, overlap);
        end

        function obj = rereferencing(obj, reref, mastoids)
            % Remove the mastoids from the number of channels
            obj.Channels = obj.Channels - 2;
         
            if reref == true
                disp("reref")
                for p=1:obj.Points
                    if mastoids == true
                        % to the average of mastoids
                        average = mean(obj.Data(p,19:20));
                    else
                        % to average
                        average = mean(obj.Data(p,1:18));
                    end
                    for i=1:obj.Channels
                        obj.Data(p,i) = obj.Data(p,i) - average;
                    end
                end
                disp("end")
            end

            % Remove the mastoids from the channels
            obj.Data = obj.Data(:,1:18);
        end

        function obj = parameters(obj, window, counter)
            if counter == 1
                obj = obj.init_parameters(window);
            end

            obj.Density(1, counter) = window.Network.Density;
            obj.Clustering_coeff(1,counter) = window.Network.Clustering_coeff;
            obj.Char_path_length(1,counter) = window.Network.Char_path_length;
            obj.Size_larg_comp(1,counter) = window.Network.Size_larg_comp;
            obj.Char_path_length_lc(1,counter) = window.Network.Char_path_length_lc;
            obj.Nb_ind_comp(1,counter) = window.Network.Nb_ind_comp;
            obj.Small_world(1,counter) = window.Network.Small_world;

            if counter == obj.Num_window
                obj.av_parameters()
            end
        end

        function obj = init_parameters(obj, window)
            obj.Num_window = floor((obj.Points-window.Length+window.Overlap)/(window.Length-window.Overlap)) - 2;

            obj.Density = zeros(1,obj.Num_window);
            obj.Clustering_coeff = zeros(1,obj.Num_window);
            obj.Char_path_length = zeros(1,obj.Num_window);
            obj.Size_larg_comp = zeros(1,obj.Num_window);
            obj.Char_path_length_lc = zeros(1,obj.Num_window);
            obj.Nb_ind_comp = zeros(1,obj.Num_window);
            obj.Small_world = zeros(1,obj.Num_window);
        end

        function obj = av_parameters(obj)
            obj.Av_density = mean(obj.Density);
            obj.Av_clustering_coeff= mean(obj.Clustering_coeff);
            obj.Av_char_path_length = mean(obj.Char_path_length);
            obj.Av_size_larg_comp = mean(obj.Size_larg_comp);
            obj.Av_char_path_length_lc = mean(obj.Char_path_length_lc);
            obj.Av_nb_ind_comp = mean(obj.Nb_ind_comp);
            obj.Av_small_world = mean(obj.Small_world);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % PROCESS_DATA quantifies the brain connectivity of a given patient
        % It starts with the EEG data of the patient and ends with network
        % parameters quantifying its brain connectivity by going through
        % the first five steps described in the main methodology of the
        % thesis
        % 
        % EEG = PROCESS_DATA(ASSOC_MEASURE)
        %
        % INPUTS: 
        %   assoc_measure - choice of association measure between nodes
        %       can be: "cc", "corr_cc" or "wPLI"
        %       REM: put the best one by default
        %
        % OUTPUT: 
        %   eeg object - with associated network parameters
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = process_data(obj, assoc)
            % STEP 1: PRE PROCESSING
            low_freq = 1;         
            high_freq = 30;
            length_window = 250;
            overlap = 125;
            [eeg, wind] = obj.preprocessing(low_freq, high_freq, length_window, overlap);

            % STEP 2: NETWORK NODES
            net = network(eeg.Channels);
            
            % STEP 3, 4 & 5: NETWORK EDGES, ADJACENCY MATRIX & PARAMETERS
            % -------------------------- WPLI ---------------------------
            if assoc == "wPLI"
                obj = obj.rereferencing(true, false);
                
                net = net.wpli_edges(eeg.Data, wind);
                net = net.adjacency_threshold(0.2);
                net = net.parameters(false);

                obj.Av_density = net.Density;
                obj.Av_clustering_coeff = net.Clustering_coeff;
                obj.Av_char_path_length = net.Char_path_length;
                obj.Av_size_larg_comp = net.Size_larg_comp;
                obj.Av_char_path_length_lc = net.Char_path_length_lc;
                obj.Av_nb_ind_comp = net.Nb_ind_comp;
                obj.Av_small_world = net.Small_world;
        
            % ---------------------- CC / CORR_CC -----------------------
            else
                if assoc_measure == "corr_cc"
                    assoc = correctedCrossCorrelation();
                    obj = obj.rereferencing(true, false);
                else
                    assoc = crossCorrelation();
                    obj = obj.rereferencing(true, true);
                end
                
                c = 1;
                for w=wind.Length-wind.Overlap:wind.Length-wind.Overlap:eeg.Points+wind.Overlap-2*wind.Length
                    wind.Data = obj.Data(w-assoc.Max_lag:w+wind.Length+assoc.Max_lag,:);
                    
                    wind.Network = net.cc_corr_edges(assoc, wind);
                    wind.Network = net.adjecency_stat_test();
                    wind.Network = wind.Network.parameters(false);

                    obj = obj.parameters(wind, c);
                    c = c+1;
                end
            end
        end
    end
end