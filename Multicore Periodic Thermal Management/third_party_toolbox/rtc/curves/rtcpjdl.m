function result = rtcpjdl(varargin)
% RTCPJDL   Create the lower curve to a (P,J,D) event model.
%    RTCPJDL(P,J,D) creates the lower curve to an event stream
%    with period P, jitter J and minimum event-interarrival
%    time D. If J > P-D, the modeled event stream is bursty.
%
%    RTCPJDL(P) creates the lower curve to an event stream
%    with period P.
%
%    RTCPJDL(P,J) creates the loewr curve to an event stream
%    with period P and jitter J.
%
%    All parameter options can be followed by a character string 
%    N that specifies the optional name of the curve.
%
%    The parameters must fulfill the following conditions:
%      - P must be a natural number
%      - P >= 1
%      - J >= 0
%      - D >= 0 and D < P
%
%    See also RTCPJDU, RTCCURVE, RTCFS, RTCBDU, RTCBDL, 
%             RTCPSU, RTCPSL, RTCTDMAU, RTCTDMAL.

%    Author(s): E. Wandeler
%    Copyright 2004-2006 Computer Engineering and Networks Laboratory (TIK) 
%    ETH Zurich, Switzerland.
%    All rights reserved.

if (exist('ch.ethz.rtc.kernel.Curve','class') ~= 8) 
    error('MATLAB:rtcpjdl:KernelNotInstalled',...
		'RTC Toolbox not installed properly!\n>>> Please reinstall the RTC Toolbox');
end
import ch.ethz.rtc.kernel.*;

if nargin < 1
    error('RTCPJDU - too few arguments.')
elseif nargin > 4
    error('RTCPJDU - too many arguments.')
end

data = [0 0 0];
name = '';
namedef = 0;

for i = (1:length(varargin))
    switch class(varargin{i})
        case 'double'
            if namedef == 0 && i <= 3
                data(i) = varargin{i};
            else 
                error('RTCPJDL - pjdl is not defined for the passed argument list.')
            end
        case 'char'
            if namedef == 0 && i <= 4
                name = varargin{i};
                namedef = 1;
            else 
                error('RTCPJDL - pjdl is not defined for the passed argument list.')
            end
        otherwise
            error('RTCPJDL - pjdl is not defined for the passed argument list.')
    end
end

try
    result = CurveFactory.createLowerPJDCurve(data(1),data(2),data(3),name);
catch
    if round(data(1)) ~= data(1)
        error('RTCPJDL(P,J,D) - P must be a natural number');
    elseif (data(1) < 1)
        error('RTCPJDL(P,J,D) - the following condition must be fulfilled: P >= 1');
    elseif (data(2) < 0)
        error('RTCPJDL(P,J,D) - the following condition must be fulfilled: J >= 0');
    elseif (data(3) < 0)
        error('RTCPJDL(P,J,D) - the following condition must be fulfilled: D >= 0');
    elseif (data(3) >= data(1))
        error('RTCPJDL(P,J,D) - the following condition must be fulfilled: D < P');
    end
end