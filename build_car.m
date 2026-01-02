function build_car
% BUILD_CAR — full car model with pedals + viewer + gauge
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
r = 0.30; gear = 9;
engine_gain = 350;
brake_gain  = 9000;


build_vehicle3D(model);


% Throttle slider - delete if exists, then recreate
if blockExists([model '/Throttle']), delete_block([model '/Throttle']); end
try
    add_block('simulink/Dashboard/Slider',[model '/Throttle']);
    set_param([model '/Throttle'],...
        'Position',[50 350 200 380],...
        'Min','0','Max','1');
catch
    % Fallback to Constant block if Dashboard not available
    add_block('simulink/Sources/Constant',[model '/Throttle']);
    set_param([model '/Throttle'],...
        'Position',[50 350 200 380],...
        'Value','0');
    disp('Note: Using Constant blocks instead of sliders. Edit block values to control.');
end

% Brake slider
if blockExists([model '/Brake']), delete_block([model '/Brake']); end
try
    add_block('simulink/Dashboard/Slider',[model '/Brake']);
    set_param([model '/Brake'],...
        'Position',[50 400 200 440],...
        'Min','0','Max','1');
catch
    add_block('simulink/Sources/Constant',[model '/Brake']);
    set_param([model '/Brake'],...
        'Position',[50 400 200 440],...
        'Value','0');
end

ensureBlock([model '/ThrottleGain'],'simulink/Math Operations/Gain');
set_param([model '/ThrottleGain'],'Gain','4000');

ensureBlock([model '/BrakeGain'],           'simulink/Math Operations/Gain');
set_param([model '/BrakeGain'],'Gain','5000');

ensureBlock([model '/EngineGain'],'simulink/Math Operations/Gain');
set_param([model '/EngineGain'],'Gain',num2str(engine_gain));

ensureBlock([model '/GearGain'],'simulink/Math Operations/Gain');
set_param([model '/GearGain'],'Gain',num2str(gear/r));

ensureBlock([model '/BrakeForce'],'simulink/Math Operations/Gain');
set_param([model '/BrakeForce'],'Gain',num2str(brake_gain));

ensureBlock([model '/v2'],'simulink/Math Operations/Product');
ensureBlock([model '/One'],'simulink/Sources/Constant');
set_param([model '/One'],'Value','1');

ensureBlock([model '/DragGain'],'simulink/Math Operations/Gain');
set_param([model '/DragGain'],'Gain',num2str(dragGain));

ensureBlock([model '/Froll'],'simulink/Sources/Constant');
set_param([model '/Froll'],'Value',num2str(m*g*Cr));

ensureBlock([model '/Slope_deg'],'simulink/Sources/Constant');
set_param([model '/Slope_deg'],'Value','5');

ensureBlock([model '/SlopeToRad'],'simulink/Math Operations/Gain');
set_param([model '/SlopeToRad'],'Gain','pi/180');

ensureBlock([model '/sin'],                 ...
    'simulink/Math Operations/Trigonometric Function');

ensureBlock([model '/SlopeForce'],'simulink/Math Operations/Gain');
set_param([model '/SlopeForce'],'Gain',num2str(m*g));

ensureBlock([model '/NetForceSum'],'simulink/Math Operations/Sum');
set_param([model '/NetForceSum'],'Inputs','+---');


ensureBlock([model '/DecelDiff'],'simulink/Discrete/Discrete Derivative');

ensureBlock([model '/SlipCalc'], 'simulink/Math Operations/Gain');
set_param([model '/SlipCalc'],'Gain',sprintf('1/%f',g));

ensureBlock([model '/SlipLimit'],...
            'simulink/Logic and Bit Operations/Compare To Constant');
set_param([model '/SlipLimit'],'const','0.2');

ensureBlock([model '/ABSSwitch'],'simulink/Signal Routing/Switch');
set_param([model '/ABSSwitch'],'Threshold','0.5');

ensureBlock([model '/ABSBrakeGain'],'simulink/Math Operations/Gain');
set_param([model '/ABSBrakeGain'],'Gain','0.25');

% Pedals to gains
safe_line(model,'Throttle/1','ThrottleGain/1');
safe_line(model,'Brake/1','BrakeGain/1');

% Throttle chain
safe_line(model,'ThrottleGain/1','EngineGain/1');
safe_line(model,'EngineGain/1','GearGain/1');

% Brake chain with ABS
safe_line(model,'BrakeGain/1','ABSBrakeGain/1');
safe_line(model,'ABSBrakeGain/1','ABSSwitch/3');
safe_line(model,'BrakeGain/1','ABSSwitch/2');
safe_line(model,'ABSSwitch/1','BrakeForce/1');

% Velocity to drag
safe_line(model,'Vehicle3D/Vehicle Speed','v2/1');
safe_line(model,'One/1','v2/2');
safe_line(model,'v2/1','DragGain/1');

% Slope
safe_line(model,'Slope_deg/1','SlopeToRad/1');
safe_line(model,'SlopeToRad/1','sin/1');
safe_line(model,'sin/1','SlopeForce/1');

% Net force sum: throttle - drag - slope - brake
safe_line(model,'GearGain/1','NetForceSum/1');
safe_line(model,'DragGain/1','NetForceSum/2');
safe_line(model,'SlopeForce/1','NetForceSum/3');
safe_line(model,'BrakeForce/1','NetForceSum/4');

% Net force to vehicle
safe_line(model,'NetForceSum/1','Vehicle3D/Accel');

% ABS slip calculation
safe_line(model,'Vehicle3D/Vehicle Speed','DecelDiff/1');
safe_line(model,'DecelDiff/1','SlipCalc/1');
safe_line(model,'SlipCalc/1','SlipLimit/1');
safe_line(model,'SlipLimit/1','ABSSwitch/1');


add_vehicle_viewer(model);
add_speed_gauge(model);

save_system(model);
disp('✔ Car built — press RUN and use the sliders to drive!');
end


function build_vehicle3D(model)
if ~bdIsLoaded(model), load_system(model); end
carPath = [model '/Vehicle3D'];

if blockExists(carPath), delete_block(carPath); end

add_block('simulink/Ports & Subsystems/Subsystem',carPath);
set_param(carPath,'Position',[600 200 900 450]);

add_block('simulink/Ports & Subsystems/In1', [carPath '/Accel']);

add_block('simulink/Continuous/Integrator', [carPath '/v']);
add_block('simulink/Continuous/Integrator', [carPath '/Position']);
add_block('simulink/Math Operations/Gain',   [carPath '/Mass']);
add_block('simulink/Math Operations/Sum',    [carPath '/Sum']);

add_block('simulink/Ports & Subsystems/Out1',[carPath '/Vehicle Speed']);
add_block('simulink/Ports & Subsystems/Out1',[carPath '/Vehicle Position']);

set_param([carPath '/Mass'],'Gain','1/1200');
set_param([carPath '/Sum'],'Inputs','+');

add_line(carPath,'Accel/1','Sum/1');
add_line(carPath,'Sum/1','Mass/1');
add_line(carPath,'Mass/1','v/1');
add_line(carPath,'v/1','Vehicle Speed/1');
add_line(carPath,'v/1','Position/1');
add_line(carPath,'Position/1','Vehicle Position/1');
end


function add_vehicle_viewer(model)
viewerPath = [model '/VehicleViewer2D'];
if blockExists(viewerPath), delete_block(viewerPath); end

add_block('simulink/Sinks/XY Graph', viewerPath);
set_param(viewerPath,'Position',[950 200 1200 450]);

if blockExists([model '/ZeroLine']), delete_block([model '/ZeroLine']); end
add_block('simulink/Sources/Constant',[model '/ZeroLine']);
set_param([model '/ZeroLine'],'Value','0');

safe_line(model,'Vehicle3D/Vehicle Position','VehicleViewer2D/1');
safe_line(model,'ZeroLine/1','VehicleViewer2D/2');
end


function add_speed_gauge(model)
gaugePath = [model '/SpeedGauge'];
if blockExists(gaugePath), delete_block(gaugePath); end

try
    add_block('simulink/Dashboard/Gauge',gaugePath);
    set_param(gaugePath,'Position',[950 50 1200 150]);
catch
    % Fallback to Scope if Dashboard Gauge not available
    add_block('simulink/Sinks/Scope',gaugePath);
    set_param(gaugePath,'Position',[950 50 1200 150]);
    disp('Note: Using Scope instead of Gauge for speed display.');
end

safe_line(model,'Vehicle3D/Vehicle Speed','SpeedGauge/1');
end


function tf = blockExists(path)
try get_param(path,'Handle'); tf=true; catch, tf=false; end
end

function ok = isBlock(path)
try, get_param(path,'Handle'); ok=true; catch, ok=false; end
end

function ensureBlock(path,type)
if ~isBlock(path), add_block(type,path,'MakeNameUnique','off'); end
end

function safe_line(sys,src,dst)
try, add_line(sys,src,dst,'autorouting','on'); catch, end
end

