function [miniT, solution, TM] = repairPBOOPTM(TM, config, dynamicData, solution)

n           = config.activeNum;
actcoreIdx  = config.actcoreIdx;
wcets       = config.wcets;

if size(solution, 2) ~= config.n
    solution = retrieveVars(solution, config.actcoreIdx, config.n);
end

tvld        = solution(2,actcoreIdx) - config.tswons;
tinv        = solution(1,actcoreIdx) + config.tswons;
k           = wcets * dynamicData.rho;
alln        = TM.n;

budget = zeros(1,n);
slope = zeros(1,n);
for i = 1 : n
    id = actcoreIdx(i);
    
    if tvld(i) < wcets(i)
        tvld(i) = wcets(i);
    else
        tvld(i) = floor(tvld(i) / wcets(i)) * wcets(i);
        if tvld(i)/k(i) - tvld(i) < config.tswons(i)
            tvld(i) = ceil(tvld(i) / wcets(i)) * wcets(i);
        end
    end
    
    newtinv = max(config.tswons(i) + config.tswoffs(i), tvld(i)/k(i) - tvld(i));
    budget(i) = tinv(i) - newtinv;
    if budget(i) >= 0 % toff gets smaller
        tinv(i) = newtinv;
    else % toff may get bigger
        
    end
    
end

if any(slope > 0)
    error('not correct');
end
Q = sum(budget(budget > 0));

while Q > 0
    for i = 1 : n
        id = actcoreIdx(i);
        if budget(i) < 0
            slope(i) = getSlope(tinv, tvld, id, min(Q, abs(budget(i))));
        else
            slope(i) = 0;
        end
    end
    [~, ic] = min(slope);
    if budget(ic) < 0
        allo = min(Q, abs(budget(ic)));
        tinv(ic) = tinv(ic) + allo;
        budget(ic) = budget(ic) + allo;
        Q = Q - allo;
    else
        break
    end
end

toffs = tinv - config.tswons;
tons  = tvld + config.tswons;
tactfinal = tons + config.tswoffs;
tslpfinal = toffs - config.tswoffs;
tact2 = zeros(1, alln);
tslp2 = tact2;
tact2(actcoreIdx) = tactfinal;
tslp2(actcoreIdx) = tslpfinal;

[miniT, ~, ~, TM] = FastBoundedPeakTemperature(TM, tslp2, tact2);
solution(1,actcoreIdx) = toffs;
solution(2,actcoreIdx) = tons;


    function slope2 = getSlope(tinvs, tvld, index, step2)
        if nargin < 4
            step2 = 0.2;
        end
        
        tact = zeros(1, alln);
        tslp = tact;
        tact1 = tvld + config.tswons + config.tswoffs;
        tslp1 = tinvs - config.tswons - config.tswoffs;
        tact(actcoreIdx) = tact1;
        tslp(actcoreIdx) = tslp1;
        
        [beforeChange, ~, ~, TM] = FastBoundedPeakTemperature(TM, tslp, tact);
        tslp(index) = tslp(index) + step2;
        [afterChange, ~, ~, TM] = FastBoundedPeakTemperature(TM, tslp, tact);
        slope2 = (afterChange - beforeChange)/step2;
    end
end







