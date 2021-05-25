function [miniTpeak, solution, TM] = PBOOsubStep(dynamicData, config, TM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solve the problem of finding the minimal peak
% temperature for a multi-core platform with the given
% searching space by adopting pay burst only once.
% This is a subproblem of the PBOO problem.
%
% INPUT:
%  dynamicData:
%       b and rho:      boundaries of the searching space
%       kernel:         the kernel used to solve pboo sub problem
%
%       config          a struct containing configuration information of
%       tasks, containing
%           actcoreIdx  the index of actived cores
%           wcets       worst case execution time of the cores indexed by
%                       actcoreIdx
%           tswons      switch on overhead of the cores indexed by actcoreIdx
%           tswoffs     switch off overhead of the cores indexed by actcoreIdx
%           activeNum   the number of actived cores
%           alpha       the arrival curve of workload
%           deadline    end to end deadline
%           N           node number
%           n           core number
%           flp         the floorplan struct
%
%       TM              the thermal model, members are:
%       lc_a/lc_i       linear coefficient of DE in active/idel mode
%       ua/ui           the vector of the constant of DE in active/idle mode
%       initT           the initial temperature
%       fftH            the fourier transform of impulse response of the thermal LTI system.
%                       should be a N times N matrix
%       T_inf_a         the state steady temperature in active mode
%       coreIdx         indicates which nodes are cores.
%       p               resolution of time vector
%       tend            tend(i,j) indicates where H( ,i,j) becomes 0
%       isCore          if node(i) is (or not) a core, 1 / 0
%       Tconstmax       the constant impulse from non-core nodes
%       n               number of processing components
%       N               number of nodes
%       sizet           the length of time vector.
%
% OUTPUT:
%       miniTpeak       the minimal peak temperature
%       solution        the optimal solution of toffs and tons
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% input check and initialize
rho         = dynamicData.rho;
b           = dynamicData.b;
kernel      = dynamicData.kernel;
if rho * max(config.wcets) >= 0.99
    error('PBOOsubStep: I can''t find a solution to tons. \rho is too large');
end

if ~( kernel == 1 || kernel == 2 || kernel == 3 )
    error('kernel should be 1, 2, 3');
end

%% shortcuts
p           = TM.p;
scalor      = 0.001; % the unit of toff and ton is ms, scale between ms and s
pToffTon    = p / scalor;  %% the resolution of toff and ton, unit ms
K           = rho * config.wcets;
SumBound    = b - config.sumWcet - config.sumTswon;



dynamicData.pToffTon = pToffTon;
dynamicData.scalor = scalor;
dynamicData.K   = K;
dynamicData.SumBound = SumBound;

if kernel == 2
    dynamicData.isSA = true;
else
    dynamicData.isSA = false;
end

%% determine the feasible region of toffs

dynamicData = getfeasibleRegion(dynamicData, config, TM);

if SumBound <= config.sumTswoff
    miniTpeak = max(TM.T_inf_a(config.actcoreIdx));
    solution(1,:) = zeros(1, config.n);
    solution(2,:) = ones(1, config.n);
    return;
end

%% prepare candidates of toff and ton for brutally searching
dynamicData = prepareCandids(dynamicData, config);


%% prepare the Timp of candidate toffs, which is used as a lookup table

TM = prepareCandidTimp(dynamicData, config, TM);

config.SumBound     = dynamicData.SumBound;
config.lseOffset    = dynamicData.lseOffset;
config.lseK         = dynamicData.lseK;
config.K            = dynamicData.K;

%% sloving
switch kernel
    case 1
        [~, solution, TM] = findTheOptSolutionBrutally(TM, config, dynamicData);
        [miniTpeak, solution, TM] = repairPBOOPTM(TM, config, dynamicData, solution);
    case 2
        startCoef = ones(1, config.activeNum);
        [tons, toffs, miniTpeak, ~, ~, ~, TM] = findingOptimalTonByGreedy(startCoef, config, TM);
        solution(1,:) = toffs;
        solution(2,:) = tons;
    case 3
        miniTpeak = inf;
        objectFunLog = [];
        objectFunLogId = [];
        for i = 1 : config.san
            [s, T , ~ , ~, TM, objectFunLog, objectFunLogId] = PBOOSA(TM, config, objectFunLog, objectFunLogId);
            if T < miniTpeak
                miniTpeak = T;
                solution = s;
            end
        end
end








