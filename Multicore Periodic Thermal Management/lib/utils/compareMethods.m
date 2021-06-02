function [resultData, TM] = compareMethods(problem, options, validAlgo, ifsave, saveprefix)


activeNum = problem.config.activeNum;
if nargin < 5
 saveprefix = problem.TM.name;
end
savename = strcat(saveprefix, num2str(activeNum));
resultData.resultFBGD = results();
resultData.resultANSA = results();
resultData.resultSDP  = results();
resultData.resultBS   = results();
resultData.config     = problem.config;
%%
if validAlgo(1)
    options.method = 'BS';
    [result0, problem.TM] = PayBurstOnlyOnceMinimizing(problem, options); %brutal searching
    resultData.resultBS = result0;
    if ifsave
    save(savename, 'resultData');
    end
end

%%
if validAlgo(2)
    options.method = 'FBGD';
    [result1, problem.TM] = PayBurstOnlyOnceMinimizing(problem, options); %gradient searching
    resultData.resultFBGD = result1;
    if ifsave
    save(savename, 'resultData');
    end
end

%%
if validAlgo(3)
    options.method = 'ANSA';
    [result2, problem.TM] = PayBurstOnlyOnceMinimizing(problem, options); %SA
    resultData.resultANSA = result2;
   if ifsave
    save(savename, 'resultData');
    end
end


%%
if validAlgo(4)
    [resultDPA, problem.TM] = SubDeadlinePartitionBrutallySearching(problem, options);
    resultData.resultSDP = resultDPA;
   if ifsave
    save(savename, 'resultData');
   end
   
end

TM = problem.TM;


end