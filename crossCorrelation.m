classdef crossCorrelation < associationMeasure
    methods
        function obj = measure(obj, window, i, j)
            cc = zeros(2*obj.Max_lag+1,1);
            for lag = -obj.Max_lag:obj.Max_lag
                x = window.Data(:,i);
                y = window.Data(:,j);
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
    end
end