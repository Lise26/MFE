classdef correctedCrossCorrelation < associationMeasure
    methods
        function obj = association(obj, window, x, y)
            cross = crossCorrelation();
            cc = cross.association(window, x, y);
            corr = zeros(cross.Max_lag,1);
            for lag=1:cross.Max_lag
                corr(lag,1) = (1/2) * (cc.Value(lag+cross.Max_lag+1) - cc.Value(-lag+cross.Max_lag+1));
            end
            obj.Value = corr;
        end

        function res = measure(obj, window, x, y)
            corr = zeros(obj.Num_window-2,1);
            for w=2:obj.Num_window-1
                start = (window.Length-window.Overlap)*(w-1);
                x_w = x(start-obj.Max_lag:start+window.Length+obj.Max_lag,:);
                y_w = y(start-obj.Max_lag:start+window.Length+obj.Max_lag,:);
                
                obj = obj.association(window, x_w, y_w);
                corr_w = max(abs(obj.Value));
                corr(w-1,1) = corr_w;
            end
            res = mean(corr);
        end
    end
end