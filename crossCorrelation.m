classdef crossCorrelation < associationMeasure
    methods
        function obj = association(obj, window, x, y)
            cc = zeros(2*obj.Max_lag+1,1);
            for lag = -obj.Max_lag:obj.Max_lag
                xc = x(obj.Max_lag+1:obj.Max_lag+1+window.Length);
                yc = y(lag+obj.Max_lag+1:lag+obj.Max_lag+1+window.Length);
                meani = mean(xc);
                meanj = mean(yc);
                sigi = std(xc);
                sigj = std(yc);
                frac = 1/(sigi*sigj*window.Length);
                cross = 0;
                for t=1:window.Length
                    cross = cross + ((xc(t)-meani)*(yc(t)-meanj));
                end
                cc(lag+obj.Max_lag+1,1) = frac*cross;
            end
            obj.Value = cc;
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
    end
end