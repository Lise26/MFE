classdef window
    properties
        Length {mustBeNumeric}
        Overlap {mustBeNumeric}
    end
    
    methods
        function obj = window(length_window, overlap)
            obj.Length = length_window;
            obj.Overlap = overlap;
        end
    end
end