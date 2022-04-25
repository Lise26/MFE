classdef crossCorrelation < associationMeasure
    methods
        function obj = cross_correlation(obj, window, i, j)
            cc = zeros(2*window.Max_lag+1,1);
            for lag = -window.Max_lag:window.Max_lag
                x = window.Data(:,i);
                y = window.Data(:,j);
                xc = x(window.Max_lag+1:window.Max_lag+1+window.Length);
                yc = y(lag+window.Max_lag+1:lag+window.Max_lag+1+window.Length);
                meani = mean(xc);
                meanj = mean(yc);
                sigi = std(xc);
                sigj = std(yc);
                frac = 1/(sigi*sigj*window.Length);
                cross = 0;
                for t=1:window.Length
                    cross = cross + ((xc(t)-meani)*(yc(t)-meanj));
                end
                cc(lag+window.Max_lag+1,1) = frac*cross;
            end
            obj.Value = cc;
        end

        % Returns the maximum cross-correlation
        function res = measure(obj, window, i, j)
            cc = obj.cross_correlation(window, i, j);
            res = max(abs(cc.Value));
        end

        function FT = FTmeasure(obj,window,i,j)
            cc = obj.cross_correlation(window, i, j);
            FT = zeros(2*window.Max_lag+1,1);    
            for lag = -window.Max_lag:window.Max_lag
                FT(lag+window.Max_lag+1,1) = (1/2)*log((1+cc.Value(lag+window.Max_lag+1,1))/(1-cc.Value(lag+window.Max_lag+1,1)));
            end
        end

        function zF = test_stat(obj, window, i, j)
            FT = obj.FTmeasure(window, i, j);
            [sF, index] = max(abs(FT));
            %{
            index = index - window.Max_lag - 1;
            frac = 1/(window.Max_lag-index);
            var = 0;
            FTii = obj.FTmeasure(window, i, i);
            FTjj = obj.FTmeasure(window, j, j);
            for i=-window.Max_lag:window.Max_lag
                var = var + (FTii(i+window.Max_lag+1)*FTjj(i+window.Max_lag+1));
            end
            var = frac*var;
            zF = sF/sqrt(var);
            %}
            zF = sF/std(FT);
        end

    end
end