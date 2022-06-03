% window class
% Creates the window object with its properties

classdef window
    properties
        Length {mustBeNumeric}
        Overlap {mustBeNumeric}
    end
    
    methods
        % Constructor
        function obj = window(length_window, overlap)
            obj.Length = length_window;
            obj.Overlap = overlap;
        end
    end
end