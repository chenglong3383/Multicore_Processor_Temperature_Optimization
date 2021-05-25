function xout = retrieveVars(xin, validid, n)

if ~isvector(validid)
    error('input validid must be a vector');
end

if max(validid) > n
    error('input indexs exceeds bound n');
end

isxincolumn = iscolumn(xin);
validid = validid(:)';
if isvector(xin)
    xin = xin(:)';
end

if size(xin,2) > n
    error('size of xin and validid exceeds bound n');
end

m = size(xin,1);

validid = round(validid);
xout = zeros(m, n);

xout(:,validid) = xin;

if isxincolumn
    xout = xout(:);
end


end






