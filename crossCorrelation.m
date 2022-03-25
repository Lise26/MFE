classdef crossCorrelation < associationMeasure
    methods
        % Returns the maximum cross-correlation
        function res = measure(obj, window, i, j)
            cc = zeros(2*window.Max_lag+1,1);
            for lag = -window.Max_lag:window.Max_lag
                x = window.Data(:,i);
                y = window.Data(:,j);
                xc = x(window.Max_lag+1:window.Max_lag+1+n);
                yc = y(lag+window.Max_lag+1:lag+window.Max_lag+1+n);
                meani = mean(xc);
                meanj = mean(yc);
                sigi = std(xc);
                sigj = std(yc);
                frac = 1/(sigi*sigj*n);
                cross = 0;
                for t=1:window.Length
                    cross = cross + ((xc(t)-meani)*(yc(t)-meanj));
                end
                cc(lag+window.Max_lag+1,1) = frac*cross;
            end
            res = max(abs(cc));
        end

        function res = FTmeasure(obj,window,i,j)
            cc = obj.measure(window,i,j);
            FT = zeros(2*window.Max_lag+1,1);    
            for lag = -window.Max_lag:window.Max_lag
                FT(lag+window.Max_lag+1,1) = (1/2)*log((1+cc(lag+window.Max_lag+1,1))/(1-cc(lag+window.Max_lag+1,1)));
            end
            sF = max(abs(FT));
            res = sF/sqrt(std(FT));
        end
    end
end