classdef window
    properties
        Data
        Length {mustBeNumeric}
        Overlap {mustBeNumeric}
        Max_lag {mustBeNumeric}
    end
    methods
        function obj = window(length_window, overlap, max_lag)
            obj.Length = length_window;
            obj.Overlap = overlap;
            obj.Max_lag = max_lag;
        end

        function obj = data(obj, data, w)
            obj.Data = data(w-obj.Max_lag:w+obj.Length+obj.Max_lag,:);
            obj = obj.normalize();
        end

        function obj = normalize(obj)
            % Normalization of each channel to zero mean and unit variance
            for i=1:size(obj.Data, 2)
                obj.Data(:,i) = obj.Data(:,i) - mean(obj.Data(:,i));
                obj.Data(:,i) = obj.Data(:,i)/std(obj.Data(:,i));
            end
        end
    end
end