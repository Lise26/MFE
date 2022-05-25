classdef correctedCrossCorrelation < associationMeasure
    methods
        function obj = association(obj, window, i, j)
            cross = crossCorrelation();
            cc = cross.association(window, i, j);
            corr = zeros(cross.Max_lag,1);
            for lag=1:cross.Max_lag
                corr(lag,1) = (1/2) * (cc.Value(lag+cross.Max_lag+1) - cc.Value(-lag+cross.Max_lag+1));
            end
            obj.Value = corr;
        end
    end
end