function [peakTem, TM] = inquirePeakT(TM, config, candidTacts, candidTslps, index)
acn = config.activeNum;
tslp = zeros(1, TM.n);
tact = zeros(1, TM.n);
for i = 1 : acn
    id = config.actcoreIdx(i);
    tslp(id) = candidTslps{i}(index(i));
    tact(id) = candidTacts{i}(index(i));
end
[peakTem, ~, ~, TM] = FastBoundedPeakTemperature(TM, tslp, tact, 1);
