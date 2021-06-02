

datafile1 = 'intel6700coresTM0.0001p.mat';
datafile2 =  'intel6700coresfloorplan.mat';
if ~exist('TM','var')
    load(datafile1);
end
load(datafile2);
disp('loaded!')

%% system setup


allstreams = [50 0 0; % H263
    60 0 0; %MP3
    50 0 0]; %MAD
all_wcets = [1.32         7.2         5.4        2.16; % H263
    1.33         5.6        5.11        3.57; %MP3
    2.4        3.12         3.6         4.8]; %MAD

tswoffs = ones(1,4);
tswons = tswoffs;

%% optimization parameters
options.verbose = 3;
options.step = 2; % searching step
options.san = 4; % repeat the Accurate Neighbor Simulated Annealing 4 times

%% for different jitterfactors
deadlinefactors = 0.9 : 0.1 : 1.5;
jitterfactors = [0.5, 1];

all_results = [];


[TM] = preCalculateImpulseAndFFT(TM);

for jitterfactor = jitterfactors
    for deadlinefactor = deadlinefactors
        
        for i = 1 : 3 % three events
            
            savefile = ['intel6700-step-',num2str(options.step),'-ddf-',num2str(deadlinefactor),'-jiiterf-',num2str(jitterfactor), '-event-',num2str(i),'.mat'];
            
            activeNum = 4;
            
           %% construct input event stream arrival curve
            period = allstreams(i,1);
            jitter = period * jitterfactor;
            d = allstreams(i,3);
            deadline = period * deadlinefactor;
            alpha = rtcpjd(period,jitter,d);
            wcets = all_wcets(i,:);
            
           %% construct configuration
            config = PBOOOptimizationProblemConfig(alpha, deadline, wcets, tswons, tswoffs, activeNum, flp, TM.N, TM.n);
            
            
            % to control whether to apply the four approaches. Order:
            % brutally searching, fast bounded greedy descending, simulated
            % annealing, sub-deadline partition
            approach_control = [1,1,1,1];
            problem.TM = TM;
            problem.config = config;
            
            [resultData, TM] = compareMethods(problem, options, approach_control, 0, 'intel6700');

            all_results = [all_results, resultData];
           % uncoment this line to save the results
          %  save(savefile,'resultData');
        end
    end
end







%