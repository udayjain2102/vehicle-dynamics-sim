function integrated_car_simulator()
% INTEGRATED CAR SIMULATOR - Combines Simulink physics with Phase 1 graphics
% Uses your Simulink model's physics (ABS, cruise, etc.) with interactive controls

clc;
disp('🔧 INTEGRATED CAR SIMULATOR');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('Checking for Simulink model...');

model = 'full_car';

% Check if model exists, if not build it
if ~exist([model '.slx'], 'file')
    disp('Model not found. Building it now...');
    try
        build_car();  % Your build function
        disp('✔ Model built successfully!');
    catch
        error('Could not build model. Make sure build_car.m is in your path.');
    end
else
    if ~bdIsLoaded(model)
        load_system(model);
    end
    disp('✔ Model loaded!');
end

disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('Controls:');
disp('  ↑ Up Arrow    = Throttle');
disp('  ↓ Down Arrow  = Brake');
disp('  ← → Arrows    = Steer Left/Right');
disp('  C Key         = Toggle Cruise Control');
disp('  ESC           = Exit');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('Starting in 2 seconds...');
pause(2);

% Vehicle parameters (matching your Simulink model)
m = 1200;           % mass (kg)
L = 2.7;            % wheelbase (m)
max_steer = 30;     % max steering angle (degrees)
max_speed = 50;     % max speed (m/s)

% Physics (from your model)
rho = 1.225; Cd = 0.32; A = 2.2;
Cr = 0.015; g = 9.81;
dragGain = 0.5*rho*Cd*A;
r = 0.30; gear = 9;
engine_gain = 350;
brake_gain = 9000;

% Simulation
dt = 0.03;
running = true;


x = 50;
y = 100;
theta = pi/2;
v = 0;
accel = 0;

% Control inputs
throttle = 0;
brake = 0;
steer_angle = 0;
cruise_enabled = false;
cruise_target = 20;  % m/s

% ABS state
abs_active = false;
slip_ratio = 0;

% Performance tracking
lap_time = 0;
max_speed_reached = 0;
max_gforce = 0;
brake_events = 0;
abs_activations = 0;
energy_used = 0;  % Joules
distance_traveled = 0;  % meters

% Input tracking
keys = struct('up', false, 'down', false, 'left', false, 'right', false);

track = create_oval_track(200, 200, 200, 100);


fig = figure('Name', '🔧 Integrated Car Simulator', ...
    'Color', [0.1 0.1 0.1], ...
    'Position', [50 50 1400 800], ...
    'KeyPressFcn', @keyPress, ...
    'KeyReleaseFcn', @keyRelease, ...
    'CloseRequestFcn', @closeWindow);

% Main view
ax_main = subplot(1, 2, 1);
hold on; axis equal; grid on;
set(ax_main, 'Color', [0.2 0.3 0.2], 'XColor', 'w', 'YColor', 'w');
title('Top-Down View', 'Color', 'white', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('X (m)', 'Color', 'white');
ylabel('Y (m)', 'Color', 'white');

% Draw track
plot(track.outer(:,1), track.outer(:,2), 'w-', 'LineWidth', 3);
plot(track.inner(:,1), track.inner(:,2), 'w-', 'LineWidth', 3);
plot(track.center(:,1), track.center(:,2), 'y--', 'LineWidth', 1);
plot([track.start(1) track.start(3)], [track.start(2) track.start(4)], 'r-', 'LineWidth', 4);

% Create car
car_length = 4.5;
car_width = 2.2;
car_shape = [-car_width/2, -car_length/2;
             car_width/2, -car_length/2;
             car_width/2, car_length/3;
             0, car_length/2;
             -car_width/2, car_length/3];

car_patch = patch('XData', car_shape(:,1)+x, 'YData', car_shape(:,2)+y, ...
    'FaceColor', 'red', 'EdgeColor', 'yellow', 'LineWidth', 2);

dir_line = plot([x x], [y y+10], 'c-', 'LineWidth', 2);

trail_x = x;
trail_y = y;
trail_plot = plot(trail_x, trail_y, 'c-', 'LineWidth', 1);

xlim([0 400]); ylim([0 400]);

% Dashboard
ax_dash = subplot(1, 2, 2);
hold on;
axis([0 1 0 1]);
axis off;
set(ax_dash, 'Color', [0.1 0.1 0.1]);

% Dashboard texts
txt_speed = text(ax_dash, 0.05, 0.95, '', 'Color', 'cyan', 'FontSize', 18, 'FontWeight', 'bold');
txt_rpm = text(ax_dash, 0.05, 0.90, '', 'Color', 'yellow', 'FontSize', 12);
txt_gear = text(ax_dash, 0.05, 0.86, '', 'Color', 'white', 'FontSize', 12);
txt_throttle = text(ax_dash, 0.05, 0.82, '', 'Color', 'green', 'FontSize', 11);
txt_brake = text(ax_dash, 0.05, 0.78, '', 'Color', 'red', 'FontSize', 11);
txt_steering = text(ax_dash, 0.05, 0.74, '', 'Color', 'yellow', 'FontSize', 11);
txt_cruise = text(ax_dash, 0.05, 0.70, '', 'Color', 'cyan', 'FontSize', 11, 'FontWeight', 'bold');
txt_abs = text(ax_dash, 0.05, 0.66, '', 'Color', 'red', 'FontSize', 11, 'FontWeight', 'bold');

% Engineering metrics section
text(ax_dash, 0.05, 0.58, 'FORCES & DYNAMICS:', 'Color', 'yellow', 'FontSize', 11, 'FontWeight', 'bold');
txt_engine_force = text(ax_dash, 0.05, 0.54, '', 'Color', 'green', 'FontSize', 9);
txt_brake_force = text(ax_dash, 0.05, 0.51, '', 'Color', 'red', 'FontSize', 9);
txt_drag_force = text(ax_dash, 0.05, 0.48, '', 'Color', 'cyan', 'FontSize', 9);
txt_net_force = text(ax_dash, 0.05, 0.45, '', 'Color', 'white', 'FontSize', 9, 'FontWeight', 'bold');
txt_power = text(ax_dash, 0.05, 0.42, '', 'Color', 'magenta', 'FontSize', 9);
txt_gforce = text(ax_dash, 0.05, 0.39, '', 'Color', [1 0.5 0], 'FontSize', 9);
txt_slip = text(ax_dash, 0.05, 0.36, '', 'Color', [1 0.5 0], 'FontSize', 9);

% Performance stats
text(ax_dash, 0.05, 0.30, 'PERFORMANCE:', 'Color', 'yellow', 'FontSize', 11, 'FontWeight', 'bold');
txt_laptime = text(ax_dash, 0.05, 0.26, '', 'Color', 'white', 'FontSize', 9);
txt_maxspeed = text(ax_dash, 0.05, 0.23, '', 'Color', 'white', 'FontSize', 9);
txt_maxg = text(ax_dash, 0.05, 0.20, '', 'Color', 'white', 'FontSize', 9);
txt_abs_count = text(ax_dash, 0.05, 0.17, '', 'Color', 'white', 'FontSize', 9);
txt_efficiency = text(ax_dash, 0.05, 0.14, '', 'Color', 'white', 'FontSize', 9);

% System status
text(ax_dash, 0.05, 0.08, 'ACTIVE SYSTEMS:', 'Color', 'cyan', 'FontSize', 10, 'FontWeight', 'bold');
txt_systems = text(ax_dash, 0.05, 0.04, '✔ Physics ✔ ABS ✔ Cruise', 'Color', 'green', 'FontSize', 8);

% Speedometer (left gauge)
gauge_angles = linspace(pi, 0, 100);
gauge_r = 0.18;
gauge_x = 0.65 + gauge_r * cos(gauge_angles);
gauge_y = 0.35 + gauge_r * sin(gauge_angles);
plot(ax_dash, gauge_x, gauge_y, 'w-', 'LineWidth', 3);

% Speed markings
for spd = 0:10:50
    ang = pi - (spd/50)*pi;
    x1 = 0.65 + 0.16*cos(ang);
    y1 = 0.35 + 0.16*sin(ang);
    x2 = 0.65 + 0.18*cos(ang);
    y2 = 0.35 + 0.18*sin(ang);
    plot(ax_dash, [x1 x2], [y1 y2], 'w-', 'LineWidth', 2);
    text(ax_dash, 0.65 + 0.13*cos(ang), 0.35 + 0.13*sin(ang), num2str(spd), ...
        'Color', 'white', 'FontSize', 8, 'HorizontalAlignment', 'center');
end

text(ax_dash, 0.65, 0.55, 'SPEED (m/s)', 'Color', 'cyan', 'FontSize', 11, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
gauge_needle_speed = plot(ax_dash, [0.65 0.65], [0.35 0.53], 'r-', 'LineWidth', 4);

% RPM Gauge (right gauge)
rpm_x = 0.65 + gauge_r * cos(gauge_angles);
rpm_y = 0.80 + gauge_r * sin(gauge_angles);
plot(ax_dash, rpm_x, rpm_y, 'w-', 'LineWidth', 3);

% RPM markings (0-7000 RPM)
for rpm_val = 0:1000:7000
    ang = pi - (rpm_val/7000)*pi;
    x1 = 0.65 + 0.16*cos(ang);
    y1 = 0.80 + 0.16*sin(ang);
    x2 = 0.65 + 0.18*cos(ang);
    y2 = 0.80 + 0.18*sin(ang);
    plot(ax_dash, [x1 x2], [y1 y2], 'w-', 'LineWidth', 2);
    text(ax_dash, 0.65 + 0.13*cos(ang), 0.80 + 0.13*sin(ang), sprintf('%d', rpm_val/1000), ...
        'Color', 'white', 'FontSize', 8, 'HorizontalAlignment', 'center');
end

% Redline zone
redline_angles = linspace(pi*0.15, 0, 50);
redline_x = 0.65 + (gauge_r-0.01) * cos(redline_angles);
redline_y = 0.80 + (gauge_r-0.01) * sin(redline_angles);
patch(ax_dash, [0.65, redline_x, 0.65], [0.80, redline_y, 0.80], 'red', 'FaceAlpha', 0.3, 'EdgeColor', 'none');

text(ax_dash, 0.65, 1.00, 'RPM (x1000)', 'Color', 'yellow', 'FontSize', 11, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
gauge_needle_rpm = plot(ax_dash, [0.65 0.65], [0.80 0.98], 'r-', 'LineWidth', 4);


prev_v = 0;
prev_brake_input = 0;

while running && ishandle(fig)
    tic;
    
    % Process inputs
    target_throttle = 0;
    target_brake = 0;
    target_steer = 0;
    
    if keys.up, target_throttle = 1.0; end
    if keys.down, target_brake = 1.0; end
    if keys.left, target_steer = -max_steer; end
    if keys.right, target_steer = max_steer; end
    
    % Smooth transitions
    throttle = throttle + (target_throttle - throttle) * 0.3;
    brake = brake + (target_brake - brake) * 0.3;
    steer_angle = steer_angle + (target_steer - steer_angle) * 0.2;
    
    % CRUISE CONTROL (from your Simulink model)
    if cruise_enabled && ~keys.up
        speed_error = cruise_target - v;
        cruise_output = 0.6 * speed_error + 0.2 * speed_error * dt;  % PID
        cruise_output = max(0, min(1, cruise_output));
        throttle = cruise_output;
    end
    
    % PHYSICS (from your Simulink model)
    F_engine = throttle * 4000 * engine_gain * (gear/r);
    F_drag = dragGain * v^2;
    F_roll = m * g * Cr;
    F_slope = m * g * sin(5 * pi/180);  % 5 degree slope
    
    % ABS SYSTEM (from your Simulink model)
    raw_brake_force = brake * 5000 * brake_gain;
    
    % Estimate slip from deceleration
    decel = (v - prev_v) / dt;
    slip_ratio = abs(decel) / (g + 0.001);
    
    % ABS activates if slip > 0.2
    if slip_ratio > 0.2 && brake > 0.1
        abs_active = true;
        F_brake = raw_brake_force * 0.25;  % Reduce braking
        if prev_brake_input < 0.1 && brake > 0.1
            abs_activations = abs_activations + 1;
        end
    else
        abs_active = false;
        F_brake = raw_brake_force;
    end
    
    prev_brake_input = brake;
    
    % Net force
    F_net = F_engine - F_brake - F_drag - F_roll - F_slope;
    
    % Acceleration
    accel = F_net / m;
    
    % G-force
    gforce = abs(accel) / g;
    max_gforce = max(max_gforce, gforce);
    
    % Update speed
    prev_v = v;
    v = v + accel * dt;
    v = max(0, min(v, max_speed));
    
    % Steering (bicycle model)
    if abs(v) > 0.1
        steer_rad = steer_angle * pi/180;
        turn_radius = L / tan(steer_rad + eps);
        omega = v / turn_radius;
        theta = theta + omega * dt;
    end
    
    % Position
    x = x + v * cos(theta) * dt;
    y = y + v * sin(theta) * dt;
    
    % Stats
    max_speed_reached = max(max_speed_reached, v);
    lap_time = lap_time + dt;
    distance_traveled = distance_traveled + v * dt;
    
    % Calculate energy consumption (Work = Force × Distance)
    energy_used = energy_used + F_engine * v * dt;  % Joules
    
    % Calculate RPM from speed and gear ratio
    wheel_rpm = (v / (2 * pi * r)) * 60;  % Wheel RPM
    engine_rpm = wheel_rpm * gear;  % Engine RPM
    
    % Trail
    trail_x = [trail_x; x];
    trail_y = [trail_y; y];
    if length(trail_x) > 500
        trail_x = trail_x(end-499:end);
        trail_y = trail_y(end-499:end);
    end
    
    % Update graphics
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    rotated_car = (R * car_shape')';
    
    if isvalid(car_patch)
        set(car_patch, 'XData', rotated_car(:,1)+x, 'YData', rotated_car(:,2)+y);
        
        % Change car color if ABS active
        if abs_active
            set(car_patch, 'FaceColor', 'yellow');
        else
            set(car_patch, 'FaceColor', 'red');
        end
    end
    
    if isvalid(dir_line)
        dir_end_x = x + 10*cos(theta);
        dir_end_y = y + 10*sin(theta);
        set(dir_line, 'XData', [x dir_end_x], 'YData', [y dir_end_y]);
    end
    
    if isvalid(trail_plot)
        set(trail_plot, 'XData', trail_x, 'YData', trail_y);
    end
    
    % Camera
    xlim(ax_main, [x-50, x+50]);
    ylim(ax_main, [y-50, y+50]);
    
    % Dashboard updates
    if isvalid(txt_speed)
        set(txt_speed, 'String', sprintf('%.1f m/s (%.0f km/h)', v, v*3.6));
    end
    if isvalid(txt_rpm)
        set(txt_rpm, 'String', sprintf('RPM: %.0f', engine_rpm));
    end
    if isvalid(txt_gear)
        set(txt_gear, 'String', sprintf('Gear Ratio: %.1f:1', gear));
    end
    if isvalid(txt_throttle)
        set(txt_throttle, 'String', sprintf('Throttle: %d%%', round(throttle*100)));
    end
    if isvalid(txt_brake)
        set(txt_brake, 'String', sprintf('Brake: %d%%', round(brake*100)));
    end
    if isvalid(txt_steering)
        set(txt_steering, 'String', sprintf('Steering: %+.1f°', steer_angle));
    end
    if isvalid(txt_cruise)
        if cruise_enabled
            set(txt_cruise, 'String', sprintf('🎯 CRUISE: ON (%.0f m/s)', cruise_target), 'Color', 'green');
        else
            set(txt_cruise, 'String', 'CRUISE: OFF', 'Color', [0.5 0.5 0.5]);
        end
    end
    if isvalid(txt_abs)
        if abs_active
            set(txt_abs, 'String', '⚠ ABS ACTIVE', 'Color', 'red');
        else
            set(txt_abs, 'String', 'ABS: Ready', 'Color', [0.5 0.5 0.5]);
        end
    end
    
    % Engineering metrics
    if isvalid(txt_engine_force)
        set(txt_engine_force, 'String', sprintf('F_engine: %.0f N', F_engine));
    end
    if isvalid(txt_brake_force)
        set(txt_brake_force, 'String', sprintf('F_brake: %.0f N', F_brake));
    end
    if isvalid(txt_drag_force)
        set(txt_drag_force, 'String', sprintf('F_drag: %.0f N', F_drag));
    end
    if isvalid(txt_net_force)
        set(txt_net_force, 'String', sprintf('F_net: %.0f N', F_net));
    end
    if isvalid(txt_power)
        power_kw = (F_engine * v) / 1000;  % kW
        set(txt_power, 'String', sprintf('Power: %.1f kW (%.1f HP)', power_kw, power_kw*1.34));
    end
    if isvalid(txt_gforce)
        set(txt_gforce, 'String', sprintf('G-Force: %.2f g', gforce));
    end
    if isvalid(txt_slip)
        set(txt_slip, 'String', sprintf('Slip: %.2f', slip_ratio));
    end
    if isvalid(txt_laptime)
        set(txt_laptime, 'String', sprintf('Time: %.1f s', lap_time));
    end
    if isvalid(txt_maxspeed)
        set(txt_maxspeed, 'String', sprintf('Max: %.1f m/s', max_speed_reached));
    end
    if isvalid(txt_maxg)
        set(txt_maxg, 'String', sprintf('Max G: %.2f g', max_gforce));
    end
    if isvalid(txt_abs_count)
        set(txt_abs_count, 'String', sprintf('ABS Events: %d', abs_activations));
    end
    if isvalid(txt_efficiency)
        if distance_traveled > 0
            efficiency = (energy_used / 1000000) / (distance_traveled / 1000);  % MJ/km
            set(txt_efficiency, 'String', sprintf('Energy: %.2f MJ/km', efficiency));
        end
    end
    
    % Speedometer needle
    if isvalid(gauge_needle_speed)
        speed_ratio = v / max_speed;
        needle_angle = pi - speed_ratio * pi;
        needle_x = 0.65 + 0.18 * cos(needle_angle);
        needle_y = 0.35 + 0.18 * sin(needle_angle);
        set(gauge_needle_speed, 'XData', [0.65 needle_x], 'YData', [0.35 needle_y]);
        
        if speed_ratio < 0.5
            set(gauge_needle_speed, 'Color', 'green');
        elseif speed_ratio < 0.8
            set(gauge_needle_speed, 'Color', 'yellow');
        else
            set(gauge_needle_speed, 'Color', 'red');
        end
    end
    
    % RPM needle
    if isvalid(gauge_needle_rpm)
        rpm_ratio = min(engine_rpm / 7000, 1.0);
        needle_angle_rpm = pi - rpm_ratio * pi;
        needle_x_rpm = 0.65 + 0.18 * cos(needle_angle_rpm);
        needle_y_rpm = 0.80 + 0.18 * sin(needle_angle_rpm);
        set(gauge_needle_rpm, 'XData', [0.65 needle_x_rpm], 'YData', [0.80 needle_y_rpm]);
        
        if rpm_ratio < 0.7
            set(gauge_needle_rpm, 'Color', 'green');
        elseif rpm_ratio < 0.85
            set(gauge_needle_rpm, 'Color', 'yellow');
        else
            set(gauge_needle_rpm, 'Color', 'red');
        end
    end
    
    drawnow limitrate;
    
    elapsed = toc;
    if elapsed < dt
        pause(dt - elapsed);
    end
end

disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('🏁 SIMULATION ENDED - PERFORMANCE REPORT');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(['Total Time: ' num2str(lap_time, '%.1f') ' s']);
disp(['Distance: ' num2str(distance_traveled, '%.1f') ' m']);
disp(['Max Speed: ' num2str(max_speed_reached*3.6, '%.1f') ' km/h']);
disp(['Max RPM: ' num2str(max(engine_rpm, max_speed_reached/(2*pi*r)*60*gear), '%.0f')]);
disp(['Max G-Force: ' num2str(max_gforce, '%.2f') ' g']);
disp(['ABS Activations: ' num2str(abs_activations)]);
disp(['Energy Used: ' num2str(energy_used/1000000, '%.2f') ' MJ']);
if distance_traveled > 0
    disp(['Energy Efficiency: ' num2str((energy_used/1000000)/(distance_traveled/1000), '%.2f') ' MJ/km']);
end
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');


    function keyPress(~, event)
        switch event.Key
            case 'uparrow'
                keys.up = true;
            case 'downarrow'
                keys.down = true;
            case 'leftarrow'
                keys.left = true;
            case 'rightarrow'
                keys.right = true;
            case 'c'
                cruise_enabled = ~cruise_enabled;
                if cruise_enabled
                    cruise_target = max(v, 15);  % Set to current speed or minimum
                end
            case 'escape'
                running = false;
        end
    end

    function keyRelease(~, event)
        switch event.Key
            case 'uparrow'
                keys.up = false;
            case 'downarrow'
                keys.down = false;
            case 'leftarrow'
                keys.left = false;
            case 'rightarrow'
                keys.right = false;
        end
    end

    function closeWindow(~, ~)
        running = false;
        delete(fig);
    end
end

function track = create_oval_track(center_x, center_y, length, width)
    theta = linspace(0, 2*pi, 200);
    a_outer = length/2 + 20;
    b_outer = width/2 + 20;
    outer_x = center_x + a_outer * cos(theta);
    outer_y = center_y + b_outer * sin(theta);
    
    a_inner = length/2 - 20;
    b_inner = width/2 - 20;
    inner_x = center_x + a_inner * cos(theta);
    inner_y = center_y + b_inner * sin(theta);
    
    a_center = length/2;
    b_center = width/2;
    center_x_line = center_x + a_center * cos(theta);
    center_y_line = center_y + b_center * sin(theta);
    
    start_line = [center_x + a_inner, center_y, ...
                  center_x + a_outer, center_y];
    
    track.outer = [outer_x' outer_y'];
    track.inner = [inner_x' inner_y'];
    track.center = [center_x_line' center_y_line'];
    track.start = start_line;
end