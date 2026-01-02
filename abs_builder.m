function abs_builder

model = 'full_car';
open_system(model);

g = 9.81;


ensureBlock([model '/DecelDiff'],'simulink/Discrete/Discrete Derivative');


safe_line(model,'Integrator/1','DecelDiff/1');


ensureBlock([model '/SlipCalc'],'simulink/Math Operations/Gain');
set_param([model '/SlipCalc'],'Gain',sprintf('1/%f',g));

safe_line(model,'DecelDiff/1','SlipCalc/1');


ensureBlock([model '/SlipLimit'],'simulink/Logic and Bit Operations/Compare To Constant');
set_param([model '/SlipLimit'],'const','0.2');

safe_line(model,'SlipCalc/1','SlipLimit/1');


ensureBlock([model '/ABSSwitch'],'simulink/Signal Routing/Switch');
set_param([model '/ABSSwitch'],'Threshold','0.5');

% Control input (ABS active)
safe_line(model,'SlipLimit/1','ABSSwitch/1');

% True: ABS reduces braking
ensureBlock([model '/ABSBrakeGain'],'simulink/Math Operations/Gain');
set_param([model '/ABSBrakeGain'],'Gain','0.25');
safe_line(model,'BrakeGain/1','ABSBrakeGain/1');
safe_line(model,'ABSBrakeGain/1','ABSSwitch/3');

% False: normal brake
safe_line(model,'BrakeGain/1','ABSSwitch/2');


safe_line(model,'ABSSwitch/1','BrakeForce/1');

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
