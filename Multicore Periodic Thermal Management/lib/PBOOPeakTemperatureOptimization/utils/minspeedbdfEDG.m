function k= minspeedbdfEDG(beta, delay)
% MINBDF Computes the minmum speed by given the delay and demand sevice curve.
%
% k= minspeedbdfEDG(bdf, delay)
%
% INPUT:
%    @beta:        the service bound curve
%    @delay:      the delay

% OUTPUT:
%    k:           minumu speed
 
max_speed=1;
min_speed=0;
epsilon = 10^(-4); % stop condition
stop = 1;
while (stop)
  %if max_speed curve is greater than beta
  mid_speed=(max_speed+min_speed)/2;
  bdf_mid = rtccurve([0 0 mid_speed]);
  bdf_mid = rtcaffine(bdf_mid, 1, delay);
  if (rtceq(rtcmax(bdf_mid, beta), bdf_mid))
    %Valid value
    max_speed = mid_speed;
  else
    %Not a valid value
    min_speed = mid_speed;
  end  
  %Stop condition
  if abs(max_speed - min_speed) < epsilon
    k = max_speed;
    stop = 0;
  end
end