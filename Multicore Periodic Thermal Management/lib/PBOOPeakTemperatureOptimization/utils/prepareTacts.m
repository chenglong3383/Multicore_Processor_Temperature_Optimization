function [tacts, tslps, tons]= prepareTacts(toffs, KorTons, config, id)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  prepare tacts and tslps for calculating peak temperature.
%  input and output parameters have the same unit


%% shortcuts
tswons = config.tswons;
tswoffs = config.tswoffs;
n = config.n;
actId = config.actcoreIdx;
toffs = toffs(:)';
KorTons = KorTons(:)';
%% input check
if nargin < 4  % toff of actived cores are given, default
    idin = actId;
    K = KorTons;
    id = true;
else
    if ~any( actId == id) && id ~= false
        error('input id error');
    end
    
    if id == false % case: toffs and tons are already input, we skip calculating tons
        idin = actId;
        tons = KorTons;
    else % case: input toff are part of all the actived toffs 
        idin = id;
        K = KorTons;
        % validid indicates the valid indexs of tswons, and tswoffs corresponding with idin
        validid = find( actId == idin ); 
        % transform tswons and tswoffs to agree with idin in size
        tswons = shrinkVars(tswons, validid);
        tswoffs = shrinkVars(tswoffs, validid);     
    end
    
end

if numel(toffs) ~= numel(KorTons) || numel(toffs) ~= numel(idin)
    error('input toffs and KorTons must have the same size');
end
% now tswons, tswoff, toffs, and K all have the same size with idin

%% transform variables

% transform them to formal form, size(1, n)
formaltswons  = retrieveVars(tswons, idin, n);
formaltswoffs = retrieveVars(tswoffs, idin, n);
formalToffs = retrieveVars(toffs, idin, n);


% generate formal tons
if id ~= false
    formalK = retrieveVars(K, idin, n);
    formalTons  = formalK ./(1 - formalK) .* formalToffs + formaltswons ./ (1 - formalK);
else
    formalTons = retrieveVars(tons, idin, n);
end


%% calculate tacts and tslps
tacts = ( formalTons + formaltswoffs ) ;
tslps = (formalToffs - formaltswoffs);
tons = formalTons(idin);

end

