



try
    disp('   Installing The Third-party Real-Time Calculus (RTC) Toolbox');
    run('./third_party_toolbox/rtc/rtc_install.m')
    rtcInstallSuccess = 1;
catch exc
    rtcInstallSuccess = 0;
    warning(message('MATLAB:mcto_install', exc.identifier, exc.message));
end

if ~rtcInstallSuccess
    disp('   The Multi-Core Temperature Optimization Toolbox was unable to install The Real-Time Calculus (RTC) Toolbox successfully.');
    return;
end

clear all


mcto_path = which('mcto_install');
mcto_path = strrep(mcto_path,'mcto_install.m','');
delimiter = mcto_path(length(mcto_path));
mcto_path = mcto_path(1:length(mcto_path)-1);
addpath(mcto_path);
addpath(genpath([mcto_path delimiter 'dataset']));
addpath(genpath([mcto_path delimiter 'lib']));
addpath(genpath([mcto_path delimiter 'third_party_toolbox']));

success = savepath;
if (success == 1)
    warning('   The current MATLABPATH could not be saved to the pathdef.m \n   which was read on startup.\n   Please try to manually save the current MATLABPATH \n   For help type >> help savepath','');
    disp(' ');
    disp('   The Multi-Core Temperature Optimization Toolbox could not be installed completely.');
else
    disp('   The Multi-Core Temperature Optimization Toolbox was successfully installed.');
end


