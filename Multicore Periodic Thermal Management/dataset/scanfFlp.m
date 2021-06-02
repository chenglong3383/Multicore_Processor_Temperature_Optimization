function [node table] = scanfFlp(fid)


stop = 0;
node = cell(1,1);
properties = [];
table = [];
line = 0;
column = 1;
while ~stop
    [read count] = fscanf(fid,'%f',1);
    if count == 0
        [read count] = fscanf(fid,'%s',1);
        if count == 0
            stop = 1;
            table = [table;properties];
        else
        line = line + 1;
        node{line} = read;
        column = 1;
        table = [table;properties];
        end
    else
        column = column + 1;
        properties(column-1) = read;
    end
end
node = node';

