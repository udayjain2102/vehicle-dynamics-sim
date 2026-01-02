function car_builder
model = 'full_car';


if ~bdIsLoaded(model)
    if exist([model '.slx'],'file')
        load_system(model);
    else
        new_system(model);
        save_system(model);
        load_system(model);
    end
end
open_system(model);


m  = 1200;
rho = 1.225; Cd = 0.32; A = 2.2;
Cr = 0.015; g = 9.81;
dragGain = 0.5*rho*Cd*A;


ensureBlock([model '/Integrator'],'simulink/Continuous/Integrator');
ensureBlock([model '/v2'],'simulink/Math Operations/Product');

ensureBlock([model '/DragGain'],'simulink/Math Operations/Gain');
set_param([model '/DragGain'],'Gain',num2str(dragGain));

ensureBlock([model '/AccelGain'],'simulink/Math Operations/Gain');
set_param([model '/AccelGain'],'Gain',num2str(1/m));

ensureBlock([model '/Sum'],'simulink/Math Operations/Sum');
set_param([model '/Sum'],'Inputs','++++-');

ensureBlock([model '/Scope'],'simulink/Sinks/Scope');

ensureBlock([model '/Froll'],'simulink/Sources/Constant');
set_param([model '/Froll'],'Value',num2str(m*g*Cr));

ensureBlock([model '/Slope_deg'],'simulink/Sources/Constant');
set_param([model '/Slope_deg'],'Value','5');

ensureBlock([model '/SlopeToRad'],'simulink/Math Operations/Gain');
set_param([model '/SlopeToRad'],'Gain','pi/180');

ensureBlock([model '/sin'], ...
    'simulink/Math Operations/Trigonometric Function');

ensureBlock([model '/SlopeForce'],'simulink/Math Operations/Gain');
set_param([model '/SlopeForce'],'Gain',num2str(m*g));

ensureBlock([model '/ThrottleGain'],'simulink/Math Operations/Gain');
set_param([model '/ThrottleGain'],'Gain','4000');

ensureBlock([model '/BrakeGain'],'simulink/Math Operations/Gain');
set_param([model '/BrakeGain'],'Gain','5000');

ensureBlock([model '/One'],'simulink/Sources/Constant');
set_param([model '/One'],'Value','1');

ensureBlock([model '/ThrottleStep'],        'simulink/Sources/Step');
set_param([model '/ThrottleStep'],'Time','1','After','0.6');

ensureBlock([model '/BrakeStep'],           'simulink/Sources/Step');
set_param([model '/BrakeStep'],'Time','8','After','0.7');


if isBlock([model '/Pedals'])
    delete_block([model '/Pedals']);
end

add_block('simulink/Signal Routing/Mux',[model '/Pedals'], ...
    'Inputs','2','MakeNameUnique','off');


safe_line(model,'Integrator/1','v2/1');
safe_line(model,'One/1','v2/2');
safe_line(model,'v2/1','DragGain/1');

safe_line(model,'DragGain/1','Sum/2');
safe_line(model,'Froll/1','Sum/3');

safe_line(model,'Slope_deg/1','SlopeToRad/1');
safe_line(model,'SlopeToRad/1','sin/1');
safe_line(model,'sin/1','SlopeForce/1');
safe_line(model,'SlopeForce/1','Sum/5');

safe_line(model,'Sum/1','AccelGain/1');
safe_line(model,'AccelGain/1','Integrator/1');
safe_line(model,'Integrator/1','Scope/1');

% pedals wiring
safe_line(model,'ThrottleStep/1','Pedals/1');
safe_line(model,'BrakeStep/1','Pedals/2');

safe_line(model,'Pedals/1','ThrottleGain/1');
safe_line(model,'Pedals/2','BrakeGain/1');

safe_line(model,'ThrottleGain/1','Sum/1');
safe_line(model,'BrakeGain/1','Sum/4');

save_system(model);

end


function ensureBlock(path,type)
    if ~isBlock(path)
        add_block(type,path,'MakeNameUnique','off');
    end
end

function ok = isBlock(path)
    try
        get_param(path,'Handle');
        ok = true;
    catch
        ok = false;
    end
end

function safe_line(model,src,dst)
    try
        add_line(model,src,dst,'autorouting','on');
    catch
        % line exists — ignore
    end
end
