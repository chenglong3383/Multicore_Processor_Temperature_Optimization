function problemConfig = PBOOOptimizationProblemConfig(alpha, deadline, wcets, tswons, tswoffs, activeNum, flp, N, n)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% return the stucture 'problemConfig' for fucntion 'PayBurstOnlyOnceMinimizing.m'
% based on the user determined arguments.
% Call:     problem = PBOOOptimizationProblemConfig(wcets, tswons, tswoffs, step, activeNum,
%                   flp, N, n)
% Input:
%           alpha       the arrival curve of workload
%           deadline    the end to end, relative deadline of workload
%           wcets       the WCET vector of all the cores, having n elements
%           tswons      the t_swon vector of all the cores, having n elements
%           tswoffs     the t_swoff vector of all the cores, having n elements
%           activeNum   the number of actived cores 
%           flp         the structure of floorplan, containing the name of
%                       nodes, the size and location of nodes, and the
%                       distance between node #1 and each other node 
%           N           the number of nodes
%           n           the number of cores

% Output:
%           config      the stuct containing the configuration, which
%                       are:
%           actcoreIdx  the index of actived cores
%           isAct       indicates if the core is active
%           wcets       worst case execution time of the cores indexed by
%                       actcoreIdx
%           tswons      switch on overhead of the cores indexed by actcoreIdx
%           tswoffs     switch off overhead of the cores indexed by actcoreIdx
%           activeNum   the number of actived cores 
%           alpha       the arrival curve of workload
%           deadline    relative end to end deadline
%           N           node number, from thermal model
%           n           core number, from thermal model
%           flp         the floorplan struct 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check inputs
if nargin < 9
    error('Inputs not enough');
end
 

[flag, ~] = checkingArguments(deadline, wcets, tswons, tswoffs, activeNum, flp, N, n);
if flag == 0
    error('input arguments error');
end

%% creat the return structure
problemConfig = struct('wcets', [], 'tswons', [], 'tswoffs', [],...
    'activeNum', activeNum, 'actcoreIdx', [], 'isAct', false(1, n),'alpha', alpha,...
    'deadline', deadline,'flp', flp, 'sumWcet', 0, 'sumTswoff', 0);


%% if not all cores are activated, get the indexs of the active cores

activeCoreIdx = chooseActCores(flp, activeNum);
problemConfig.isAct(activeCoreIdx) = true;
problemConfig.actcoreIdx   = activeCoreIdx;

%% get the wcets, tswons, tswoffs of the actived cores

problemConfig.wcets        = shrinkVars(wcets, activeCoreIdx);
problemConfig.tswoffs      = shrinkVars(tswoffs, activeCoreIdx);
problemConfig.tswons       = shrinkVars(tswons, activeCoreIdx);
problemConfig.sumWcet      = sum(problemConfig.wcets);
problemConfig.sumTswoff    = sum(problemConfig.tswoffs);
problemConfig.sumTswon     = sum(problemConfig.tswons);
problemConfig.n            = n;   
 