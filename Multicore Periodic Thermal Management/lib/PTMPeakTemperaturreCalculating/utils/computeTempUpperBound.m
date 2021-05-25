function [Temperature, Tconvs] = computeTempUpperBound(TM, tslp, tact, isAct, isPeriodic)

if ~isfield(TM, 'Timp')
    error('Object Timp is not complete for calculation');
end
Timp = TM.Timp;
if isempty(Timp)
    error('Object Timp is not complete for calculation');
end

Temperature = zeros(1, TM.n);
Tconvs = zeros(TM.n, TM.n);
for i = 1 : TM.n
    id_target = TM.coreIdx(i);
    if ~isAct(id_target)
        continue;
    end
    
    for j = 1 : TM.n
        id_heatsource = TM.coreIdx(j);
        if ~isAct(id_heatsource)
            Tconvs(i, j) = TM.TimpCores2Cores(id_target, id_heatsource);
            Temperature(i) = Temperature(i) + Tconvs(i, j);
            continue;
        end
        if isAct(id_heatsource) && ~isPeriodic(id_heatsource)
            Tconvs(i, j) =  TM.TimpCores2Cores(id_target, id_heatsource)...
                * TM.ua(id_heatsource) / TM.ui(id_heatsource);
            Temperature(i) = Temperature(i) + Tconvs(i, j);
            continue;
        end
        
        [flag, timps] = ImpMatFindImpulse(Timp, id_target, id_heatsource,...
            tslp(id_heatsource), tact(id_heatsource));
        
        if ~flag
            id_target
            id_heatsource
            tslp(id_heatsource)
            tact(id_heatsource)
            error('Object Timp is not complete for calculation');
        end
        if length(timps) > 1
            error('duplicated toff and ton have been appended');
        end
        Temperature(i) = Temperature(i) + timps(1,1).vMax;
        Tconvs(i, j) = timps(1,1).vMax;
    end
    Temperature(i) = Temperature(i) + TM.TimpSumNonCore2Cores(id_target);
end


end