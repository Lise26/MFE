% associationMeasure class
% Parent class of all association measures (cross-correlation, corrected
% cross-correlation and wPLI

classdef associationMeasure
    properties
        Num_window {mustBeNumeric}
        Value
        Max_lag {mustBeNumeric}
    end
    methods
        % Constructor
        function obj = associationMeasure()
            % Initialization of the lag
            obj.Max_lag = 50;
        end

        function obj = association(obj)
            obj.Value = 0;
        end
   
        % Compute the association matrix between all pair of nodes for a
        % given EEG signal
        function res_matrix = matrix(obj,eeg,window)
            res_matrix = zeros(eeg.Channels);
            obj.Num_window = floor((eeg.Points-window.Length+window.Overlap)/(window.Length-window.Overlap)) - 2;
            for i=1:eeg.Channels
                for j=i+1:eeg.Channels
                    res_matrix(i,j) = obj.measure(window,eeg.Data(:,i),eeg.Data(:,j));
                end
            end
        end
    end
end