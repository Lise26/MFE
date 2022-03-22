classdef crossCorrelation < associationMeasure
    methods
        function res = measure(obj,x,y,n,max_lag, corrected)
            res = zeros(2*max_lag+1,1);
            for lag = -max_lag:max_lag
                xc = x(max_lag+1:max_lag+1+n);
                yc = y(lag+max_lag+1:lag+max_lag+1+n);
                meani = mean(xc);
                meanj = mean(yc);
                sigi = std(xc);
                sigj = std(yc);
                frac = 1/(sigi*sigj*n);
                cross = 0;
                for t=1:n
                    cross = cross + ((xc(t)-meani)*(yc(t)-meanj));
                end
                res(lag+max_lag+1,1) = frac*cross;
            end
            if corrected == true
                corr = zeros(2*max_lag+1,1);
                for lag=-max_lag:max_lag
                    corr(lag+max_lag+1,1) = (1/2) * (res(lag+max_lag+1) - res(-lag+max_lag+1));
                end
                res = corr;
            end
        end

        function res = FTmeasure(obj,x,y,n,max_lag)
            cc = measure(obj,x,y,n,max_lag,false);
            res = zeros(2*max_lag+1,1);    
            for lag = -max_lag:max_lag
                res(lag+max_lag+1,1) = (1/2)*log((1+cc(lag+max_lag+1,1))/(1-cc(lag+max_lag+1,1)));
            end
        end
    end
end