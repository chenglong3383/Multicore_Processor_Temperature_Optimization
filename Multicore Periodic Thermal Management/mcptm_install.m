
mcptm_path = which('mcptm_install');
mcptm_path = strrep(mcptm_path,'mcptm_install.m','');
delimiter = mcto_path(length(mcptm_path));


try
    disp('   Installing The Third-party Real-Time Calculus (RTC) Toolbox');
    run([mcptm_path delimiter 'third_party_toolbox' delimiter 'rtc' delimiter 'rtc_install.m' ])
    rtcInstallSuccess = 1;
catch exc
    rtcInstallSuccess = 0;
    warning(message('MATLAB:mcptm_install', exc.identifier, exc.message));
end

if ~rtcInstallSuccess
    disp('   The Multi-Core Periodic Thermal Management Toolbox was unable to install The Real-Time Calculus (RTC) Toolbox successfully.');
    return;
end

clear all


mcptm_path = which('mcptm_install');
mcptm_path = strrep(mcptm_path,'mcptm_install.m','');
delimiter = mcto_path(length(mcptm_path));
mcptm_path = mcto_path(1:length(mcptm_path)-1);
addpath(mcptm_path);
addpath(genpath([mcptm_path delimiter 'dataset']));
addpath(genpath([mcptm_path delimiter 'lib']));
addpath(genpath([mcptm_path delimiter 'third_party_toolbox']));

success = savepath;
if (success == 1)
    warning('   The current MATLABPATH could not be saved to the pathdef.m \n   which was read on startup.\n   Please try to manually save the current MATLABPATH \n   For help type >> help savepath','');
    disp(' ');
    disp('   The Multi-Core Periodic Thermal Management Toolbox could not be installed completely.');
else
    disp('   The Multi-Core Periodic Thermal Management Toolbox was successfully installed.');
end


