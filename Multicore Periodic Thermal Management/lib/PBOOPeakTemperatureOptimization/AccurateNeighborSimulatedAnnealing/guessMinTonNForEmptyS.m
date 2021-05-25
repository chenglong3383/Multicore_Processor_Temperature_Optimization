function [tonN, toffs, miniTemp] = guessMinTonNForEmptyS(config, TM)


% time resolution parameters
scalor          = 0.001; % the default time unit of this function is millisecond
pTact           = TM.p / scalor;

% the limited-memory projected quasi-Newton method demands column vectors
% as inputs
config          = reshapeToColumnVectors(config);

% shortcuts
limitSumToffs   = config.SumBound;
K               = config.K;


nvar            = numel(config.wcets);
tonN            = ones(nvar, 1);

changeId        = 1;
while true
    tons = tonN.*config.wcets + config.tswons;
    upperToffs = ( (1 - K) .* tons - config.tswons ) ./ K;
    
    if sum(upperToffs(:)) > limitSumToffs + pTact
        break;
    end
    tonN(changeId) = tonN(changeId) + 1;
    
    changeId = changeId + 1;
    if changeId > nvar
        changeId = 1;
    end
end



while true
    tons = tonN.*config.wcets + config.tswons;
    [toffs, miniTemp, solutionAux, TM] = OptimizeToffsWithConstantTons(tons, config, TM, 0);
    
    if isempty(solutionAux.S)
        break;
    end
    tonN(changeId) = tonN(changeId) + 1;
    
    changeId = changeId + 1;
    if changeId > nvar
        changeId = 1;
    end
end



end