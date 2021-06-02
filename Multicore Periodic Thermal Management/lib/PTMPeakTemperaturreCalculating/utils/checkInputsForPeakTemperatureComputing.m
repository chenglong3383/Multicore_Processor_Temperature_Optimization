function [flag, report] = checkInputsForPeakTemperatureComputing(TM, tslp, tact)

flag = 1;
report = [];

if  ~isfield(TM, 'isComplete') || ~isfield(TM, 'fftH')
    flag = 0;
    report = [report, 'warning: the FFT of the impulse in TM has not been',...
        ' pre-calculated! Will result in VERY SLOW temperature calculating speed\n'];
end

if ~isvector(tact)
    flag = -1;
    report = [report, 'error: tact must be a vector\n'];
end

if ~isvector(tslp)
    flag = -1;
    report = [report, 'error: tslp must be a vector\n'];
end

if numel(tact) ~=  TM.n
    flag = -1;
    report = [report, 'error: tact must have TM.n elements\n'];
end

if numel(tslp) ~=  TM.n
    flag = -1;
    report = [report, 'error: tslp must have TM.n elements\n'];
end



end