function [TM] = preCalculateImpulseAndFFT(TM, problemConfig)

disp('Start pre-calculate the Fourier Transformation of impulses between');
disp(['nodes in thermal model of multicore processor ', TM.name]);
p = TM.p;
t = 0 : p : p*( TM.sizet - 1);
n = TM.n;

if ~isfield(TM, 'isComplete')
    TM.isComplete = false(n,n);
end

if nargin > 1
    acn = problemConfig.activeNum;
    actId = problemConfig.isAct;
    activeIdx = problemConfig.actcoreIdx;
else
    acn = n;
    actId = true(1, n);
    activeIdx = 1 : n;
end
if exist('TM.fftH','var')
    delete(TM.fftH);
end
TM.fftH = fftH(TM.fftLength, acn, n);
fftHinit(TM.fftH, activeIdx);

if ~isempty (TM.fitResults{1,1})
    TM.H = single(zeros(numel(t), n, n));
end

for i = 1 : n
    if ~actId(i)
        continue;
    end
    for j = 1 : n
        if ~actId(j)
            continue;
        end        
        if isempty(TM.fitResults{i,j})
            NH = TM.H(:, i, j);
        else
            NH = max( TM.fitResults{i,j}.fitresult(t), 0);
            TM.H(:, i, j) = single(NH);
        end
        flag2 = fftHwrite(TM.fftH, i, j, fft(NH, TM.fftLength));
        if ~flag2
            error('invalid target or heatsource!');
        end
        TM.isComplete(i,j) = true;
    end
end
disp(['Finish pre-calculating']);
