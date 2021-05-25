function structure = reshapeToColumnVectors(structure)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reshape all one dimension vectors in a stucture to column vectors
% 
%
% author: Long Cheng
% date: 14/05/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


allMembers = fields(structure);

for i = 1 : numel(allMembers)
   field = structure.(allMembers{i});
   if isvector(field)
      structure.(allMembers{i}) = field(:);
   end
end