function [xout] = shrinkVars(xin, validid)

if ~isvector(xin) || ~isvector(validid)
    error('input xin and validid must be vectors');
end

rowinputed = isrow(xin);

xin = xin(:)';
validid = validid(:)';
xout = xin(:,validid);

if ~rowinputed
    xout = xout(:);
end

end



