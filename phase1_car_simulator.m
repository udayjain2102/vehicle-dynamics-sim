function phase1_car_simulator()
% PHASE 1 CAR SIMULATOR - Interactive 2D driving with keyboard controls
% Controls: Arrow Keys (Up=Throttle, Down=Brake, Left/Right=Steer)
%           ESC=Exit

clc;
disp('  PHASE 1: INTERACTIVE CAR SIMULATOR');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('Controls:');
disp('  ↑ Up Arrow    = Throttle');
disp('  ↓ Down Arrow  = Brake');
disp('  ← → Arrows    = Steer Left/Right');
disp('  ESC           = Exit');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('Starting in 2 seconds...');
pause(2);


% Vehicle parameters
m = 1200;           % mass (kg)
L = 2.7;            % wheelbase (m)
max_steer = 30;     % max steering angle (degrees)
max_speed = 50;     % max speed (m/s)

% Physics
rho = 1.225; Cd = 0.32; A = 2.2;
Cr = 0.015; g = 9.81;
dragGain = 0.5*rho*Cd*A;
rollGain = m*g*Cr;

% Control gains
throttle_gain = 8000;
brake_gain = 15000;
steer_rate = 60;    % degrees per second

% Simulation
dt = 0.03;          % time step (30 FPS)
running = true;


% Position and orientation
x = 50;             % x position (m)
y = 100;            % y position (m)
theta = pi/2;       % heading angle (rad, 0=East, pi/2=North)
v = 0;              % speed (m/s)

% Control inputs
throttle = 0;
brake = 0;
steer_angle = 0;    % current steering angle (degrees)

% Performance tracking
lap_time = 0;
max_speed_reached = 0;
max_gforce = 0;

% Input tracking
keys = struct('up', false, 'down', false, 'left', false, 'right', false);


% Simple oval track
track = create_oval_track(200, 350, 200, 100);

fig = figure('Name', 'Phase 1 Car Simulator', ...
    'Color', [0.1 0.1 0.1], ...
    'Position', [50 50 1400 800], ...
    'KeyPressFcn', @keyPress, ...
    'KeyReleaseFcn', @keyRelease, ...
    'CloseRequestFcn', @closeWindow);

% Main view (top-down)
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

% Start/finish line
plot([track.start(1) track.start(3)], [track.start(2) track.start(4)], ...
    'r-', 'LineWidth', 4);
text(track.start(1), track.start(2)-20, 'START/FINISH', ...
    'Color', 'red', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Create car (triangle pointing up initially)
car_length = 4.5;
car_width = 2.2;
car_shape = [-car_width/2, -car_length/2;
             car_width/2, -car_length/2;
             car_width/2, car_length/3;
             0, car_length/2;
             -car_width/2, car_length/3];

car_patch = patch('XData', car_shape(:,1)+x, 'YData', car_shape(:,2)+y, ...
    'FaceColor', 'red', 'EdgeColor', 'yellow', 'LineWidth', 2);

% Direction indicator
dir_line = plot([x x], [y y+10], 'c-', 'LineWidth', 2);

% Trajectory trail
trail_x = x;
trail_y = y;
trail_plot = plot(trail_x, trail_y, 'c-', 'LineWidth', 1);

xlim([0 400]); ylim([0 400]);

% Dashboard panel
ax_dash = subplot(1, 2, 2);
hold on;
axis([0 1 0 1]);
axis off;
set(ax_dash, 'Color', [0.1 0.1 0.1]);

% Dashboard text objects
txt_speed = text(ax_dash, 0.1, 0.95, '', 'Color', 'cyan', 'FontSize', 20, 'FontWeight', 'bold');
txt_throttle = text(ax_dash, 0.1, 0.85, '', 'Color', 'green', 'FontSize', 14);
txt_brake = text(ax_dash, 0.1, 0.80, '', 'Color', 'red', 'FontSize', 14);
txt_steering = text(ax_dash, 0.1, 0.75, '', 'Color', 'yellow', 'FontSize', 14);
txt_gforce = text(ax_dash, 0.1, 0.65, '', 'Color', 'magenta', 'FontSize', 14);
txt_position = text(ax_dash, 0.1, 0.55, '', 'Color', 'white', 'FontSize', 12);
txt_laptime = text(ax_dash, 0.1, 0.45, '', 'Color', 'white', 'FontSize', 12);
txt_maxspeed = text(ax_dash, 0.1, 0.40, '', 'Color', 'white', 'FontSize', 12);
txt_maxg = text(ax_dash, 0.1, 0.35, '', 'Color', 'white', 'FontSize', 12);

% Instructions
text(ax_dash, 0.1, 0.20, 'CONTROLS:', 'Color', 'yellow', 'FontSize', 14, 'FontWeight', 'bold');
text(ax_dash, 0.1, 0.15, '↑ = Throttle', 'Color', 'white', 'FontSize', 11);
text(ax_dash, 0.1, 0.11, '↓ = Brake', 'Color', 'white', 'FontSize', 11);
text(ax_dash, 0.1, 0.07, '← → = Steer', 'Color', 'white', 'FontSize', 11);
text(ax_dash, 0.1, 0.03, 'ESC = Exit', 'Color', 'white', 'FontSize', 11);

% Speedometer visualization (semi-circle gauge)
gauge_angles = linspace(pi, 0, 100);
gauge_r = 0.15;
gauge_x = 0.7 + gauge_r * cos(gauge_angles);
gauge_y = 0.7 + gauge_r * sin(gauge_angles);
plot(ax_dash, gauge_x, gauge_y, 'w-', 'LineWidth', 3);
text(ax_dash, 0.7, 0.5, '0', 'Color', 'white', 'FontSize', 10, 'HorizontalAlignment', 'center');
text(ax_dash, 0.85, 0.7, num2str(max_speed), 'Color', 'white', 'FontSize', 10);
text(ax_dash, 0.55, 0.7, '0', 'Color', 'white', 'FontSize', 10);
text(ax_dash, 0.7, 0.85, 'SPEED (m/s)', 'Color', 'cyan', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

gauge_needle = plot(ax_dash, [0.7 0.7], [0.7 0.85], 'r-', 'LineWidth', 4);


prev_v = 0;
while running && ishandle(fig)
    tic;
    
    % Process keyboard inputs
    target_throttle = 0;
    target_brake = 0;
    target_steer = 0;
    
    if keys.up
        target_throttle = 1.0;
    end
    if keys.down
        target_brake = 1.0;
    end
    if keys.left
        target_steer = -max_steer;
    end
    if keys.right
        target_steer = max_steer;
    end
    
    % Smooth control transitions
    throttle = throttle + (target_throttle - throttle) * 0.3;
    brake = brake + (target_brake - brake) * 0.3;
    steer_angle = steer_angle + (target_steer - steer_angle) * dt * steer_rate / max_steer;
    steer_angle = max(-max_steer, min(max_steer, steer_angle));
    
    % Calculate forces
    F_drive = throttle * throttle_gain;
    F_brake = brake * brake_gain;
    F_drag = dragGain * v^2;
    F_roll = rollGain * sign(v);
    
    F_net = F_drive - F_brake - F_drag - F_roll;
    
    % Acceleration
    a = F_net / m;
    
    % Update speed
    v = v + a * dt;
    v = max(0, min(v, max_speed)); % Clamp to [0, max_speed]
    
    % Calculate G-force
    gforce = abs(a) / g;
    max_gforce = max(max_gforce, gforce);
    
    % Bicycle model kinematics
    if abs(v) > 0.1
        steer_rad = steer_angle * pi/180;
        turn_radius = L / tan(steer_rad + eps);
        omega = v / turn_radius; % angular velocity
        theta = theta + omega * dt;
    end
    
    % Update position
    x = x + v * cos(theta) * dt;
    y = y + v * sin(theta) * dt;
    
    % Track max speed
    max_speed_reached = max(max_speed_reached, v);
    
    % Update lap time
    lap_time = lap_time + dt;
    
    % Update trail
    trail_x = [trail_x; x];
    trail_y = [trail_y; y];
    if length(trail_x) > 500
        trail_x = trail_x(end-499:end);
        trail_y = trail_y(end-499:end);
    end
    
    % Rotate car shape
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    rotated_car = (R * car_shape')';
    
    % Update graphics
    set(car_patch, 'XData', rotated_car(:,1)+x, 'YData', rotated_car(:,2)+y);
    
    dir_end_x = x + 10*cos(theta);
    dir_end_y = y + 10*sin(theta);
    set(dir_line, 'XData', [x dir_end_x], 'YData', [y dir_end_y]);
    
    set(trail_plot, 'XData', trail_x, 'YData', trail_y);
    
    % Update camera to follow car
    xlim([x-50, x+50]);
    ylim([y-50, y+50]);
    
    % Update dashboard (with validity checks)
    if isvalid(txt_speed)
        set(txt_speed, 'String', sprintf('SPEED: %.1f m/s (%.1f km/h)', v, v*3.6));
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
    if isvalid(txt_gforce)
        set(txt_gforce, 'String', sprintf('G-Force: %.2f g', gforce));
    end
    if isvalid(txt_position)
        set(txt_position, 'String', sprintf('Position: (%.1f, %.1f)', x, y));
    end
    if isvalid(txt_laptime)
        set(txt_laptime, 'String', sprintf('Time: %.1f s', lap_time));
    end
    if isvalid(txt_maxspeed)
        set(txt_maxspeed, 'String', sprintf('Max Speed: %.1f m/s', max_speed_reached));
    end
    if isvalid(txt_maxg)
        set(txt_maxg, 'String', sprintf('Max G: %.2f g', max_gforce));
    end
    
    % Update speedometer needle
    if isvalid(gauge_needle)
        speed_ratio = v / max_speed;
        needle_angle = pi - speed_ratio * pi;
        needle_x = 0.7 + 0.15 * cos(needle_angle);
        needle_y = 0.7 + 0.15 * sin(needle_angle);
        set(gauge_needle, 'XData', [0.7 needle_x], 'YData', [0.7 needle_y]);
        
        % Color-code speed
        if speed_ratio < 0.5
            set(gauge_needle, 'Color', 'green');
        elseif speed_ratio < 0.8
            set(gauge_needle, 'Color', 'yellow');
        else
            set(gauge_needle, 'Color', 'red');
        end
    end
    
    drawnow limitrate;
    
    % Maintain frame rate
    elapsed = toc;
    if elapsed < dt
        pause(dt - elapsed);
    end
    
    prev_v = v;
end

disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('🏁 SIMULATION ENDED');
disp(['Total Time: ' num2str(lap_time, '%.1f') ' seconds']);
disp(['Max Speed: ' num2str(max_speed_reached*3.6, '%.1f') ' km/h']);
disp(['Max G-Force: ' num2str(max_gforce, '%.2f') ' g']);
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
    % Creates an oval race track
    
    % Outer oval
    theta = linspace(0, 2*pi, 200);
    a_outer = length/2 + 20;
    b_outer = width/2 + 20;
    outer_x = center_x + a_outer * cos(theta);
    outer_y = center_y + b_outer * sin(theta);
    
    % Inner oval
    a_inner = length/2 - 20;
    b_inner = width/2 - 20;
    inner_x = center_x + a_inner * cos(theta);
    inner_y = center_y + b_inner * sin(theta);
    
    % Center line
    a_center = length/2;
    b_center = width/2;
    center_x_line = center_x + a_center * cos(theta);
    center_y_line = center_y + b_center * sin(theta);
    
    % Start/finish line (at rightmost point)
    start_line = [center_x + a_inner, center_y, ...
                  center_x + a_outer, center_y];
    
    track.outer = [outer_x' outer_y'];
    track.inner = [inner_x' inner_y'];
    track.center = [center_x_line' center_y_line'];
    track.start = start_line;
end