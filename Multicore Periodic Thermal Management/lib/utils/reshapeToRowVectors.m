function stucture = reshapeToRowVectors(stucture)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reshape all one dimension vectors in a stucture to row vectors
% 
%
% author: Long Cheng
% date: 14/05/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


allMembers = fields(stucture);

for i = 1 : numel(allMembers)
   field = stucture.(allMembers{i});
   if isvector(field)
      stucture.(allMembers{i}) = field(:)';
   end
end