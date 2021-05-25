function [optToff, optTon, flag, TM] = DPAPTM(beta, feasible, id, TM, config)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% initialize and shortcuts
tswon       = config.tswons(id);
wcet        = config.wcets(id);
step        = config.step;
nodeIdx     = config.actcoreIdx(id); % the id of kth core


flag        = false;
optToff     = 0;
optTon      = 0;
optTemp     = Inf;


%% brutal searching
for tempToff = feasible(1)  : step : feasible(2)
    rho = minspeedbdfEDG( beta, tempToff + tswon);
    K = rho * wcet;
    if K >=0.999
        continue;
    end
    [tact, tslp, ton]= prepareTacts(tempToff, K, config, nodeIdx);
%     ton = K/(1-K) * tempToff + tswon/(1-K);
%     tact = ton + tswoff;  % tact
%     tslp = tempToff - tswoff;  % tslp
    if ( TM.tend(nodeIdx,nodeIdx) + 2*( max(tact + tslp) )/ 1000 ) >=...
            (TM.sizet * TM.p - 0.01) &&  K > 0.9
        Tpeak = max(TM.T_inf_a);
    else
     [Tpeak, TM] = CalculatePeakTemperature(TM, tslp, tact, 'self', nodeIdx);
    end
    if Tpeak < optTemp
        flag    = true;
        optTemp = Tpeak;
        optToff = tempToff;
        optTon  = ton;
    end
    
end
