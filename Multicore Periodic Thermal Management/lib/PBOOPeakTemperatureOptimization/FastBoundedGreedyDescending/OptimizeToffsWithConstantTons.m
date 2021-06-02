function [toffs, miniTemp, solutionAux, TM] = OptimizeToffsWithConstantTons(tons, problemConfig, TM, isquick)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
    isquick = [];
end

if isempty(isquick)
    isquick = false;
end


%% prepare and check inputs

% time resolution parameters
scalor          = 0.001; % the default time unit of this function is millisecond
pTact           = TM.p / scalor;

% the limited-memory projected quasi-Newton method demands column vectors
% as inputs
problemConfig   = reshapeToColumnVectors(problemConfig);
originTon       = tons;
tons            = tons(:);
% shortcuts
limitSumToffs   = problemConfig.SumBound;
lseOffset       = problemConfig.lseOffset;
lseK            = problemConfig.lseK;
K               = problemConfig.K;

upperToffs = ( (1 - K) .* tons - problemConfig.tswons ) ./ K;
upperToffs = max(0, upperToffs);
acn = problemConfig.activeNum;
if acn ~= numel(tons)
    error('tons should has numberOfActivatedCores elements');
end
lowerToffs = zeros(size(problemConfig.tswoffs)) ;
%lowerToffs = config.tswoffs ;
if any( upperToffs - lowerToffs < 0)
    error('the feasible toffs between upperToffs and lowerToffs may be a empty set');
end


if sum(upperToffs(:)) <= limitSumToffs + pTact
    toffs = upperToffs(:);
    funEvals = 0;
else
    initToffs = lowerToffs(:);%limitSumToffs/acn * ones(1, acn);
    funObj = @(x) funObjForMinConF_PQN(x);
    funProj = @(x) funProjForMinConF_PQN(x);
    
    option.optTol = 0.0001;
    % option.suffDec = 0.01;
    % option.SPGoptTol = 1e-4;
    option.verbose = 0;
    if isquick
        option.optTol = 0.01;
        option.suffDec = 0.01;
        option.SPGoptTol = 1e-5;
    end
    [toffs, ~, funEvals] = minConF_PQN(funObj, initToffs, funProj, option);
end

[tacts, tslps] = reviseForCalculatingTemperature(tons, toffs, problemConfig, pTact);

% calculate the fast bounded peak temperature
[miniTemp, Tvector, Tconv, TM] = FastBoundedPeakTemperature(TM, tslps, tacts);
Tvector = Tvector(problemConfig.actcoreIdx);
% calculate the gradient of the LSE temperature at the solution
[LSETemperature, Gradient, grdComplete] = funObjForMinConF_PQN(toffs);

S = 1 : numel(toffs);
S = S(abs(toffs(:) - upperToffs)<1e-6);

% let the outputs match the input
if isrow(originTon)
    toffs = toffs(:)';
    S = S(:)';
    Tvector = Tvector(:)';
    Gradient = Gradient(:)';
else
    toffs = toffs(:);
    S = S(:);
    Tvector = Tvector(:);
    Gradient = Gradient(:);
end

solutionAux.tons            = originTon;
solutionAux.toffs           = toffs;
solutionAux.miniT           = miniTemp;
solutionAux.S               = S;
solutionAux.Tvector         = Tvector;
solutionAux.Gradient        = Gradient;
solutionAux.funEvals        = funEvals;
solutionAux.grdComplete     = grdComplete;
solutionAux.LseTemperature  = LSETemperature;
solutionAux.Tconv           = Tconv;




    function [Temperature, Gradient, grdComplete] = funObjForMinConF_PQN(toffs)
        [tacts, tslps] = reviseForCalculatingTemperature(tons, toffs, problemConfig, pTact);
        
        [Temperature, Tvector, TM] = CalculatePeakTemperatureSmooth(TM, tslps, tacts, lseK, lseOffset);
        [Gradient, Temperature, grdComplete, TM] = calculateSmoothTemperatureGradientRespectToToff(Temperature, TM, problemConfig, tacts, tslps, lseK, lseOffset);
        Gradient = Gradient(:);
    end

    function [proj_x] = funProjForMinConF_PQN(toffs0)
        toffs0 = toffs0(:);
        A = ones(1, acn);
        proj_x = findProjectOfPointOnToAnAffineSpace(toffs0, A, limitSumToffs, upperToffs, lowerToffs);
        if isempty(proj_x)
            proj_x = zeros(size(toffs0));
        end
        proj_x = proj_x(:);
    end

end










