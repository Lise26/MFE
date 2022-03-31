classdef network
    properties
      Nodes {mustBeNumeric}
      Graph
      Density {mustBeNumeric}
      Clustering_coeff {mustBeNumeric}
      Char_path_length {mustBeNumeric}
      Size_larg_comp {mustBeNumeric}
      Char_path_length_lc {mustBeNumeric}
      Nb_ind_comp {mustBeNumeric}
    end
    
    methods
        function obj = network(nodes)
            obj.Nodes = nodes;
        end

        function obj = construction(obj, window, measure, s_test)
            matrix = zeros(obj.Nodes);

            % Use a statistical test to generate the association matrix
            if s_test == true
                a = sqrt(2*log(window.Length));
                b = a - (2*a)^(-1)*(log(log(window.Length))+log(4*pi));
                p_values = zeros(obj.Nodes);
                for i=1:obj.Nodes
                    for j=i+1:obj.Nodes
                        matrix(i,j) = measure.FTmeasure(window, i, j);
                        p_values(i,j) = exp(-2*exp(-a*(matrix(i,j)-b)));
                    end
                end

                tot = obj.Nodes*obj.Nodes;
                m = (obj.Nodes*(obj.Nodes-1)/2);
                [sorted, ~] = sort(reshape(p_values.',1,[]));
                sorted(1:tot-m) = [];
                q = 0.05;
                % q = 0.1;
                
                for i=1:m
                    if sorted(i) > q*i/m
                        k = i-1;
                        break
                    else
                        if i == m
                            k = m;
                        end
                        continue
                    end
                end
    
                val = sorted(k);
                obj.Graph = p_values;
    
                obj.Graph(obj.Graph<=val)=1;
                obj.Graph(obj.Graph~=1)=0;
                obj.Graph = (obj.Graph+obj.Graph') ; %Make it symmetric
            
            % Use a threshold to generate the association matrix
            else
                for i=1:obj.Nodes
                    for j=i+1:obj.Nodes
                        matrix(i,j) = measure.measure(window, i, j);
                    end
                end
                obj.Graph = (obj.Graph+obj.Graph') ; %Make it symmetric
                obj.Graph = threshold_proportional(matrix, 0.2);
                obj.Graph(obj.Graph>0)=1;
            end

        end

        function obj = parameters(obj, component)
            % Density
            potential = obj.Nodes*(obj.Nodes-1);
            actual = sum(obj.Graph == 1, 'all');
            obj.Density = actual/potential; 

            % Clustering coefficient (CC)
            % The CC of the network is a matrix, so we take the mean
            obj.Clustering_coeff = mean(clustering_coef_bu(obj.Graph),'all');
            
            % Characteristic path length (CPL)
            % PROBLEM: Lengths between disconnected nodes are set to Inf: THIS WILL ALWAYS BE INF
            dist_mat = distance_bin(obj.Graph);
            obj.Char_path_length = charpath(dist_mat, 0, 0);
        
            % Size of the largest component
            % component: array where each node of the network is labeled with the component it belongs to
            % comp_size: array with the sizes of the components
            [components, comp_size] = get_components(obj.Graph);
            obj.Size_larg_comp = max(comp_size);
            
            % Characteristic path length of the largest component
            % Build the network of the largest component only
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
        
            % Number of independent components
            obj.Nb_ind_comp = length(comp_size);

        end
    end
end