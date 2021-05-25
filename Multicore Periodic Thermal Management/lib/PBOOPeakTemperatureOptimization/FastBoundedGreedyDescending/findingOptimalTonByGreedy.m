function [tons, toffs, miniT, S, Tvector, auxData, TM] = findingOptimalTonByGreedy(startCoef, config, TM, tonDirection)


%%
if nargin < 5
    tonDirection = [];
end
if isempty(tonDirection)
    tonDirection = 1;
end
config          = reshapeToColumnVectors(config);
K               = config.K;
activeNum       = config.activeNum;
wcets           = config.wcets;
verbose         = config.verbose;

if tonDirection >= 0
    coefStep    = 1;
else
    coefStep    = -1;
end

if max(K) - 1   >= -1e-3
    error('too large rho!');
end


lowerBoundTvlds  = (2 * config.tswoffs .* K + config.tswons .* K) ./ (1 - K);
lowerCoef       = ceil(lowerBoundTvlds ./ wcets);
lowerCoef       = max(1, lowerCoef);
lowerCoef       = lowerCoef(:);
startCoef       = startCoef(:);
previousCoef    = max(lowerCoef, startCoef);

auxData         = [];
stop            = 0;
while ~stop
    
    currentTvld = previousCoef .* wcets;
    if verbose >= 3
        fprintf(['Searching the optimal toff for ton = [', num2str(previousCoef(:)', '%d '), '] * wcets''\n']);
    end
    
    
    [currenttoffs, currentT, solutionAux, TM] = OptimizeToffsWithConstantTons(currentTvld + config.tswons, config, TM);
    solutionAux.tonCoef = previousCoef;
    auxData     = [auxData; solutionAux];
    S           = solutionAux.S;
    nvalid      = numel(S);
    G           = zeros(1, activeNum);
    g           = zeros(1, activeNum);
    
    for i = 1 : nvalid
        id          = S(i);
        tempCoef    = previousCoef;
        tempCoef(id) = tempCoef(id) + coefStep;
        if tempCoef(id) < lowerCoef(id)
            G(id) = inf;
        else
            tempTvld     = tempCoef .* wcets;
            [~, tempT, ~, TM] = OptimizeToffsWithConstantTons(tempTvld  + config.tswons, config, TM);
            G(id) = (tempT - currentT)/wcets(id);
        end
    end
    
    if min(G) >= 0
        stop = 1;
        if verbose >= 3
           fprintf(['Greedy find optimal ton terminated\n']); 
        end
    else
        argminGs = find(G==min(G));
        miniWcets = Inf;
        miniWcetId = [];
        for i = 1:numel(argminGs)
            if wcets(argminGs(i)) < miniWcets
                miniWcets = wcets(argminGs(i));
                miniWcetId = argminGs(i);
            end
        end
        previousCoef(miniWcetId) = previousCoef(miniWcetId) + coefStep;
        
        if previousCoef(miniWcetId) < lowerCoef(miniWcetId)
            error('internal error! previousCoef must be no less than lowerCoef!')
        end
    end
    
end

tons = currentTvld + config.tswons;
toffs = currenttoffs;
miniT = currentT;
Tvector = solutionAux.Tvector;


