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

        Av_density {mustBeNumeric}
        Av_clustering_coeff {mustBeNumeric}
        Av_char_path_length {mustBeNumeric}
        Av_size_larg_comp {mustBeNumeric}
        Av_char_path_length_lc {mustBeNumeric}
        Av_nb_ind_comp {mustBeNumeric}
    end

    methods
        function obj = EEGData(data, chan, points, s_freq, ref)
            obj.Data = data;
            obj.Channels = chan;
            obj.Points = points;
            obj.Sample_frequency = s_freq;
            obj.Reference = ref;
        end

        function obj = preprocessing(obj, low_freq, high_freq)
            % Filter the frequency band between 0.5 and 30 Hz
            dat = bandpass(obj.Data(:,1:obj.Channels),[low_freq high_freq], obj.Sample_frequency);
            
            % Re-referencing to average
            dat(:,obj.Reference) = [];
            obj.Channels = obj.Channels - 1;
            average = mean(dat, "all");
            for i=1:obj.Channels
                dat(:,i) = dat(:,i) - average;
            end
            obj.Data = dat;
        end

        function obj = init_parameters(obj, window)
            obj.Num_window = (obj.Points / window.Overlap) - 3;

            obj.Density = zeros(1,obj.Num_window);
            obj.Clustering_coeff = zeros(1,obj.Num_window);
            obj.Char_path_length = zeros(1,obj.Num_window);
            obj.Size_larg_comp = zeros(1,obj.Num_window);
            obj.Char_path_length_lc = zeros(1,obj.Num_window);
            obj.Nb_ind_comp = zeros(1,obj.Num_window);
        end

        function obj = WIND_parameters(obj, window, counter)
            obj.Density(1, counter) = window.Density;
            obj.Clustering_coeff(1,counter) = window.Clustering_coeff;
            obj.Char_path_length(1,counter) = window.Char_path_length;
            obj.Size_larg_comp(1,counter) = window.Size_larg_comp;
            obj.Char_path_length_lc(1,counter) = window.Char_path_length_lc;
            obj.Nb_ind_comp(1,counter) = window.Nb_ind_comp;
        end

        function obj = EEG_parameters(obj)
            obj.Av_density = mean(obj.Density, "all");
            obj.Av_clustering_coeff= mean(obj.Clustering_coeff, "all");
            obj.Av_char_path_length = mean(obj.Char_path_length, "all");
            obj.Av_size_larg_comp = mean(obj.Size_larg_comp, "all");
            obj.Av_char_path_length_lc = mean(obj.Char_path_length_lc, "all");
            obj.Av_nb_ind_comp = mean(obj.Nb_ind_comp, "all");
        end
    end
end