classdef associationMeasure
    properties
        Value
        Max_lag {mustBeNumeric}
    end
    methods
        function obj = associationMeasure()
            obj.Max_lag = 50;
        end

        function obj = measure(obj)
            obj.Value = 0;
        end

        function FT = FTmeasure(obj,window,i,j)
            res = obj.measure(window, i, j);
            FT = zeros(size(res.Value));    
            for lag = 1:size(res.Value,1)
                FT(lag,1) = (1/2)*log((1+res.Value(lag,1))/(1-res.Value(lag,1)));
            end
        end

        function zF = test_stat(obj, window, i, j)
            FT = obj.FTmeasure(window, i, j);
            [sF, ~] = max(abs(FT));
            zF = sF/std(FT);
        end

        function res_matrix = matrix(obj, wind, channels)
            res_matrix = zeros(channels);
            for i=1:channels
                for j=i+1:channels
                    res_matrix(i,j) = obj.test_stat(wind, i, j);
                end
            end
        end
    end
end