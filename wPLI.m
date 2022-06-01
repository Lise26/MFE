% Code coming from Ghita Ait Ouhmane's Master Thesis
% Ait Ouhmane, Ghita. 2022. “Assessing consciousness at the Intensive Care
% Unit (ICU)." Master s thesis, Université Libre de Bruxelles.

classdef wPLI < associationMeasure
   methods
       function res = measure(obj, window, x, y)
            %wPLI as defined by Vinck et Al, averages over the number of epochs
            % Starts by dividing the signal into epochs 
            % For each epoch, a Hann window function is used on the signal and the wPLI is computed
            % using cpsd and averaged over the epochs
            %The result is an array with the wPLI values for frequencies in the range [0,fs/2]. 
            %The final value is obtained by selecting the range of interest and averaging over it
        
            %Correct format for this implementation
            x = x.';
            y = y.';
            
            %Epoching 
            x_w = zeros(obj.Num_window,window.Length); 
            y_w = zeros(obj.Num_window,window.Length);
        
            for w=1:obj.Num_window
                start = (window.Length-window.Overlap)*(w-1)+1;
                x_w(w,:) = hann(window.Length).'.*x(start:start+window.Length-1);
                y_w(w,:) = hann(window.Length).'.*y(start:start+window.Length-1);
                [S_w(w,:),f_w] = cpsd(x_w(w,:),y_w(w,:),[],[],[],250);
            end
        
            num = abs(mean(imag(S_w),1));
            den = mean(abs(imag(S_w)),1);
            wpli_cpsdVinck = num./den ;
            
            %Select frequencies of interest and average over it to obtain a single wPLI value            
            [range,~] = find(f_w>1 & f_w<30);
            res = mean(wpli_cpsdVinck(range),'omitnan');
       end
   end
end