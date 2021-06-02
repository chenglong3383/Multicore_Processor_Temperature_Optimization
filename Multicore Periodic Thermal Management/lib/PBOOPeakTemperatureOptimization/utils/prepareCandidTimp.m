function TM = prepareCandidTimp(dynamicData, config, TM)

%% shortcuts
n = TM.n;
acn = config.activeNum;
limit = dynamicData.limit;

%% initializing

validTarget = false(1, n);
validTarget(config.actcoreIdx) = true;

%% calculating
if dynamicData.kernel == 1
    disp('Pre-computing impulses between nodes in TM for BS...');
    for actId = 1 :acn
        tact = zeros(1, acn);
        tslp = zeros(1, acn);
        validcoreId = config.actcoreIdx(actId);
        validSource = false(1, n);
        validSource(validcoreId) = true;
        for k = 1 : limit(actId)
            tact(actId) = dynamicData.candids.candidTacts{actId}(k);
            tslp(actId) = dynamicData.candids.candidTslps{actId}(k);
            formaltact = retrieveVars(tact, config.actcoreIdx, n);
            formaltslp = retrieveVars(tslp, config.actcoreIdx, n);
            [TM] = completeTimp(TM, formaltslp, formaltact,...
                validSource, validTarget, dynamicData.scalor);
            
        end
    end
    disp('Finish computing impulse between nodes in TM for BS!');
end





