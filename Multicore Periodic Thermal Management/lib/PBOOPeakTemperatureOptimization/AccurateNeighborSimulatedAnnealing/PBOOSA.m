function [solution, Tpeak, exitflag, output, TM, objectFunLog, objectFunLogId] = PBOOSA(TM, config, objectFunLog, objectFunLogId)
%% pre-processing
scalor  = 0.001;

p = TM.p/scalor;

K       = config.K;
SumBound = config.SumBound;
verbose = config.verbose;


% default N is 10. If 10*wcet > 1000, N is revised as 1000/wcet
actWCETs = config.wcets;

lbTonN = ceil(config.tswons ./ (1-K) ./ actWCETs);

defaultTonNs = lbTonN;

ubToffs = SumBound * ones(1, numel(actWCETs));

ubTonN = ceil(minimalTon(ubToffs)./ actWCETs) + 5;

defaultX = [defaultTonNs];


xNum = numel(defaultX);


%% Start with the default options
options = saoptimset;
%% Modify options setting
insulationFactor = 1;
miniTemp = 1;
maxt = TM.sizet * TM.p;
tendA = max(max(TM.tend(1:config.n,1:config.n)));

maxFunEvals = 2000*xNum;

if isempty(objectFunLog)
    objectFunLog = zeros(maxFunEvals*3, xNum+1);
    objectFunLogId = 1;
end

TolFun_Data = 1e-03;
DisplayInterval_Data = 100;
InitialTemperature = 100 * ones(1, xNum);
[specialTonN, specialToffs, ~] = guessMinTonNForEmptyS(config, TM);
specialTonN = specialTonN(:)';
if all(specialTonN == 1)
    bestX = specialTonN(:)';
    Tpeak = ObjectFun(bestX);
    exitflag = [];
    output = [];
else  
    ubTonN = min(ubTonN, specialTonN);
    options = saoptimset(options,'TolFun', TolFun_Data);
    options = saoptimset(options,'MaxFunEvals', maxFunEvals);
    
    if verbose >= 3
        options = saoptimset(options,'Display', 'iter');
        options = saoptimset(options,'DisplayInterval', DisplayInterval_Data);
    else if verbose >= 2
            options = saoptimset(options,'Display', 'final');
        else
            options = saoptimset(options,'Display', 'off');
        end
    end
        

    options = saoptimset(options,'AnnealingFcn', @annealingCSA);
    options = saoptimset(options,'TemperatureFcn', @myTemperatureFCN);
    options = saoptimset(options,'StallIterLimit', max(100,200*xNum));
    %options = saoptimset(options,'TimeLimit', 600);
    
    options = saoptimset(options,'InitialTemperature', InitialTemperature);
    
    [bestX,Tpeak,exitflag,output] = ...
        simulannealbnd(@ObjectFun,defaultX,lbTonN,ubTonN,options);
end


bestTons = bestX.*actWCETs + config.tswons;
[bestToffs, ~, ~, TM] = OptimizeToffsWithConstantTons(bestTons, config, TM);

solution = [bestToffs;bestTons];

    function T = ObjectFun(X)
        [flag, T0] = checkobjectFunLog(X);
        if flag
            T = T0;
            return;
        end
        tons = X.*actWCETs + config.tswons;
        if all(X >= specialTonN)
            toffs = specialToffs;
        else
            [toffs, ~, ~, TM] = OptimizeToffsWithConstantTons(tons, config, TM, 0);
        end
        
        
        [tact, tslp]= prepareTacts(toffs, tons, config, false);
        tact = round(tact/p)*p;
        tslp = round(tslp/p)*p;

        [T, TM] = AccurateNeighborPeakTemperature(TM, tslp, tact);
        
        objectFunLog(objectFunLogId, :) = [X(:)', T];
        objectFunLogId = objectFunLogId + 1;
    end

    function [flag, T] = checkobjectFunLog(X0)
        [flag, id] = ismember(X0(:)', objectFunLog(1:objectFunLogId, 1:xNum), 'row' );
        if flag
            T = objectFunLog(id, xNum+1);
        else
            T = Inf;
        end
    end

    function ton = minimalTon(toff)
        ton = K ./ (1-K) .* toff + config.tswons ./ (1-K);
    end
    function toff = maximalToff(ton)
        toff =  ( (1 - K) .* ton - config.tswons ) ./ K;
    end

    function [c0, c1] = checkTonConstraints(toff, tonN)
        c0 = -1;
        c1 = -1;
        if any(tonN < lbTonN)
            return;
        end
        
        if any(tonN > ubTonN)
            return;
        end
        
        ton = tonN .* actWCETs + config.tswons;
        miniTon =  minimalTon(toff);
        if any(ton - miniTon < -1e-6 )
            return;
        end
        c0 = 1;
        period = (ton(:)' + toff(:)')*scalor;
        if any( tendA + period*2.2 > maxt)
            return;
        end
        c1 = 1;
        
    end

    function [newx] = annealingCSA(optimValues,problem)
        currentx = optimValues.x;
        current_tonN = currentx;
        current_tonN = current_tonN(:)';
        
        ton_temperature = optimValues.temperature;
        ton_temperature = ton_temperature(:)';
        
        while true
            
            newTonN = randomTonNInRange(current_tonN, ubTonN, lbTonN, ton_temperature, InitialTemperature);
            maxtoff = maximalToff(newTonN .* actWCETs + config.tswons);

            [c0, c1] = checkTonConstraints(maxtoff, newTonN);
            if c0 < 0
                disp('annealingCSA: this should not appear');
                continue;
            else if c1 < 0
                    continue;
                else
                    break;
                end
            end
        end
        
        newx = newTonN;
    end

    function [temp] = myTemperatureFCN(optimValues, options)
        temp = options.InitialTemperature - (optimValues.k./insulationFactor);
        
        temp(temp < miniTemp) = miniTemp;
    end

end

