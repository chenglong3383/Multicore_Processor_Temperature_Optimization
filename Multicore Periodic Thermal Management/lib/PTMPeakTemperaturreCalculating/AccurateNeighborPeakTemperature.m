function [Tpeak, TM] = AccurateNeighborPeakTemperature(TM, tslp, tact)
% [Tpeak, TM] = AccurateNeighborPeakTemperature(TM, tslp, tact)
% 
% Function for calculating the Accurate Neighbor Peak Temperature of a multicore processor
% managed by Periodic Thermal Management 
% Input:
% TM:   the thermal and power model of the processor, generated by
%       unction MultiCoreProcessorThermalModel
% tslp: a vector specifying the length of the PTM sleep intervals of all
%       cores
% tact: a vector specifying the length of the PTM active intervals of all
%       cores
%
% Output:
% Tpeak: the Accurate Neighbor Peak Temperature
% TM:   the thermal and power model containing the calculating history. Use
%       it for future peak temperature calculating to speed up the program.
% 
% Note: the order of cores in tslp and tact should be same with that in TM.
%       the time unit is milisecond!
[flag, report] = checkInputsForPeakTemperatureComputing(TM, tslp, tact);
if flag == 0
    warning(report);
end

if flag < 0
    error(report, 0);
end

scalor  = 0.001; % unit ms
pTact   = TM.p / scalor;          % the resolution of tact and tslp

if ( max(TM.tend) + 2 * scalor * ( max(tact) + max(tslp) ) ) >= (TM.fftLength * TM.p - 5)
    error('Check the unit of tact and tslp!');
end


% since only the thermal influences from non-core nodes have been considered in
% TM.Tconstmax, the thermal influences from cores should always been
% calculated


%% isAct and isPeriodic indicates if the calculation of Timp(i,j) can be skipped

isAct = ( tact >= pTact ); % we consider tact=0 in this case, the core is not activated
isPeriodic = isAct; % A core must be activated before being periodic
isPeriodic( tslp < pTact ) = false; % when tslp=0, the core is activated but not periodic


%% check if Timp already been calculated AND calculate Timp
[TM] = completeTimp(TM, tslp, tact, isPeriodic, isAct, scalor);


%% calculate the temperature
[ Temperature] = computeTemp(TM, tslp, tact, isAct, isPeriodic);

Tpeak = max(Temperature);

