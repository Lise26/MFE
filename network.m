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

        function obj = construction(obj, measure, window, corrected)
            assoc_measure = zeros(obj.Nodes);
        
            % REM: the matrix is not perfectly diagonal: can cut half of the computations ?
            for i=1:obj.Nodes
                for j=1:obj.Nodes
                    assoc_measure(i,j) = max(measure.measure(window.Data(:,i),window.Data(:,j),window.Length,window.Max_lag, corrected));
                end
            end
        
            obj.Graph = threshold_proportional(assoc_measure, 0.2);
            for i=1:obj.Nodes
                for j=1:obj.Nodes
                    if obj.Graph(i,j) > 0
                        obj.Graph(i,j) = 1;
                    end
                    if obj.Graph(i,j) > 0
                        obj.Graph(i,j) = 1;
                    end
                end
            end 
            obj = obj.parameters(false);
        end

        function obj = construction_ST(obj, measure, window)
            FCC = zeros(2*window.Max_lag+1,1);
            sF = zeros(obj.Nodes);
            zF = zeros(obj.Nodes);
            a = sqrt(2*log(window.Length));
            b = a - (2*a)^(-1)*(log(log(window.Length))+log(4*pi));
            p = zeros(obj.Nodes);

            % REM: the matrix is not perfectly diagonal: can cut half of the computations ?
            for i=1:obj.Nodes
                for j=i:obj.Nodes
                    FCC(:) = measure.FTmeasure(window.Data(:,i),window.Data(:,j),window.Length,window.Max_lag);
                    sF(i,j) = max(abs(FCC));
                    zF(i,j) = sF(i,j)/sqrt(std(FCC));
                    p(i,j) = exp(-2*exp(-a*(zF(i,j)-b)));
                end
            end

            tot = obj.Nodes*obj.Nodes;
            m = (obj.Nodes*(obj.Nodes-1)/2)+18;
            [sorted, ~] = sort(reshape(p.',1,[]));
            sorted(1:tot-m) = [];
            q = 0.05;
            
            for i=1:m
                if sorted(i) > q*i/m
                    if i == 1
                        k = 1;
                    else
                        k = i-1;
                    end
                    break
                else
                    continue
                end
            end

            val = sorted(k);
            obj.Graph = p;

            for i=1:obj.Nodes
                for j = i:obj.Nodes
                    if p(i,j) > val
                        obj.Graph(i,j) = 0;
                    else
                        obj.Graph(i,j) = 1;
                        obj.Graph(j,i) = p(i,j);
                    end
                end
            end
            
            obj = obj.parameters(false);
        end

        function obj = parameters(obj, component)
            % Density
            potential = obj.Nodes*(obj.Nodes-1);
            actual = potential - sum(obj.Graph == 0, 'all');
            obj.Density = actual/potential; 

            % Clustering coefficient (CC)
            % The CC of the network is a matrix, so we take the mean
            obj.Clustering_coeff = mean(clustering_coef_bu(obj.Graph),'all');
            
            % Characteristic path length (CPL)
            % PROBLEM: Lengths between disconnected nodes are set to Inf: THIS WILL ALWAYS BE INF
            % The distance matrix contains lengths of shortest paths between all pairs of nodes
            dist = distance_bin(obj.Graph);
            % The CPL is the average shortest path length in the network
            obj.Char_path_length = mean(dist, "all");
        
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