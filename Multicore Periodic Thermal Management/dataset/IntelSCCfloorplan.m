function flp = IntelSCCfloorplan()


node = cell(48, 1 );

for i = 1 : 48
    node{i} = strcat('',num2str(i));
end

table = [0.00360000000000000,0.00260000000000000,0,0;0.00360000000000000,0.00260000000000000,0,0.00260000000000000;0.00360000000000000,0.00260000000000000,0.00360000000000000,0;0.00360000000000000,0.00260000000000000,0.00360000000000000,0.00260000000000000;0.00360000000000000,0.00260000000000000,0.00720000000000000,0;0.00360000000000000,0.00260000000000000,0.00720000000000000,0.00260000000000000;0.00360000000000000,0.00260000000000000,0.0108000000000000,0;0.00360000000000000,0.00260000000000000,0.0108000000000000,0.00260000000000000;0.00360000000000000,0.00260000000000000,0.0144000000000000,0;0.00360000000000000,0.00260000000000000,0.0144000000000000,0.00260000000000000;0.00360000000000000,0.00260000000000000,0.0180000000000000,0;0.00360000000000000,0.00260000000000000,0.0180000000000000,0.00260000000000000;0.00360000000000000,0.00260000000000000,0,0.00520000000000000;0.00360000000000000,0.00260000000000000,0,0.00780000000000000;0.00360000000000000,0.00260000000000000,0.00360000000000000,0.00520000000000000;0.00360000000000000,0.00260000000000000,0.00360000000000000,0.00780000000000000;0.00360000000000000,0.00260000000000000,0.00720000000000000,0.00520000000000000;0.00360000000000000,0.00260000000000000,0.00720000000000000,0.00780000000000000;0.00360000000000000,0.00260000000000000,0.0108000000000000,0.00520000000000000;0.00360000000000000,0.00260000000000000,0.0108000000000000,0.00780000000000000;0.00360000000000000,0.00260000000000000,0.0144000000000000,0.00520000000000000;0.00360000000000000,0.00260000000000000,0.0144000000000000,0.00780000000000000;0.00360000000000000,0.00260000000000000,0.0180000000000000,0.00520000000000000;0.00360000000000000,0.00260000000000000,0.0180000000000000,0.00780000000000000;0.00360000000000000,0.00260000000000000,0,0.0104000000000000;0.00360000000000000,0.00260000000000000,0,0.0130000000000000;0.00360000000000000,0.00260000000000000,0.00360000000000000,0.0104000000000000;0.00360000000000000,0.00260000000000000,0.00360000000000000,0.0130000000000000;0.00360000000000000,0.00260000000000000,0.00720000000000000,0.0104000000000000;0.00360000000000000,0.00260000000000000,0.00720000000000000,0.0130000000000000;0.00360000000000000,0.00260000000000000,0.0108000000000000,0.0104000000000000;0.00360000000000000,0.00260000000000000,0.0108000000000000,0.0130000000000000;0.00360000000000000,0.00260000000000000,0.0144000000000000,0.0104000000000000;0.00360000000000000,0.00260000000000000,0.0144000000000000,0.0130000000000000;0.00360000000000000,0.00260000000000000,0.0180000000000000,0.0104000000000000;0.00360000000000000,0.00260000000000000,0.0180000000000000,0.0130000000000000;0.00360000000000000,0.00260000000000000,0,0.0156000000000000;0.00360000000000000,0.00260000000000000,0,0.0182000000000000;0.00360000000000000,0.00260000000000000,0.00360000000000000,0.0156000000000000;0.00360000000000000,0.00260000000000000,0.00360000000000000,0.0182000000000000;0.00360000000000000,0.00260000000000000,0.00720000000000000,0.0156000000000000;0.00360000000000000,0.00260000000000000,0.00720000000000000,0.0182000000000000;0.00360000000000000,0.00260000000000000,0.0108000000000000,0.0156000000000000;0.00360000000000000,0.00260000000000000,0.0108000000000000,0.0182000000000000;0.00360000000000000,0.00260000000000000,0.0144000000000000,0.0156000000000000;0.00360000000000000,0.00260000000000000,0.0144000000000000,0.0182000000000000;0.00360000000000000,0.00260000000000000,0.0180000000000000,0.0156000000000000;0.00360000000000000,0.00260000000000000,0.0180000000000000,0.0182000000000000];


flp = generateFlp(node, table);
