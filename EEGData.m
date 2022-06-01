% EEGData class

classdef EEGData
    properties
        Data
        Channels {mustBeNumeric}
        Points {mustBeNumeric}
        Sample_frequency {mustBeNumeric}
        Reference {mustBeNumeric}

        Network
    end

    methods
        function obj = EEGData(EEG_folder, ref)
            EEG_file = EEG_folder + "EEG.mat";
            EEG_header = EEG_folder + "Header.mat";
            load(EEG_file);
            load(EEG_header);
        
            obj.Points = size(EEG, 1);
            obj.Channels = size(EEG, 2)-3; 
            % Remove ECG, RSO and LIO that are not EEG channels
                % ECG = electrocardiogramme
                % RSO and LIO = electro oculogramme (right superior and left inferior)
            obj.Sample_frequency = Header.Fs;
            obj.Data = EEG(:,1:obj.Channels);

            % Delete the reference
            obj.Reference = ref;
            obj.Data(:,obj.Reference) = [];
            obj.Channels = obj.Channels - 1;
        end

        function [obj, wind] = preprocessing(obj, low_freq, high_freq, length_window, overlap, reref, mast)
            % Filter the frequency band between low_freq and high_freq 
            obj.Data = bandpass(obj.Data(:,1:obj.Channels),[low_freq high_freq], obj.Sample_frequency);
            % Re-referencing
            obj = obj.rereferencing(reref, mast);
            % Windowing
            wind = window(length_window, overlap);
        end

        function obj = rereferencing(obj, reref, mastoids)
            % Remove the mastoids from the number of channels
            obj.Channels = obj.Channels - 2;
         
            % Re-referencing
            if reref == true
                disp("reref")
                disp(obj.Points)
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

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = process_data(obj, assoc, window_size, t)
            % STEP 1: PRE PROCESSING
            low_freq = 1;         
            high_freq = 30;
            length_window = window_size;
            overlap = 125;
            reref = true;
            mast = true;
            [obj, wind] = obj.preprocessing(low_freq, high_freq, length_window, overlap, reref, mast);

            % STEP 2: NETWORK NODES
            obj.Network = network(obj.Channels);

            if assoc == "wPLI"
                measure = wPLI();
            elseif assoc == "corr_cc"
                measure = correctedCrossCorrelation();
            else
                measure = crossCorrelation();
            end
            
            % STEP 3: NETWORK EDGES
            obj.Network = obj.Network.edges(measure,obj,wind);

            % STEP 4: ADJACENCY MATRIX 
            if assoc == "cc" && t == 0.05
                obj.Network = obj.Network.adjacency_p_val(2*measure.Max_lag+1, t);
            else
                obj.Network = obj.Network.adjacency_threshold(t);
            end

            % STEP 5: PARAMETERS
            obj.Network = obj.Network.parameters(false);
        end
    end
end