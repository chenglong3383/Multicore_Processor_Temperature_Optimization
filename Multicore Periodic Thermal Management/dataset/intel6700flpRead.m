clear;

fid = fopen('intel6700.flp','r');

[node, table] = scanfFlp(fid);

if size(node, 1) ~= size(table, 1)
    error('file is wrong');
end

intel6700flp = generateFlp(node, table);


    