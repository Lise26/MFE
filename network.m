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
            obj.Graph = (obj.Edges+obj.Edges') ; %Make it symmetric
            obj.Graph = threshold_proportional(obj.Graph, val);
            
            % Display network
            netw = zeros(19);
            netw(1:7,1:7) = obj.Graph(1:7,1:7);
            netw(1:7,9:19) = obj.Graph(1:7,8:18);
            netw(9:19,9:19) = obj.Graph(8:18,8:18);
            ijw = adj2edgeL(triu(netw));        
            figure();
            f_PlotEEG_BrainNetwork(19, ijw, 'w_unity');

            obj.Graph(obj.Graph>0)=1;
        end

        function obj = adjacency_stat_test(obj,n, q)
            p_values = zeros(obj.Nodes);
            disp(min(obj.Edges, [], "all"))
            disp(max(obj.Edges, [], "all"))
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
            for i=1:m
                if sorted(i) > (q/m)*i
                    k = i-1;
                    break
                else
                    if i == m
                        k = i;
                    end
                end
            end
            if k == 0
                k = 1;
            end
            disp(k)
            val = sorted(k);
            disp("Confidence in the network (number of false positives - percentage)")
            disp(q*k)
            obj.Graph = p_values;
            obj.Graph(obj.Graph>val)=0;

            obj.Graph(obj.Graph~=0)=1;
            disp(sum(obj.Graph, 'all'))
            obj.Graph = (obj.Graph+obj.Graph') ; %Make it symmetric
        end

        function obj = adjacency_p_val(obj,n,t)
            p_values = zeros(obj.Nodes);
            %disp(min(obj.Edges, [], "all"))
            %disp(max(obj.Edges, [], "all"))
            a = sqrt(2*log(n));
            b = a - (2*a)^(-1)*(log(log(n))+log(4*pi));
            for i=1:obj.Nodes
                for j=i+1:obj.Nodes
                    p_values(i,j) = exp(-2*exp(-a*(obj.Edges(i,j)-b)));
                end
            end
            obj.Graph = p_values;
            obj.Graph(obj.Graph>t)=0;

            %{
             % Display network
            netw = zeros(19);
            netw(1:7,1:7) = obj.Graph(1:7,1:7);
            netw(1:7,9:19) = obj.Graph(1:7,8:18);
            netw(9:19,9:19) = obj.Graph(8:18,8:18);
            ijw = adj2edgeL(triu(netw));        
            figure();
            f_PlotEEG_BrainNetwork(19, ijw, 'w_intact');
            %}

            obj.Graph(obj.Graph~=0)=1;
            disp(sum(obj.Graph, 'all'))
            obj.Graph = (obj.Graph+obj.Graph') ; %Make it symmetric
        end

        function obj = parameters(obj, component)
            % Density
            obj.Density = density_und(obj.Graph); 

            % Clustering coefficient
            % The CC of the network is a matrix, so we take the mean
            obj.Clustering_coeff = mean(clustering_coef_bu(obj.Graph),'all');
            
            % Characteristic path length
            % Do not consider infinitly long paths
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
            disp("Comparing SWs")
            disp(obj.Small_world)

            % get its basic properties
            n = size(obj.Graph,1);  % number of nodes
            k = sum(obj.Graph);  % degree distribution of undirected network
            K = mean(k); % mean degree of network
            [expectedC,expectedL] = ER_Expected_L_C(K,n);  % L_rand and C_rand
            [S_ws,~,~] = small_world_ness(obj.Graph,expectedL,expectedC,1);  % Using WS clustering coefficient

            sm = S_ws;
            disp(sm)
            
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

        end
    end
end