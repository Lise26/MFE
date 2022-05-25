classdef associationMeasure
    properties
        Num_window {mustBeNumeric}
        Value
        Max_lag {mustBeNumeric}
    end
    methods
        function obj = associationMeasure()
            obj.Max_lag = 50;
        end

        function obj = association(obj)
            obj.Value = 0;
        end

        function FT = FTmeasure(obj,window,x,y)
            res = obj.association(window,x,y);
            FT = zeros(size(res.Value));    
            for lag = 1:size(res.Value,1)
                %FT(lag,1) = (1/2)*log((1+res.Value(lag,1))/(1-res.Value(lag,1)));
                FT(lag,1) = atanh(res.Value(lag,1));
            end
        end

        function zF = measure(obj, window, x, y)
            test_stat = zeros(obj.Num_window-2,1);
            for w=2:obj.Num_window-1
                start = (window.Length-window.Overlap)*(w-1);
                x_w = x(start-obj.Max_lag:start+window.Length+obj.Max_lag,:);
                y_w = y(start-obj.Max_lag:start+window.Length+obj.Max_lag,:);
                
                FT = obj.FTmeasure(window, x_w, y_w);
                [sF, ~] = max(abs(FT));
                test_stat(w-1,1) = sF/std(FT);
            end
            zF = mean(test_stat);
        end
   
        function res_matrix = matrix(obj,eeg,window)
            res_matrix = zeros(eeg.Channels);
            obj.Num_window = floor((eeg.Points-window.Length+window.Overlap)/(window.Length-window.Overlap)) - 2;
            for i=1:eeg.Channels
                for j=i+1:eeg.Channels
                    res_matrix(i,j) = obj.measure(window,eeg.Data(:,i),eeg.Data(:,j));
                end
            end
        end
    end
end