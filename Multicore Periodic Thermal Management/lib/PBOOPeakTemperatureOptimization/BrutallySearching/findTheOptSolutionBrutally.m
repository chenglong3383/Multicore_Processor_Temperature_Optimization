function [miniTpeak, final_solution, TM] = findTheOptSolutionBrutally(TM, config)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a revised version of the original brutally searching function.
% The efficiency is improved. For stage number less than 5, this new
% version finds a slightly better solution by refining the original
% solution with a much smaller searching step. 
% 
% this function searches the best toff and ton by testing all
% the possible solutions.

%% shortcuts

n               = TM.n;
acn             = config.activeNum;  % active core number
miniTpeak       = max(TM.T_inf_a);
verbose         = config.verbose;
step            = config.step;
limitSumToffs = config.SumBound;

%% determing feasible toffs and discretized toffs
feasibleRegion = zeros(acn, 2);
% feasibleRegion, (*,1) the lower bounds, (*,2) the upper bpounds

for j = 1 : acn
    if TM.isCore(config.actcoreIdx(j)) == 0
        error('coreIdx in config error');
    end
    feasibleRegion(j,1) = config.tswoffs(j) + config.pToffTon;
    feasibleRegion(j,2) = limitSumToffs;
    if feasibleRegion(j,2) < feasibleRegion(j,1)
        error('b too small');
    end
end

[miniTpeak, solution, TM] = brutallySearchingInRegion(feasibleRegion, step, TM, max(TM.T_inf_a));

if acn < 5
    region = zeros(acn, 2);
    for j = 1 : acn
        region(j,1) = max(solution(1, j) - 1,  feasibleRegion(j, 1));
        region(j,2) = min(solution(1, j) + 1,  feasibleRegion(j, 2));
    end
    newstep = max(0.1, step/5);
    if verbose >= 3
        disp('BS: refine the solution with a finer searching step!');
    end
    [miniTpeak, solution, TM] = brutallySearchingInRegion(region, newstep, TM, miniTpeak);
end


final_solution = zeros(2, n);
final_solution(:, config.actcoreIdx) = solution;

    function [miniTpeak, solution, TM] = brutallySearchingInRegion(region, searchStep, TM, upperBound)
        miniTpeak       = upperBound;
        oldIndex        = ones(1, acn); % oldIndex(i) determined which toff in candidToffs{i} is currently
        % choosed
        optIndex        = zeros(1, acn);
        solution        = zeros(2, acn);
        candidToffs     = cell(acn, 1);
        candidTons      = cell(acn, 1);
        upperToffs      = cell(acn, 1);
        candidTslps     = cell(acn, 1);
        candidTacts     = cell(acn, 1);
        
        limit           = zeros(1, acn);
        K               = config.K;
        for i = 1 : acn
            candidToffs{i} = [0, region(i, 1) : searchStep : region(i, 2)];
            candidTslps{i} = max(0, candidToffs{i} - config.tswoffs(i));
            alwaysOn = candidToffs{i} < config.tswoffs(i);
            
            limit(i) = numel(candidToffs{i});
            tinvs = candidToffs{i} + config.tswons(i);
            minTvld = K(i) / (1-K(i)) .* tinvs;
            minTvld = ceil(minTvld ./ config.wcets(i)) .* config.wcets(i);
            
            candidTons{i} = minTvld + config.tswons(i) ;
            candidTacts{i}= candidTons{i} + config.tswoffs(i);
            
            upperToff = ( (1 - K(i)) .* candidTons{i} - config.tswons(i) ) ./ K(i);
            upperToff(alwaysOn) = 0;
            upperToffs{i} = upperToff;
        end
        
        %% initializing
        
        validTarget = false(1, n);
        validTarget(config.actcoreIdx) = true;
        
        %% calculating
        if verbose >= 3
            disp('Pre-computing impulses between nodes in TM for BS...');
        end
        for actId = 1 : acn
            tact = zeros(1, acn);
            tslp = zeros(1, acn);
            validcoreId = config.actcoreIdx(actId);
            validSource = false(1, n);
            validSource(validcoreId) = true;
            for k = 1 : limit(actId)
                tact(actId) = candidTacts{actId}(k);
                tslp(actId) = candidTslps{actId}(k);
                formaltact = retrieveVars(tact, config.actcoreIdx, n);
                formaltslp = retrieveVars(tslp, config.actcoreIdx, n);
                [TM] = completeTimp(TM, formaltslp, formaltact,...
                    validSource, validTarget, config.scalor);
                
            end
        end
        if verbose >= 3
            disp('Finish computing impulse between nodes in TM for BS!');
        end
        
        %% display arguments
        total = 1;
        for i = 1 : acn
            total = total * limit(i);
        end
        if total < 5000
            numticks = 10;
        else
            if total < 20000
                numticks = 100;
            else
                if total < 100000000
                    numticks = 200;
                else
                    numticks = 1000;
                end
            end
        end
        disp_ticks = round(linspace(0, total, numticks));
        percent_tick = linspace(0, 100, numticks);
        tickid = 1;
        
        count = 0;
        
        if verbose >= 2
            disp(['BS: checking ', num2str(total, '%d'), ' solution candidates']);
        end
        %% do the searching
        stop = 0;
        tstart=tic;
        
        toffs = zeros(1, acn);
        tons  = zeros(1, acn);
        upperToff = zeros(1, acn);
        
        while ~stop
            
            
            for i = 1 : acn
                toffs(i) = candidToffs{i}(oldIndex(i));
                tons(i)  = candidTons{i}(oldIndex(i));
                upperToff(i) =  upperToffs{i}(oldIndex(i));
            end
            
            if verbose >= 3 && count > disp_ticks(tickid)
                timeExpense = toc(tstart);
                disp(['BS: complete ', num2str(percent_tick(tickid)), '%, current', ...
                    ' best temperature ', num2str(miniTpeak, '%.3f'), ' (K)', ...
                    ' remain time: ', num2str( 100*timeExpense/percent_tick(tickid)...
                    -  timeExpense, '%.5d'), ' s' ]);
                if tickid  < numticks
                    tickid = tickid + 1;
                end
            end
            
            ifCheckTemp = 1;
            if sum(upperToff) < limitSumToffs
                if max(upperToff - toffs) > step
                    ifCheckTemp = 0;
                end
            else
                if sum(toffs) + step < limitSumToffs
                    ifCheckTemp = 0;
                end
            end
            
            % check if current toffs satisfy the deadline bounds
            if  sum(toffs) > limitSumToffs
                ifCheckTemp = 0;
            end
            
            if ~ifCheckTemp % check next solution
                [oldIndex, flag] = updateIndex(acn, limit, oldIndex);
                count = count +1;
                if flag
                    stop = 1;
                end
                continue;
            end
            
            % get current peak temperature
            
            [peakTem, TM] = inquirePeakT(TM, config, candidTacts, candidTslps, oldIndex);
            
            % update result
            if peakTem < miniTpeak
                miniTpeak = peakTem;
                optIndex = oldIndex;
            end
            
            % update current toffs, go to next point
            [oldIndex, flag] = updateIndex(acn, limit, oldIndex);
            
            count = count +1;
            
            % entire space explored
            if flag
                stop = 1;
            end
        end
        
        % prepare results
        if ~any( optIndex == 0 )
            for i = 1 : acn
                solution(1, i) = candidToffs{i}(optIndex(i));
                solution(2, i) = candidTons{i}(optIndex(i));
            end
        end
        
        
    end


end
