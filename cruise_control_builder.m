function cruise_control_builder

model = 'full_car';
open_system(model);


ensureBlock([model '/CruiseTarget'],'simulink/Sources/Constant');
set_param([model '/CruiseTarget'],'Value','20');   % m/s (~72 km/h)


ensureBlock([model '/CruiseEnable'],'simulink/Sources/Constant');
set_param([model '/CruiseEnable'],'Value','1');    % 1=ON, 0=OFF

ensureBlock([model '/SpeedError'],'simulink/Math Operations/Sum');
set_param([model '/SpeedError'],'Inputs','+-');

safe_line(model,'CruiseTarget/1','SpeedError/1');
safe_line(model,'Integrator/1','SpeedError/2');   % vehicle speed

ensureBlock([model '/CruisePID'],'simulink/Continuous/PID Controller');
set_param([model '/CruisePID'],...
    'P','0.6','I','0.2','D','0');


safe_line(model,'SpeedError/1','CruisePID/1');


ensureBlock([model '/CruiseSwitch'],'simulink/Signal Routing/Switch');
set_param([model '/CruiseSwitch'],'Threshold','0.5');

safe_line(model,'CruiseEnable/1','CruiseSwitch/1');
safe_line(model,'CruiseSwitch/1','ThrottleGain/1');
safe_line(model,'ThrottleStep/1','CruiseSwitch/2');
safe_line(model,'CruisePID/1','CruiseSwitch/3');




save_system(model);

end



function ensureBlock(path,type)
    try, get_param(path,'Handle'); 
    catch, add_block(type,path,'MakeNameUnique','off'); 
    end
end

function safe_line(model,src,dst)
    try, add_line(model,src,dst,'autorouting','on');
    catch, end
end
