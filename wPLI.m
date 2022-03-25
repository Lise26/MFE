% Code coming from Ghita Ait Ouhmane

classdef wPLI < associationMeasure
   methods
       function wPLI = measure(obj,window, i, j)
            %Compute the common part, imaginary part of the cross-spectrum
            imag_cs = imag(cpsd(window.Data(:,i),window.Data(:,j))); %one sided by default
            %Compute the wPLI
            wPLI = abs(mean(abs(imag_cs) .* sign(imag_cs)))/mean(abs(imag_cs));
       end 
   end
end
