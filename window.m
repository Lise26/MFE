classdef window
    properties
        Length {mustBeNumeric}
        Overlap {mustBeNumeric}
        Max_lag {mustBeNumeric}
        
        Data
        Network

        Density {mustBeNumeric}
        Clustering_coeff {mustBeNumeric}
        Char_path_length {mustBeNumeric}
        Size_larg_comp {mustBeNumeric}
        Char_path_length_lc {mustBeNumeric}
        Nb_ind_comp {mustBeNumeric}
        Degree {mustBeNumeric}
    end
    
    methods
        function obj = window(length_window, overlap, max_lag)
            obj.Length = length_window;
            obj.Overlap = overlap;
            obj.Max_lag = max_lag;
        end

        function obj = network(obj, data, w, assoc, s_test, bootstrap)
            obj.Data = data(w-obj.Max_lag:w+obj.Length+obj.Max_lag,:);
            obj = obj.normalize();
            obj.Network = network(size(obj.Data, 2));
            obj.Network = obj.Network.construction(obj, assoc, s_test, bootstrap);

            
            if w == 125
                figure();
                [x,y] = adjacency_plot_und(obj.Network.Graph);  % call function
                plot(x,y); 
                figure();
                G = graph(obj.Network.Graph);
                p = plot(G);
                set(gcf, 'units','normalized','outerposition',[0 0 1 1])
            end
            if w == 56250
                figure();
                [x,y] = adjacency_plot_und(obj.Network.Graph);  % call function
                plot(x,y); 
                figure();
                G = graph(obj.Network.Graph);
                p = plot(G);
                set(gcf, 'units','normalized','outerposition',[0 0 1 1])
            end
            if w == 112625
                figure();
                [x,y] = adjacency_plot_und(obj.Network.Graph);  % call function
                plot(x,y); 
                figure();
                G = graph(obj.Network.Graph);
                p = plot(G);
                set(gcf, 'units','normalized','outerposition',[0 0 1 1])
            end
            if w == 175000
                figure();
                [x,y] = adjacency_plot_und(obj.Network.Graph);  % call function
                plot(x,y); 
                figure();
                G = graph(obj.Network.Graph);
                p = plot(G);
                set(gcf, 'units','normalized','outerposition',[0 0 1 1])
            end
            if w == 225125
                figure();
                [x,y] = adjacency_plot_und(obj.Network.Graph);  % call function
                plot(x,y); 
                figure();
                G = graph(obj.Network.Graph);
                p = plot(G);
                set(gcf, 'units','normalized','outerposition',[0 0 1 1])
            end
            
        end
        
        function obj = normalize(obj)
            % Normalization of each channel to zero mean and unit variance
            for i=1:size(obj.Data, 2)
                obj.Data(:,i) = obj.Data(:,i) - mean(obj.Data(:,i));
                obj.Data(:,i) = obj.Data(:,i)/std(obj.Data(:,i));
            end
        end

        function obj = parameters(obj)
            obj.Network = obj.Network.parameters(false);
            obj.Density = obj.Network.Density; % Network density
            obj.Clustering_coeff = obj.Network.Clustering_coeff; % Clustering coefficient
            obj.Char_path_length  = obj.Network.Char_path_length; % Characteristic path length
            obj.Size_larg_comp = obj.Network.Size_larg_comp; % Size of the largest component
            obj.Char_path_length_lc = obj.Network.Char_path_length_lc; % Characteristic path length of the largest component
            obj.Nb_ind_comp = obj.Network.Nb_ind_comp; % Number of independent components
            obj.Degree = obj.Network.Degree; % Degree
        end

    end
end