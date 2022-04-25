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
      Degree {mustBeNumeric}
    end
    
    methods
        function obj = network(nodes)
            obj.Nodes = nodes;
        end

        function obj = construction(obj, window, measure, s_test, bootstrap)
            matrix = zeros(obj.Nodes);
            p_values = zeros(obj.Nodes);

            % Use a statistical test to generate the association matrix
            if s_test == true
                a = sqrt(2*log(window.Length));
                b = a - (2*a)^(-1)*(log(log(window.Length))+log(4*pi));
                for i=1:obj.Nodes
                    for j=i+1:obj.Nodes
                        matrix(i,j) = measure.test_stat(window, i, j);
                        p_values(i,j) = exp(-2*exp(-a*(matrix(i,j)-b)));
                    end
                end

                disp(matrix)
                disp(p_values)

                tot = obj.Nodes*obj.Nodes;
                m = obj.Nodes*(obj.Nodes-1)/2;
                [sorted, ~] = sort(reshape(p_values.',1,[]));
                sorted(1:tot-m) = [];
                disp(sorted)
                q = 0.05;
                % q = 0.1;
                % q = 0.25;
                th = q/m;
                
                for i=1:m
                    if sorted(i) > th*i
                        k = i-1;
                        break
                    else
                        if i == m
                            k = i;
                        end
                        continue
                    end
                end

    
                if k == 0
                    k = 1;
                end
                val = sorted(k);
                disp(k)
                %disp("Confidence in the network (number of false positives - percentage)")
                %disp(q*k)
                obj.Graph = p_values;
    
                obj.Graph(obj.Graph>val)=0;
                obj.Graph(obj.Graph~=0)=1;
                obj.Graph = (obj.Graph+obj.Graph') ; %Make it symmetric
            
            elseif bootstrap == true
                for i=1:obj.Nodes
                    for j=i+1:obj.Nodes
                        matrix(i,j) = measure.measure(window, i, j);
                    end
                end

                for ns=1:10000
                    % Power spectrum (Hanning tapered)
                    SE = dsp.SpectrumEstimator;
                    dat = window.Data;
                    hann_w = hann(size(window.Data,1));
                    for i=1:obj.Nodes
                        dat(:,i) = window.Data(:,i).*hann_w;
                    end
                    spect = SE(dat);
    
                    % Average power spectra from all time series
                    av_spect = zeros(size(spect,1),1);
                    for i=1:size(spect,1)
                        av_spect(i) = sum(spect(i,:))/obj.Nodes;
                    end
    
                    % Smooth the resulting average spectrum
                    filter = av_spect;
                    for i=6:size(av_spect,1)-5
                        mov_av = sum(av_spect(i-5:i+5))/11;
                        filter(i) = mov_av;
                    end
                    pw = av_spect.*filter;
    
                    resid = window.Data;
                    for i=1:obj.Nodes
                        resid(:,i) = ifft(fft(window.Data(:,i)./sqrt(pw)));
                    end
    
                    surr = window.Data;
                    for i=1:obj.Nodes
                        surr(:,i) = ifft(fft(resid(:,i).'*sqrt(av_spect)));
                    end
    
                    window.Data = surr;
                    s_surr = zeros(obj.Nodes);
                    for i=1:obj.Nodes
                        for j=i+1:obj.Nodes
                            s_surr(i,j) = measure.measure(window, i, j);
                        end
                    end
                    if ns == 1
                        res = s_surr;
                    end
                    res = cat(3,res,s_surr);
                end

            % compute p-values
            for i=1:obj.Nodes
                for j=i+1:obj.Nodes
                    s = 0;
                    for b=1:ns
                        if res(i,j,b) >= matrix(i,j)
                            s = s+1;
                        end
                    end
                    p_values(i,j) = s/ns; 
                end
            end

            tot = obj.Nodes*obj.Nodes;
            m = obj.Nodes*(obj.Nodes-1)/2;
            [sorted, ~] = sort(reshape(p_values.',1,[]));
            sorted(1:tot-m) = [];
            % q = 0.05;
            q = 0.1;
            th = q/m;
            
            for i=1:m
                if sorted(i) > th*i
                    k = i-1;
                    break
                end
            end

            if k == 0
                k = 1;
            end
            val = sorted(k);
            % disp("Confidence in the network (number of false positives)")
            % disp(q*k)
            obj.Graph = p_values;

            obj.Graph(obj.Graph>val)=0;
            obj.Graph(obj.Graph~=0)=1;
            obj.Graph = (obj.Graph+obj.Graph') ; %Make it symmetric
                
            % Use a threshold to generate the association matrix
            else
                for i=1:obj.Nodes
                    for j=i+1:obj.Nodes
                        matrix(i,j) = measure.measure(window, i, j);
                    end
                end
                obj.Graph = (obj.Graph+obj.Graph') ; %Make it symmetric
                obj.Graph = threshold_proportional(matrix, 0.235);
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

            % Mean degree
            obj.Degree = mean(degrees_und(obj.Graph), "all");

        end
    end
end