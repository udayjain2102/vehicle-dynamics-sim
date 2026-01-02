function drivetrain_builder

model = 'full_car';
open_system(model);

m = 1200;        % mass (kg)
r = 0.30;        % wheel radius (m)
gear = 9;        % effective gear ratio
engine_gain = 350;  % Nm per throttle
brake_gain  = 9000; % N braking


ensureBlock([model '/EngineGain'],'simulink/Math Operations/Gain');
set_param([model '/EngineGain'],'Gain',num2str(engine_gain));

safe_line(model,'ThrottleGain/1','EngineGain/1');


ensureBlock([model '/GearGain'],'simulink/Math Operations/Gain');
set_param([model '/GearGain'],'Gain',num2str(gear/r));

safe_line(model,'EngineGain/1','GearGain/1');


ensureBlock([model '/BrakeForce'],'simulink/Math Operations/Gain');
set_param([model '/BrakeForce'],'Gain',num2str(brake_gain));

safe_line(model,'BrakeGain/1','BrakeForce/1');


ensureBlock([model '/ForceSum'],'simulink/Math Operations/Sum');
set_param([model '/ForceSum'],'Inputs','+++-');

safe_line(model,'GearGain/1','ForceSum/1');
safe_line(model,'DragGain/1','ForceSum/2');
safe_line(model,'SlopeForce/1','ForceSum/3');
safe_line(model,'BrakeForce/1','ForceSum/4');


safe_line(model,'ForceSum/1','AccelGain/1');

save_system(model);

end


function ensureBlock(path,type)
    try
        get_param(path,'Handle');
    catch
        add_block(type,path,'MakeNameUnique','off');
    end
end

function safe_line(model,src,dst)
    try
        add_line(model,src,dst,'autorouting','on');
    catch
    end
end
