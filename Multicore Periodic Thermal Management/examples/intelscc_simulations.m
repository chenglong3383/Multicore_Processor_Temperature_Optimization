
%% load themal and power model of Intel SCC processor
savefile1 = 'IntelSCCTM0.0001p.mat';
savefile2 = 'IntelSCCfloorplan.mat';
if ~exist('TM','var')
    load(savefile1);
end
load(savefile2);
disp('Thermal model loaded!')

% switching overhead 
tswoffs = ones(1,48);
tswons = tswoffs;

%% input workload model
stream = [100,0,0];
alpha = rtcpjd(100 , 0 ,0);
wcets = [5.74 4.34 4.90 4.06 5.18 4.34 5.46 5.46 5.46 4.90 3.78 4.06 6.02...
    4.06 5.74 4.90 6.30 3.78 4.62 3.78 6.30 3.50 5.74 5.74 6.02 3.78 4.62...
    4.34 5.74 4.62 6.02 4.06 4.34 3.78 3.78 6.02 5.18 4.90 3.78 6.02 5.18...
    4.62 4.90 4.62 3.78 4.06 3.78 4.06];

activeNum = 2; % adjusting this parameter to compare the four approaches for different stage numbers
deadline = activeNum * 6  + 40;


options.verbose = 3; % 0: no info, 1: final, 2: iter, 3:debug
options.step = 4; % searching step 
if activeNum <= 4
    options.step = 4; % searching step 
end
options.san = 4; % repeat the Accurate Neighbor Simulated Annealing 4 times


config = PBOOOptimizationProblemConfig(alpha, deadline, wcets, tswons, tswoffs, activeNum, flp, TM.N, TM.n);


[TM] = preCalculateImpulseAndFFT(TM, config);

            
% to control whether to apply the four approaches. Order:
% brutally searching, fast bounded greedy descending, simulated
% annealing, sub-deadline partition
approach_control = [1,1,0,1];

problem.TM = TM;
problem.config = config;
[resultData, TM] = compareMethods(problem, options, approach_control, 0, 'IntelSCC');




