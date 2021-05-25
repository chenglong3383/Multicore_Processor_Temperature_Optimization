function proj = findProjectOfPointOnToAnAffineSpace(x0, A, b, upperbounds, lowerbounds)

n = numel(x0);

upperbounds = upperbounds(:);
lowerbounds = lowerbounds(:);

% if n~=size(A, 2) || n~=numel(upperbounds) || n~=numel(lowerbounds)
%    error('input A or upperbounds or lowerbounds size error!'); 
% end

% if sum(upperbounds(:)) < b || sum(lowerbounds(:)) > b
%     error('infeasible upper or lower bounds!');
% end

    
x0 = x0(:); % x0 should be a column vector
A = A(:)'; % A should be a row vector



quadH = eye(n);
quadf = -x0;
quadA = [];
quadb = [];
quadAeq = A;
quadbeq = b;
quadlb = lowerbounds;
quadub = upperbounds;

option.Display = 'off';
proj = quadprog(quadH, quadf, quadA, quadb, quadAeq, quadbeq, quadlb, quadub, [], option);




