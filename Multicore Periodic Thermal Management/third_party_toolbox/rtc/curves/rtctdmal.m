function result = rtctdmal(s, c, b, n)
% RTCTDMAL   Create the lower curve to a TDMA resource model.
%    RTCTDMAL(S,C,B) creates the lower curve to a TDMA resource
%    where a slot of length S is allocated on a resource 
%    with total bandwidth B and TDMA cycle length C.
%
%    The parameter triple can be followed by a character 
%    string N that specifies the optional name of the curve.
%
%    The parameters must fulfill the following conditions:
%      - S >= 0 ^ S <= C
%      - C must be a natural number
%      - C >= 1
%      - B >= 0
%
%    See also RTCTDMAU, RTCCURVE, RTCFS, RTCBDU, RTCBDL, RTCPSU, 
%             RTCPSL, RTCPJDU, RTCPJDL.

%    Author(s): E. Wandeler
%    Copyright 2004-2006 Computer Engineering and Networks Laboratory (TIK) 
%    ETH Zurich, Switzerland.
%    All rights reserved.

if (exist('ch.ethz.rtc.kernel.Curve','class') ~= 8) 
    error('MATLAB:rtctdmal:KernelNotInstalled',...
		'RTC Toolbox not installed properly!\n>>> Please reinstall the RTC Toolbox');
end
import ch.ethz.rtc.kernel.*;

if nargin == 3
    n = '';
elseif nargin < 3
    error('RTCTDMAL - too few arguments.')
elseif nargin > 4
    error('RTCTDMAL - too many arguments.')
end

if (~strcmp(class(s),'double') || ~strcmp(class(c),'double') ...
        || ~strcmp(class(b),'double') || ~strcmp(class(n),'char'))
    error('RTCTDMAL - tdmal is not defined for the passed argument list.')
end

if round(c) ~= c
    error('RTCTDMAL(S,C,B) - C must be a natural number');
end

try
    result = CurveFactory.createLowerTDMACurve(s,c,b,n);
catch
    if (s < 0)
        error('RTCTDMAL(S,C,B) - the following condition must be fulfilled: S >= 0');
    elseif (s > c)
        error('RTCTDMAL(S,C,B) - the following condition must be fulfilled: S <= C');
    elseif (c < 1)
        error('RTCTDMAL(S,C,B) - the following condition must be fulfilled: C >= 1');
    elseif (b < 0)
        error('RTCTDMAL(S,C,B) - the following condition must be fulfilled: B >= 0');
    end
end