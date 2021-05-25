function [Tpeak, Tvector, TM] = CalculatePeakTemperatureSmooth(TM, tslp, tact, k, offset)



%% calculate the fast bounded peak temperature
[~, Tvector, ~, TM] = FastBoundedPeakTemperature(TM, tslp, tact);


A = exp( (Tvector - offset)*k );

Tpeak = log(sum(A))/k + offset;



