savefile1 = 'IntelSCCTM0.0001p.mat';
savefile2 = 'IntelSCCfloorplan.mat';
if ~exist('TM','var')
    load(savefile1);
    [TM] = preCalculateImpulseAndFFT(TM);
end
load(savefile2);
disp('Thermal model loaded!')


meantoffs = 5 : 10 : 300;

T1 = [];
T2 = [];

ratio = 0.3;
n = TM.n;
activeNum = 12;

toffs = zeros(1, n);

for meantoff = meantoffs
    toffs(1: activeNum) =  meantoff * ones(1, activeNum);
    tons = toffs * ratio;
    
    [Tpeak1, TM] = AccurateNeighborPeakTemperature(TM, toffs, tons);
    [Tpeak2, ~, ~, TM] = FastBoundedPeakTemperature(TM, toffs, tons);
    
    T1 = [T1, Tpeak1];
    T2 = [T2, Tpeak2];
end


plot(meantoffs, T2-T1, 'r-v','linewidth',1);
grid on
legend('two methods difference: FBPT-ANPT');