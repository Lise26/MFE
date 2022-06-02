classdef network
    properties
      Nodes {mustBeNumeric}
      Edges
      Graph
      
      Density {mustBeNumeric}
      Clustering_coeff {mustBeNumeric}
      Char_path_length {mustBeNumeric}
      Size_larg_comp {mustBeNumeric}
      Char_path_length_lc {mustBeNumeric}
      Nb_ind_comp {mustBeNumeric}
      Small_world {mustBeNumeric}
    end
    
    methods
        function obj = network(nodes)
            obj.Nodes = nodes;
        end

        function obj = edges(obj, measure, eeg, window)
            obj.Edges = measure.matrix(eeg,window);
        end

        function obj = adjacency_threshold(obj, val)
            obj.Graph = (obj.Edges+obj.Edges');
            obj.Graph = threshold_proportional(obj.Graph, val);
            obj.Graph(obj.Graph>0)=1;
        end

        function obj = adjacency_stat_test(obj, n, q)
            p_values = zeros(obj.Nodes);
            a = sqrt(2*log(n));
            b = a - (2*a)^(-1)*(log(log(n))+log(4*pi));
            for i=1:obj.Nodes
                for j=i+1:obj.Nodes
                    p_values(i,j) = exp(-2*exp(-a*(obj.Edges(i,j)-b)));
                end
            end
            tot = obj.Nodes*obj.Nodes;
            m = obj.Nodes*(obj.Nodes-1)/2;
            [sorted, ~] = sort(reshape(p_values.',1,[]));
            sorted(1:tot-m) = [];
            k = 0;
            for i=1:m
                if sorted(i) > (q/m)*i
                    k = i-1;
                    break
                end
            end
            if k == 0
                disp("No reasonable value found for k")
            else
                val = sorted(k);
                obj.Graph = p_values;
                obj.Graph(obj.Graph>val)=0;
                obj.Graph(obj.Graph~=0)=1;
                obj.Graph = (obj.Graph+obj.Graph');
            end
        end

        function obj = adjacency_p_val(obj,n,t)
            p_values = zeros(obj.Nodes);
            a = sqrt(2*log(n));
            b = a - (2*a)^(-1)*(log(log(n))+log(4*pi));
            for i=1:obj.Nodes
                for j=i+1:obj.Nodes
                    p_values(i,j) = exp(-2*exp(-a*(obj.Edges(i,j)-b)));
                end
            end
            obj.Graph = p_values;
            obj.Graph(obj.Graph>t)=0;
            obj.Graph(obj.Graph~=0)=1;
            obj.Graph = (obj.Graph+obj.Graph');
        end

        function obj = parameters(obj, component)
            % Null network
            if sum(obj.Graph, 'all') == 0
                obj.Density = 0;
                obj.Clustering_coeff = 0;
                obj.Char_path_length = 0;
                obj.Size_larg_comp = 0;
                obj.Char_path_length_lc = 0;
                obj.Nb_ind_comp = 0;
                obj.Small_world = 0;
            else
                % Density
                obj.Density = density_und(obj.Graph); 
    
                % Clustering coefficient
                % The CC of the network is a matrix, so we take the mean
                obj.Clustering_coeff = mean(clustering_coef_bu(obj.Graph),'all');
                
                % Characteristic path length
                dist_mat = distance_bin(obj.Graph);
                obj.Char_path_length = charpath(dist_mat, 0, 0);
            
                % Size of the largest component
                % components: array where each node of the network is labeled with the component it belongs to
                % comp_size: array with the sizes of the components
                [components, comp_size] = get_components(obj.Graph);
                obj.Size_larg_comp = max(comp_size);
    
                % Number of independent components
                obj.Nb_ind_comp = length(comp_size);
    
                % Small world property
                obj.Small_world = small_world_propensity(obj.Graph, 'bin');
                
                % Characteristic path length of the largest component
                % Build the network of the largest component only
                % and extract path length
                largest_comp = find(comp_size==obj.Size_larg_comp);
                nodes_lc = find(components==largest_comp(1));
                init = uint32(1):uint32(obj.Nodes);
                [not_nodes_lc, ~] = setdiff(init, nodes_lc);
                net_lc = obj.Graph;
                for i=length(not_nodes_lc):-1:1
                    net_lc(not_nodes_lc(i),:) = [];
                    net_lc(:,not_nodes_lc(i)) = [];
                end
                if component == false
                    comp = network(size(net_lc, 1));
                    comp.Graph = net_lc;
                    comp = comp.parameters(true);
                    obj.Char_path_length_lc = comp.Char_path_length;
                end
            end
        end
    end
end