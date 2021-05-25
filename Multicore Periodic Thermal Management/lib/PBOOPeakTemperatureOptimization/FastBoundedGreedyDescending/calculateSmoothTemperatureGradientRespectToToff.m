function [grd, currentT, grdComplete, TM] = calculateSmoothTemperatureGradientRespectToToff(currentT, TM, config, tacts, tslps, k, offset)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the gradient respect to toffs on point (tons, toffs)
%
%% input check and default arguments
if nargin < 6
    error('not enough inputs');
end

nvar = config.activeNum;

scalor = 0.001; % unit: ms

grd = zeros(1, nvar);

ncores = config.n;

if numel(tacts) ~= ncores || numel(tslps) ~= ncores
    error('input tacts and tslps size error');
end

[~, Tvector, TM] = CalculatePeakTemperatureSmooth(TM, tslps, tacts, k, offset);

Tvector = Tvector(config.actcoreIdx);
grdComplete = zeros(nvar, nvar);
for j = 1 : nvar
    sourceId = config.actcoreIdx(j);
    grd0 = zeros(1, nvar);
    for i = 1 : nvar
        targetId = config.actcoreIdx(i);
        [grd0(i), TM] = calcParticalDerivativeOfTconvWrtToff(TM, targetId, sourceId, tacts(sourceId), tslps(sourceId));
    end
    grd0 = grd0 * scalor;
    grdComplete(:,j) = grd0';
    A = exp( (Tvector - offset)*k );
    A = A(:)';
    grd(j) = (A * grd0')/sum(A);
end

end











