classdef correctedCrossCorrelation < associationMeasure
    methods
        function obj = corrected_cc(obj, window, i, j)
            cross = crossCorrelation();
            cc = cross.cross_correlation(window, i, j);

            corr = zeros(2*window.Max_lag+1,1);
            for lag=-window.Max_lag:window.Max_lag
                corr(lag+window.Max_lag+1,1) = (1/2) * (cc.Value(lag+window.Max_lag+1) - cc.Value(-lag+window.Max_lag+1));
            end
            obj.Value = corr;
        end

        % Returns the maximum corrected cross-correlation
        function res = measure(obj,window,i,j)
            corr = obj.corrected_cc(window, i, j);
            res = max(abs(corr.Value));
        end

        function res = FTmeasure(obj,window,i,j)
            corr = obj.corrected_cc(window, i, j);            
            FT = zeros(2*window.Max_lag+1,1);    
            for lag = -window.Max_lag:window.Max_lag
                FT(lag+window.Max_lag+1,1) = (1/2)*log((1+corr.Value(lag+window.Max_lag+1,1))/(1-corr.Value(lag+window.Max_lag+1,1)));
            end
            sF = max(abs(FT));
            res = sF/sqrt(std(FT));
        end
    end
end