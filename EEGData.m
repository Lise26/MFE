classdef EEGData
    properties
        Data
        Channels {mustBeNumeric}
        Points {mustBeNumeric}
        Low_frequency {mustBeNumeric}
        High_frequency {mustBeNumeric}
        Sample_frequency {mustBeNumeric}
        Reference {mustBeNumeric}
        Num_window {mustBeNumeric}

        Density {mustBeNumeric}
        Clustering_coeff {mustBeNumeric}
        Char_path_length {mustBeNumeric}
        Size_larg_comp {mustBeNumeric}
        Char_path_length_lc {mustBeNumeric}
        Nb_ind_comp {mustBeNumeric}
    end

    methods
        function obj = EEGData(data, chan, points, low_freq, high_freq, s_freq, ref)
            obj.Data = data;
            obj.Channels = chan;
            obj.Points = points;
            obj.Low_frequency = low_freq;
            obj.High_frequency = high_freq;
            obj.Sample_frequency = s_freq;
            obj.Reference = ref;
        end

        function obj = preprocessing(obj)
            % Filter the frequency band between 0.5 and 30 Hz
            dat = bandpass(obj.Data(:,1:obj.Channels),[obj.Low_frequency obj.High_frequency], obj.Sample_frequency);
            
            % Re-referencing to average
            dat(:,obj.Reference) = [];
            obj.Channels = obj.Channels - 1;
            average = mean(dat, "all");
            for i=1:obj.Channels
                dat(:,i) = dat(:,i) - average;
            end
            obj.Data = dat;
        end

        function obj = EEG_parameters(obj, data, window, measure, corrected)
            obj.Num_window = (obj.Points / window.Overlap) - 2;

            density = zeros(1,obj.Num_window);
            cluster_coeff = zeros(1,obj.Num_window);
            path_length = zeros(1,obj.Num_window);
            largest_comp = zeros(1,obj.Num_window);
            path_length_lc = zeros(1,obj.Num_window);
            ind_comp = zeros(1,obj.Num_window);

            c = 1;

            for w=125:window.Overlap:obj.Points-375
                dat = window.data(data, w);

                net = network(obj.Channels);
                % net = net.construction(measure, dat, corrected);
                net = net.construction_ST(measure, dat);

            
                % BU (binary undirected network)
           
                density(1, c) = net.Density; % Network density
                cluster_coeff(1,c) = net.Clustering_coeff; % Clustering coefficient
                path_length(1,c) = net.Char_path_length; % Characteristic path length
                largest_comp(1,c) = net.Size_larg_comp; % Size of the largest component
                path_length_lc(1,c) = net.Char_path_length_lc; % Characteristic path length of the largest component
                ind_comp(1,c) = net.Nb_ind_comp; % Number of independent components
            
                c = c+1;
            end

            % Average of the parameters on all windows
            obj.Density = mean(density, "all");
            obj.Clustering_coeff= mean(cluster_coeff, "all");
            obj.Char_path_length = mean(path_length, "all");
            obj.Size_larg_comp = mean(largest_comp, "all");
            obj.Char_path_length_lc = mean(path_length_lc, "all");
            obj.Nb_ind_comp = mean(ind_comp, "all");

            time = [750:500:9000];
            disp(size(time))
            figure();
            subplot(2,2,1)
            plot(time, density)
            xlabel('Time (in ms)')
            ylabel('Density')
            subplot(3,2,2)
            plot(time, cluster_coeff)
            xlabel('Time (in ms)')
            ylabel('Clustering coefficient')
            subplot(3,2,3)
            plot(time, path_length)
            xlabel('Time (in ms)')
            ylabel('Characteristic path length')
            subplot(3,2,4)
            plot(time, largest_comp)
            xlabel('Time (in ms)')
            ylabel('Size of the largest component')
            subplot(3,2,5)
            plot(time, path_length_lc)
            xlabel('Time (in ms)')
            ylabel('Characteristic path length of the largest component')
            subplot(3,2,6)
            plot(time, ind_comp)
            xlabel('Time (in ms)')
            ylabel('Number of independent components')
        end
    end
end