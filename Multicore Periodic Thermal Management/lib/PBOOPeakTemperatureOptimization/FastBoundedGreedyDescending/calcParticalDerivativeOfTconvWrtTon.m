function [g, TM] = calcParticalDerivativeOfTconvWrtTon(TM, i, j, tact, tslp)



scalor = 0.001;
pTact = TM.p / scalor;

validSource = false(1, TM.n);
validTarget = false(1, TM.n);

validSource(j) = true;
validTarget(i) = true;

tacts = zeros(1, TM.n);
tslps = zeros(1, TM.n);
tacts(j) = tact;
tslps(j) = tslp;

[TM] = completeTimp(TM, tslps, tacts, validSource, validTarget,  scalor);

[flag, timps] = ImpMatFindImpulse(TM.Timp, i, j, tslp, tact);

if flag
    tPeak = timps(1).tPeak / scalor;
else
    error('The impulse between j and i should already been calculated!');
end


period = (tact+tslp);
period = round(period/pTact)*pTact;

N = floor(tPeak/period);
d = tPeak - N*period;

periodLength = round(period / pTact);
dLength = round(d / pTact);
tactLength = round( tact / pTact );
tslpLength = round( tslp / pTact );

Ua = TM.ua(j); 
Us = TM.ui(j);


vectorId1 = dLength  : periodLength :  (dLength + (N-1)*periodLength);
if dLength  < 1
    vectorId1(1) = 1;
end
vectorId2 = dLength + tslpLength  : periodLength : (dLength + (N-1)*periodLength + tslpLength);
if dLength + tslpLength  < 1
    vectorId2(1) = 1;
end

if dLength < tactLength
    epsilon = dLength/tactLength;
    vectorCoef1 = epsilon : numel(vectorId1) - 1 + epsilon;
    vectorCoef2 = vectorCoef1;
else
    vectorCoef1 = 1 : numel(vectorId1);
    vectorCoef2 = vectorCoef1;
end



g = (Ua - Us) * (vectorCoef1 * double( TM.H(vectorId1, i, j)) - vectorCoef2 * double( TM.H(vectorId2, i, j) ) ) ;







