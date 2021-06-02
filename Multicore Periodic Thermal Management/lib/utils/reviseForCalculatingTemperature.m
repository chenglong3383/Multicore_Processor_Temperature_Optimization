function [tacts, tslps] = reviseForCalculatingTemperature(tons, toffs, config, p)



if ~isVectorsSizeEqual(tons, toffs, config.tswoffs)
    error('input vectors size not equal');
end

tacts = tons + config.tswoffs;
tslps = toffs - config.tswoffs;
tacts = round(tacts/p)*p;
tslps = round(tslps/p)*p;


tacts = retrieveVars(tacts, config.actcoreIdx, config.n);
tslps = retrieveVars(tslps, config.actcoreIdx, config.n);

tacts = max(0, tacts);
tslps = max(0, tslps);

end