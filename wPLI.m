% Code coming from Ghita Ait Ouhmane

classdef wPLI < associationMeasure
   methods
       function res = measure(obj, window, x, y)
            %wPLI as defined by Vinck et Al, averages over the number of epochs
            % Starts by dividing the signal into epochs 
            % For each epoch, a Hann window function is used on the signal and the wPLI is computed
            % using cpsd and averaged over the epochs
            %The result is an array with the wPLI values for frequencies in the range [0,fs/2]. 
            %The final value is obtained by selecting the range of interest and averaging over it
        
            %Epoching 
            nb_windows = floor((length(x))/(window.Length-window.Overlap));
            x_w = zeros(nb_windows,window.Length); 
            y_w = zeros(nb_windows,window.Length);
        
            for w=1:nb_windows-1
                start = (window.Length-window.Overlap)*(w-1)+1;
                x_w(w,:) = hann(window.Length).'.*x(start:start+window.Length-1);
                y_w(w,:) = hann(window.Length).'.*y(start:start+window.Length-1);
                [S_w(w,:),f_w] = cpsd(x_w(w,:),y_w(w,:),[],[],[],250);
            end
        
            num = abs(mean(imag(S_w),1));
            den = mean(abs(imag(S_w)),1);
            wpli_cpsdVinck = num./den ;
            
            %For EEG signals, select range of frequencies of interest and
            %average over it to obtain a single wPLI value
            [delta,~] = find(f_w>0.5 & f_w<4);
            [theta,~] = find(f_w>4 & f_w<8);
            [alpha,~] = find(f_w>8 & f_w<13);
            [beta,~]  = find(f_w>13 & f_w<30);
            [gamma,~] = find(f_w>30 & f_w<40);
        
            wpli_array = deal([mean(wpli_cpsdVinck(delta),'omitnan'),mean(wpli_cpsdVinck(theta),'omitnan'),...
                               mean(wpli_cpsdVinck(alpha),'omitnan'),mean(wpli_cpsdVinck(beta),'omitnan'),...
                               mean(wpli_cpsdVinck(gamma),'omitnan')]); 
            
            [range,~] = find(f_w>1 & f_w<30);
            res = mean(wpli_cpsdVinck(range),'omitnan');
        
       end

       function wpli_matrix = matrix(obj,data,window)
            % data        : input data in format time x channels
            % output      : wPLI matrix for signals in data
         
            channels = size(data,2);
            wpli_matrix = zeros(channels,channels);
            for i=1:channels
                for j=i+1:channels
                    wpli_matrix(i,j) = obj.measure(window, data(:,i).',data(:,j).');
                end
            end
       end
   end
end