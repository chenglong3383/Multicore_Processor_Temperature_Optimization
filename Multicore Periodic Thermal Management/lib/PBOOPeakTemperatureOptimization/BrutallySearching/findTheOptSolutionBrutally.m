function [miniTpeak, solution, TM] = findTheOptSolutionBrutally(TM, config, dynamicData)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function searches the best toff and ton by testing all
% the possible solutions.

%% shortcuts
candids         = dynamicData.candids;
limit           = dynamicData.limit;
b               = dynamicData.b;
n               = TM.n;
acn             = config.activeNum;  % active core number
solution        = zeros(2,n);
miniTpeak       = max(TM.T_inf_a);
candidToffs     = candids.candidToffs;
candidTons      = candids.candidTons;
verbose         = config.verbose;
oldIndex        = ones(1, acn); % oldIndex(i) determined which toff in candidToffs{i} is currently
                                % choosed
optIndex        = zeros(1, acn);


%limitSumToffs = b - config.sumWcet; //incorrect
limitSumToffs = dynamicData.SumBound;
%% display arguments
total = 1;
for i = 1 : acn
    total = total * limit(i);
end
if total < 5000
    numticks = 10;
else if total < 20000
        numticks = 100;
    else
        numticks = 200;
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
while ~stop
    
     [toffs, ~] = getPTMs(candids, oldIndex);
     
     if count > disp_ticks(tickid) && verbose >= 3
         disp(['BS: complete ', num2str(percent_tick(tickid)), '%, current', ...
               ' best temperature ', num2str(miniTpeak, '%.3f'), ' (K)']);
         if tickid  < numticks
             tickid = tickid + 1;
         end
     end
    
    
    % check if current toffs satisfy the deadline bounds
    if sum(toffs) > limitSumToffs
        [oldIndex, flag] = updateIndex(acn, limit, oldIndex);
        count = count +1;
        if flag
            stop = 1;
        end
        continue;
    end
    
    % get current peak temperature
    
    [peakTem, TM] = inquirePeakT(TM, config, candids, oldIndex);

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
        solution(1,i) = candidToffs{i}(optIndex(i));
        solution(2,i) = candidTons{i}(optIndex(i));
    end
end
