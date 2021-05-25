function f = isVectorsSizeEqual(varargin)

if nargin < 2
    f = true;
else
    s0 = size(varargin{1});
    f = true;
    for i = 2 : nargin
       if ~isequal(s0, size(varargin{i}))
          f = false;
          break;
       end
    end
    

end