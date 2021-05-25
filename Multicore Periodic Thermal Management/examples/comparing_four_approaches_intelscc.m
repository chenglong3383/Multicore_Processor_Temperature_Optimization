
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

activeNum = 4; % adjusting this parameter to see what happens
deadline = activeNum * 6  + 40;


options.verbose = 2;
options.step = 4; % searching step 
options.san = 4; % repeat the Accurate Neighbor Simulated Annealing 4 times


config = PBOOOptimizationProblemConfig(alpha, deadline, wcets, tswons, tswoffs, activeNum, flp, TM.N, TM.n);

[TM] = preCalculateImpulseAndFFT(TM, config);


control = ones(1, 4);

problem.TM = TM;
problem.config = config;
[resultData, TM] = compareMethods(problem, options, control, 0, 'RevisedresultObject_IntelSCC');




