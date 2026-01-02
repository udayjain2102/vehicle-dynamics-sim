function animate_car_3d()
% ANIMATE_CAR_3D - Simple 3D animation using manual simulation
% Run this AFTER building your model with build_car

model = 'full_car';

% Make sure model is loaded
if ~bdIsLoaded(model)
    error('Model not loaded. Run build_car first!');
end

disp(' Starting manual simulation with animation...');

% Get initial conditions and parameters
m = 1200;
stopTime = 20;
dt = 0.02;  % time step
time = 0:dt:stopTime;
N = length(time);

% Initialize arrays
position = zeros(N,1);
speed = zeros(N,1);
accel = zeros(N,1);

% Create 3D figure first
fig = figure('Name', '3D Car Animation - Live', 'Color', 'w', 'Position', [100 100 1200 700]);
ax = axes('Parent', fig);
hold on; grid on; axis equal;
view(3);
xlabel('X Position (m)', 'FontSize', 12); 
ylabel('Y (m)', 'FontSize', 12); 
zlabel('Z (m)', 'FontSize', 12);
set(ax, 'Color', [0.7 0.9 1]);

% Draw road
roadX = [0 600 600 0];
roadY = [-2 -2 6 6];
roadZ = [0 0 0 0];
patch(roadX, roadY, roadZ, [0.3 0.3 0.3], 'EdgeColor', 'none');

% Road lines
for x = 0:10:600
    plot3([x x], [2 2], [0.05 0.05], 'y--', 'LineWidth', 2);
end

% Car dimensions
carLength = 4;
carWidth = 2;
carHeight = 1.5;
wheelRadius = 0.4;

% Create car body
carVerts = [0 0 wheelRadius; carLength 0 wheelRadius; 
            carLength carWidth wheelRadius; 0 carWidth wheelRadius;
            0 0 wheelRadius+carHeight; carLength 0 wheelRadius+carHeight;
            carLength carWidth wheelRadius+carHeight; 0 carWidth wheelRadius+carHeight];
carFaces = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
carBody = patch('Vertices', carVerts, 'Faces', carFaces, ...
                'FaceColor', 'red', 'EdgeColor', 'k', 'LineWidth', 2);

% Create wheels
theta = linspace(0, 2*pi, 20);
wheelX = wheelRadius * cos(theta);
wheelY = wheelRadius * sin(theta) * 0.3;
wheelZ = wheelRadius * sin(theta);

wheel1 = patch(wheelX*0+0.8, wheelY+0.5, wheelZ+wheelRadius, 'black', 'EdgeColor', 'none');
wheel2 = patch(wheelX*0+carLength-0.8, wheelY+0.5, wheelZ+wheelRadius, 'black', 'EdgeColor', 'none');
wheel3 = patch(wheelX*0+0.8, wheelY+carWidth-0.5, wheelZ+wheelRadius, 'black', 'EdgeColor', 'none');
wheel4 = patch(wheelX*0+carLength-0.8, wheelY+carWidth-0.5, wheelZ+wheelRadius, 'black', 'EdgeColor', 'none');

xlim([0 50]); ylim([-2 6]); zlim([0 3]);

% Physics parameters
rho = 1.225; Cd = 0.32; A = 2.2;
Cr = 0.015; g = 9.81;
dragGain = 0.5*rho*Cd*A;
r = 0.30; gear = 9;
engine_gain = 350;
brake_gain = 9000;
slope_deg = 5;
slope_rad = slope_deg * pi/180;

% Simple simulation loop with live animation
updateInterval = 10; % Update display every N steps
for i = 2:N
    t = time(i);
    
    % Throttle and brake inputs (step functions)
    if t < 1
        throttle = 0;
    else
        throttle = 0.6;
    end
    
    if t < 8
        brake = 0;
    else
        brake = 0.7;
    end
    
    % Forces
    F_throttle = throttle * 4000 * engine_gain * (gear/r);
    F_brake = brake * 5000 * brake_gain;
    F_drag = dragGain * speed(i-1)^2;
    F_roll = m * g * Cr;
    F_slope = m * g * sin(slope_rad);
    
    % Net force
    F_net = F_throttle - F_drag - F_roll - F_slope - F_brake;
    
    % Acceleration
    accel(i) = F_net / m;
    
    % Integrate
    speed(i) = speed(i-1) + accel(i) * dt;
    if speed(i) < 0, speed(i) = 0; end
    
    position(i) = position(i-1) + speed(i) * dt;
    
    % Update animation every few steps
    if mod(i, updateInterval) == 0
        pos = position(i);
        spd = speed(i);
        
        % Update car body
        newVerts = carVerts;
        newVerts(:,1) = newVerts(:,1) + pos;
        set(carBody, 'Vertices', newVerts);
        
        % Update wheels
        set(wheel1, 'XData', wheelX + pos + 0.8);
        set(wheel2, 'XData', wheelX + pos + carLength - 0.8);
        set(wheel3, 'XData', wheelX + pos + 0.8);
        set(wheel4, 'XData', wheelX + pos + carLength - 0.8);
        
        % Update camera
        xlim([pos-5, pos+45]);
        
        % Update title
        title(sprintf('Time: %.1fs | Speed: %.1f m/s (%.1f km/h)', ...
                      t, spd, spd*3.6), 'FontSize', 14, 'FontWeight', 'bold');
        
        drawnow limitrate;
    end
end

title(' Simulation Complete!', 'FontSize', 16, 'Color', 'green', 'FontWeight', 'bold');
disp('✔ Animation complete!');
disp(['Final position: ' num2str(position(end)) ' m']);
disp(['Final speed: ' num2str(speed(end)) ' m/s']);
end