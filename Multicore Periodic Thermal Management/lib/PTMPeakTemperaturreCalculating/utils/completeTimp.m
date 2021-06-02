function [TM] = completeTimp(TM, tslp, tact, validSource, validTarget,  scalor)

% Timp stores the history of calculating peak temperature. If we re-calculate the temperature
% with input TON and TOFF that already in the history, we can skip the
% expensive convlution operation and directly use the result.
if isfield(TM, 'Timp')
    Timp = TM.Timp;
else
    Timp = [];
end

if isempty(Timp)
    Timp = ImpulsePeriod2dMat(TM.n, TM.n);
end

% disp(['Before completeTimp, number of impulse: ', num2str(getAllImpulseNum(Timp))]);
for j = 1 : TM.n
    id_heatsource = TM.coreIdx(j);
    
    %% skip simple scenarios
    % if this node is not actived or always stays in one state, we skip
    % this node. The impulse response can be calculated directly from TM
    if ~validSource(id_heatsource)
        continue;
    end
    %% node j is periodically switching between active and sleep
    origATact   = tact(id_heatsource);
    origATslp   = tslp(id_heatsource);
    atact   = origATact;
    atslp   = origATslp;
    
    if atact*scalor < TM.p 
        atact = 0;
    end
    
    if atslp*scalor < TM.p
        atslp = 0;
    end
    
    powerTraced = false;
    
    for i = 1 : TM.n
        id_target = TM.coreIdx(i);
        % The peak temperature must in actived nodes, so we skip
        % non-actived nodes
        if ~validTarget(id_target)
            continue;
        end
        [flag] = ImpMatCheck(Timp, id_target, id_heatsource, origATslp, origATact);
        % the impulse response from j to i is already calculated and saved in Timp, skip...
        if flag
            continue;
        end
        
        
        
        tracelength     = (TM.sizet + 100) * TM.p;
        fftLength       = TM.fftLength;
        
        if ~powerTraced   % if the power trace is not generated
            [origin_ptrace, periodSamplePoints, ~] = ObtainPeriodicPowerTrace(TM.ua(j),...
                TM.ui(j), atact * scalor, atslp * scalor, tracelength, TM.p);
            
            origin_ptrace = origin_ptrace(1:TM.sizet);
            powerTraced = true;
        end
        
        % get the interval for fft
        sampleStart     = floor( TM.tend(id_target, id_heatsource) / TM.p );
        local_maxIndex  = sampleStart + periodSamplePoints * 2;  % sampling two periods
        if local_maxIndex > TM.sizet
            error(['completeTimp: the thermal convolution to be calculated'...
                ' may be inaccurate due to too large period, i.e., ton+toff. To solve'...
                ' this problem, construct a new thermal model structure. The product'...
                ' of property "sizet" and "p" should satisfy "sizet*p > max(tend)+2*period" ']);
        end
        
        if ~isfield(TM, 'isComplete') || ~TM.isComplete(id_target,id_heatsource)
            p               = TM.p;
            t               = 0 : p : p*( TM.sizet - 1);
            if isfield(TM, 'H') && numel(TM.H(:, id_target, id_heatsource))==TM.sizet
                NH = fft( max(TM.H(:, id_target, id_heatsource), 0), fftLength) ;
            else
                NH = fft( max(TM.fitResults{id_target,id_heatsource}.fitresult(t),0),fftLength) ;
            end
            
            if ~isfield(TM, 'fftH')
                TM.fftH = fftH(TM.fftLength, TM.n, TM.n);
                fftHinit(TM.fftH, 1:TM.n);
            end
            % uncomment these two lines to save NH to TM,
            flag2 = fftHwrite(TM.fftH, id_target, id_heatsource, NH);
            if ~flag2
                error('invalid target or heatsource!');
            end
            TM.isComplete(id_target,id_heatsource) = true;
        else
            NH = fftHread(TM.fftH, id_target, id_heatsource);
            if numel(NH) == 1 && NH == 0
                error('invalid target or heatsource!');
            end
        end
        % do fft
        out             = ifft( NH .* fft( (origin_ptrace)', fftLength) ) * TM.p; % convolution
        out_trace       = out(sampleStart : local_maxIndex);
        clear out;
        clear NH;
        % extract one period to creat an object of class PeriodSample
        range1          = 1 : periodSamplePoints ;
        [~, min_id3]    = min( out_trace(range1) ); % find the vMin in the first period
        idx_start_time  = min_id3;
        idx_end_time    = idx_start_time + periodSamplePoints - 1;
        if idx_end_time > numel(out_trace)
            idx_end_time = numel(out_trace);
            warning(['completeTimp: extracting an incomplete convolution period'...
                'the temperature may be inaccurate!']);
        end
        
        imp             = out_trace(idx_start_time : idx_end_time);
        start_time      = (idx_start_time + sampleStart - 1) * TM.p;
        
        %% push the new impulse into Timp
        impulse         = PeriodSample();
        psPush(impulse, imp', TM.p, start_time);
        ImpMatAppendToff(Timp, id_target, id_heatsource, origATslp, origATact, impulse);
    end
end
% disp(['After  completeTimp, number of impulse: ', num2str(getAllImpulseNum(Timp))]);
TM.Timp = Timp;
end