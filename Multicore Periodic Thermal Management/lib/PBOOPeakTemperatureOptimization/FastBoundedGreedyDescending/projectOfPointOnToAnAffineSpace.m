function proj = projectOfPointOnToAnAffineSpace(x0, A, b, upperbounds, lowerbounds)

n = numel(x0);

upperbounds = upperbounds(:);
lowerbounds = lowerbounds(:);

if n~=size(A, 2) || n~=numel(upperbounds) || n~=numel(lowerbounds)
   error('input A or upperbounds or lowerbounds size error!'); 
end

if sum(upperbounds(:)) < b || sum(lowerbounds(:)) > b
    error('infeasible upper or lower bounds!');
end

sumLowerBoundsExceptOneElement = sum(lowerbounds(:)) - lowerbounds;
sumUpperBoundsExceptOneElement = sum(upperbounds(:)) - upperbounds;

realUpperBounds = min(b - sumLowerBoundsExceptOneElement, upperbounds);
realLowerBounds = max(b - sumUpperBoundsExceptOneElement, lowerbounds);


sumRealUpperBoundsExcept = sum(realUpperBounds(:)) - realUpperBounds;
for i = 1 : n
    if abs( b - realLowerBounds(i) - sumRealUpperBoundsExcept(i) ) > 1e-10
        error('internel error');
    end
end
    
x0 = x0(:); % x0 should be a column vector
A = A(:)'; % A should be a row vector

temp1 = A'*inv(A*A')';
temp2 = temp1 * A;

I = eye(size(temp2));

proj0 = (I - temp2) * x0 + temp1 * b;

isValid = proj0 <= realUpperBounds & proj0 >= realLowerBounds;
if all(isValid)
    proj = proj0;
    return;
else
    [~, invalidId] = find(~isValid, 1, 'first');
    if n == 2
        endpoint1 = [realLowerBounds(1); realUpperBounds(2)];
        endpoint2 = [realUpperBounds(1); realLowerBounds(2)];
        if dot(proj0 - endpoint1, proj0 - endpoint1) < dot(proj0 - endpoint2, proj0 - endpoint2)
            proj = endpoint1;
        else
            proj = endpoint2;
        end
        return;
        
    end
    
    newProj = proj0;
    if proj0(invalidId) > realUpperBounds(invalidId)
        newProj(invalidId) = realUpperBounds(invalidId);
    else
        newProj(invalidId) = realLowerBounds(invalidId);
    end
    
    otherIds = [1:invalidId-1, invalidId+1:n];
    otherProj = projectOfPointOnToAnAffineSpace(x0(otherIds), A(otherIds), b-newProj(invalidId), upperbounds(otherIds), lowerbounds(otherIds));
    
    newProj(otherIds) = otherProj;
    
    proj = newProj;
    
    
end
