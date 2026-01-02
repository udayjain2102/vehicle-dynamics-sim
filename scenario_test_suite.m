function scenario_test_suite()
% SCENARIO TESTING SUITE - Automated vehicle performance tests
% Tests: 0-60km/h, Braking, Hill Climb, Wet Road

clc;
disp('╔════════════════════════════════════════════╗');
disp('║  VEHICLE PERFORMANCE TESTING SUITE         ║');
disp('║  Mechanical Engineering Project            ║');
disp('╚════════════════════════════════════════════╝');
disp(' ');
disp('Available Tests:');
disp('  1. Acceleration Test (0-60 km/h)');
disp('  2. Braking Distance Test');
disp('  3. Hill Climb Performance');
disp('  4. Wet Road Handling');
disp('  5. Run All Tests');
disp('  6. Compare Vehicle Configurations');
disp(' ');

choice = input('Select test (1-6): ');

switch choice
    case 1
        results = acceleration_test();
        display_results(results);
        plot_acceleration_data(results);
    case 2
        results = braking_test();
        display_results(results);
        plot_braking_data(results);
    case 3
        results = hill_climb_test();
        display_results(results);
        plot_hill_data(results);
    case 4
        results = wet_road_test();
        display_results(results);
        plot_wet_road_data(results);
    case 5
        run_all_tests();
    case 6
        compare_vehicles();
    otherwise
        disp('Invalid selection!');
        return;
end

end


function results = acceleration_test()
disp(' ');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('🏁 ACCELERATION TEST (0-60 km/h)');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

% Vehicle parameters
m = 1200;
dragGain = 0.4365;
rollGain = 176.58;
engine_force = 4000;
r = 0.30;
gear = 9;
engine_gain = 350;

% Simulation
dt = 0.01;
v = 0;
t = 0;
distance = 0;

target_speed = 60 / 3.6;  % 60 km/h in m/s

% Preallocate for speed
n_steps = ceil(30/dt);
time_log = zeros(n_steps, 1);
speed_log = zeros(n_steps, 1);
accel_log = zeros(n_steps, 1);
force_log = zeros(n_steps, 1);
idx = 0;

while v < target_speed && t < 30
    % Forces
    F_drive = engine_force * engine_gain * (gear/r);
    F_drag = dragGain * v^2;
    F_roll = rollGain;
    F_net = F_drive - F_drag - F_roll;
    
    % Acceleration
    a = F_net / m;
    
    % Update
    v = v + a * dt;
    distance = distance + v * dt;
    t = t + dt;
    
    % Log data
    idx = idx + 1;
    time_log(idx) = t;
    speed_log(idx) = v * 3.6;  % km/h
    accel_log(idx) = a;
    force_log(idx) = F_net;
end

% Trim arrays
time_log = time_log(1:idx);
speed_log = speed_log(1:idx);
accel_log = accel_log(1:idx);
force_log = force_log(1:idx);

results.test_name = 'Acceleration Test (0-60 km/h)';
results.time_to_60 = t;
results.distance = distance;
results.avg_accel = mean(accel_log);
results.max_accel = max(accel_log);
results.time_log = time_log;
results.speed_log = speed_log;
results.accel_log = accel_log;
results.force_log = force_log;

disp(['✔ Time to 60 km/h: ' num2str(t, '%.2f') ' seconds']);
disp(['✔ Distance covered: ' num2str(results.distance, '%.2f') ' meters']);
disp(['✔ Average acceleration: ' num2str(results.avg_accel, '%.2f') ' m/s²']);
disp(['✔ Max acceleration: ' num2str(results.max_accel, '%.2f') ' m/s²']);

end


function results = braking_test()
disp(' ');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('🛑 BRAKING DISTANCE TEST (50 km/h → 0)');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

% Parameters
m = 1200;
brake_gain = 9000;
brake_force_max = 5000 * brake_gain;
g = 9.81;

% Initial conditions
v = 50 / 3.6;  % 50 km/h in m/s
initial_v = v;
dt = 0.001;
t = 0;
distance = 0;

n_steps = ceil(10/dt);
time_log = zeros(n_steps, 1);
speed_log = zeros(n_steps, 1);
distance_log = zeros(n_steps, 1);
decel_log = zeros(n_steps, 1);
abs_active_log = zeros(n_steps, 1);
idx = 0;

while v > 0.1 && t < 10 && idx < n_steps
    % Calculate deceleration and slip
    decel = brake_force_max / m;
    slip = decel / g;
    
    % ABS activates if slip > 0.2
    if slip > 0.2
        F_brake = brake_force_max * 0.25;  % ABS reduces force
        abs_active = 1;
    else
        F_brake = brake_force_max;
        abs_active = 0;
    end
    
    % Deceleration
    a = -F_brake / m;
    
    % Update
    v = v + a * dt;
    v = max(0, v);
    distance = distance + v * dt;
    t = t + dt;
    
    % Log
    idx = idx + 1;
    time_log(idx) = t;
    speed_log(idx) = v * 3.6;
    distance_log(idx) = distance;
    decel_log(idx) = -a;
    abs_active_log(idx) = abs_active;
end

% Trim arrays
time_log = time_log(1:idx);
speed_log = speed_log(1:idx);
distance_log = distance_log(1:idx);
decel_log = decel_log(1:idx);
abs_active_log = abs_active_log(1:idx);

results.test_name = 'Braking Distance Test';
results.initial_speed = initial_v * 3.6;
results.braking_time = t;
results.braking_distance = distance;
results.avg_decel = mean(decel_log);
results.max_decel = max(decel_log);
results.abs_interventions = sum(diff([0; abs_active_log]) > 0);
results.time_log = time_log;
results.speed_log = speed_log;
results.distance_log = distance_log;
results.decel_log = decel_log;

disp(['✔ Braking distance: ' num2str(distance, '%.2f') ' meters']);
disp(['✔ Braking time: ' num2str(t, '%.2f') ' seconds']);
disp(['✔ Average deceleration: ' num2str(results.avg_decel, '%.2f') ' m/s² (%.2f g)', results.avg_decel/g]);
disp(['✔ ABS interventions: ' num2str(results.abs_interventions)]);

end

function results = hill_climb_test()
disp(' ');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('⛰️  HILL CLIMB TEST (15° slope, 100m)');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

% Parameters
m = 1200;
g = 9.81;
slope = 15 * pi/180;  % 15 degrees
dragGain = 0.4365;
rollGain = 176.58;
engine_force = 4000 * 350 * (9/0.3);

% Simulation
dt = 0.01;
v = 10;  % Start at 10 m/s
t = 0;
distance = 0;
target_distance = 100;  % 100 meter hill

time_log = [];
speed_log = [];
distance_log = [];
power_log = [];

while distance < target_distance && t < 60 && v > 0
    % Forces
    F_drive = engine_force;
    F_drag = dragGain * v^2;
    F_roll = rollGain;
    F_slope = m * g * sin(slope);
    F_net = F_drive - F_drag - F_roll - F_slope;
    
    % Acceleration
    a = F_net / m;
    
    % Update
    v = v + a * dt;
    v = max(0, v);
    distance = distance + v * dt;
    t = t + dt;
    
    % Power
    power = F_drive * v / 1000;  % kW
    
    % Log
    time_log(end+1,1) = t;
    speed_log(end+1,1) = v * 3.6;
    distance_log(end+1,1) = distance;
    power_log(end+1,1) = power;
end

results.test_name = 'Hill Climb Test (15°, 100m)';
results.climb_time = t;
results.final_speed = v * 3.6;
results.avg_speed = mean(speed_log);
results.avg_power = mean(power_log);
results.max_power = max(power_log);
results.time_log = time_log;
results.speed_log = speed_log;
results.distance_log = distance_log;
results.power_log = power_log;

if distance >= target_distance
    disp(['✔ Hill climb time: ' num2str(t, '%.2f') ' seconds']);
    disp(['✔ Final speed: ' num2str(v*3.6, '%.2f') ' km/h']);
    disp(['✔ Average speed: ' num2str(results.avg_speed, '%.2f') ' km/h']);
    disp(['✔ Average power: ' num2str(results.avg_power, '%.2f') ' kW']);
else
    disp('✖ Failed to complete hill climb!');
    disp(['✔ Distance achieved: ' num2str(distance, '%.2f') ' meters']);
end

end

function results = wet_road_test()
disp(' ');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('🌧️  WET ROAD HANDLING TEST');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

% Compare dry vs wet braking
disp('Testing braking performance on wet surface...');

% Wet road parameters (reduced friction)
wet_friction = 0.5;  % 50% grip
m = 1200;
brake_gain = 9000;
brake_force_max = 5000 * brake_gain * wet_friction;

v = 50 / 3.6;
dt = 0.001;
t = 0;
distance = 0;

time_log = [];
distance_log = [];
abs_events = 0;
prev_abs = false;

while v > 0.1 && t < 15
    F_brake = brake_force_max;
    a = -F_brake / m;
    
    slip = abs(a) / 9.81;
    if slip > 0.15  % Lower threshold for wet
        abs_active = true;
        F_brake = F_brake * 0.4;
        a = -F_brake / m;
        if ~prev_abs
            abs_events = abs_events + 1;
        end
    else
        abs_active = false;
    end
    prev_abs = abs_active;
    
    v = v + a * dt;
    v = max(0, v);
    distance = distance + v * dt;
    t = t + dt;
    
    time_log(end+1,1) = t;
    distance_log(end+1,1) = distance;
end

% Dry road comparison
dry_distance = braking_test();

results.test_name = 'Wet Road Handling Test';
results.wet_distance = distance;
results.dry_distance = dry_distance.braking_distance;
results.distance_increase = ((distance - dry_distance.braking_distance) / dry_distance.braking_distance) * 100;
results.wet_time = t;
results.abs_events = abs_events;
results.time_log = time_log;
results.distance_log = distance_log;

disp(['✔ Wet braking distance: ' num2str(distance, '%.2f') ' meters']);
disp(['✔ Dry braking distance: ' num2str(dry_distance.braking_distance, '%.2f') ' meters']);
disp(['✔ Increase: ' num2str(results.distance_increase, '%.1f') '%']);
disp(['✔ ABS activations: ' num2str(abs_events)]);

end


function run_all_tests()
disp(' ');
disp('╔════════════════════════════════════════════╗');
disp('║      RUNNING COMPLETE TEST SUITE           ║');
disp('╚════════════════════════════════════════════╝');

results_all = {};
results_all{1} = acceleration_test();
results_all{2} = braking_test();
results_all{3} = hill_climb_test();
results_all{4} = wet_road_test();

% Generate summary report
disp(' ');
disp('╔════════════════════════════════════════════╗');
disp('║         PERFORMANCE SUMMARY REPORT         ║');
disp('╚════════════════════════════════════════════╝');
disp(' ');
disp('Acceleration Performance:');
disp(['  • 0-60 km/h time: ' num2str(results_all{1}.time_to_60, '%.2f') ' s']);
disp(['  • Distance: ' num2str(results_all{1}.distance, '%.2f') ' m']);
disp(' ');
disp('Braking Performance:');
disp(['  • 50-0 km/h distance: ' num2str(results_all{2}.braking_distance, '%.2f') ' m']);
disp(['  • Stopping time: ' num2str(results_all{2}.braking_time, '%.2f') ' s']);
disp(' ');
disp('Hill Climb Performance:');
disp(['  • 100m climb time: ' num2str(results_all{3}.climb_time, '%.2f') ' s']);
disp(['  • Average power: ' num2str(results_all{3}.avg_power, '%.2f') ' kW']);
disp(' ');
disp('Wet Road Performance:');
disp(['  • Braking distance: ' num2str(results_all{4}.wet_distance, '%.2f') ' m']);
disp(['  • vs Dry: +' num2str(results_all{4}.distance_increase, '%.1f') '%']);
disp(' ');

% Create comprehensive plots
create_summary_plots(results_all);

% Export to CSV
export_results_to_csv(results_all);

end


function compare_vehicles()
disp(' ');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' VEHICLE COMPARISON MODE');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('Comparing three vehicle types:');
disp('  1. Sports Car (light, powerful)');
disp('  2. Sedan (balanced)');
disp('  3. SUV (heavy, less aerodynamic)');
disp(' ');

% Run acceleration test for all three
sports_time = run_accel_test(1000, 0.30, 5000);
sedan_time = run_accel_test(1200, 0.35, 4000);
suv_time = run_accel_test(1800, 0.50, 4500);

disp('Acceleration Results (0-60 km/h):');
disp(['  Sports Car: ' num2str(sports_time, '%.2f') ' s']);
disp(['  Sedan:      ' num2str(sedan_time, '%.2f') ' s']);
disp(['  SUV:        ' num2str(suv_time, '%.2f') ' s']);

% Plot comparison
figure('Name', 'Vehicle Comparison', 'Color', 'w');
bar([sports_time, sedan_time, suv_time]);
set(gca, 'XTickLabel', {'Sports Car', 'Sedan', 'SUV'});
ylabel('Time to 60 km/h (seconds)');
title('Acceleration Comparison');
grid on;

end

function time = run_accel_test(mass, drag_coef, engine_f)
v = 0;
t = 0;
dt = 0.01;
target = 60/3.6;

while v < target && t < 30
    F_net = engine_f * 350 * 9/0.3 - 0.5*1.225*drag_coef*2.2*v^2 - mass*9.81*0.015;
    a = F_net / mass;
    v = v + a * dt;
    t = t + dt;
end
time = t;
end


function plot_acceleration_data(results)
figure('Name', 'Acceleration Test Results', 'Color', 'w', 'Position', [100 100 1000 600]);

subplot(2,2,1);
plot(results.time_log, results.speed_log, 'b-', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Speed (km/h)');
title('Speed vs Time');
grid on;

subplot(2,2,2);
plot(results.time_log, results.accel_log, 'r-', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Acceleration (m/s²)');
title('Acceleration vs Time');
grid on;

subplot(2,2,3);
plot(results.time_log, results.force_log/1000, 'g-', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Net Force (kN)');
title('Net Force vs Time');
grid on;

subplot(2,2,4);
plot(results.speed_log, results.accel_log, 'm-', 'LineWidth', 2);
xlabel('Speed (km/h)'); ylabel('Acceleration (m/s²)');
title('Acceleration vs Speed');
grid on;
end

function plot_braking_data(results)
figure('Name', 'Braking Test Results', 'Color', 'w', 'Position', [100 100 1000 600]);

subplot(2,2,1);
plot(results.time_log, results.speed_log, 'b-', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Speed (km/h)');
title('Speed vs Time');
grid on;

subplot(2,2,2);
plot(results.distance_log, results.speed_log, 'r-', 'LineWidth', 2);
xlabel('Distance (m)'); ylabel('Speed (km/h)');
title('Speed vs Distance');
grid on;

subplot(2,2,3);
plot(results.time_log, results.decel_log, 'g-', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Deceleration (m/s²)');
title('Deceleration vs Time');
grid on;

subplot(2,2,4);
text(0.2, 0.7, sprintf('Braking Distance: %.2f m', results.braking_distance), 'FontSize', 14);
text(0.2, 0.5, sprintf('Braking Time: %.2f s', results.braking_time), 'FontSize', 14);
text(0.2, 0.3, sprintf('Avg Deceleration: %.2f m/s²', results.avg_decel), 'FontSize', 14);
axis off;
title('Summary');
end

function plot_hill_data(results)
figure('Name', 'Hill Climb Test Results', 'Color', 'w', 'Position', [100 100 1000 600]);

subplot(2,2,1);
plot(results.distance_log, results.speed_log, 'b-', 'LineWidth', 2);
xlabel('Distance (m)'); ylabel('Speed (km/h)');
title('Speed vs Distance');
grid on;

subplot(2,2,2);
plot(results.time_log, results.power_log, 'r-', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Power (kW)');
title('Power Output vs Time');
grid on;

subplot(2,2,3);
plot(results.time_log, results.speed_log, 'g-', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Speed (km/h)');
title('Speed vs Time');
grid on;

subplot(2,2,4);
text(0.2, 0.7, sprintf('Climb Time: %.2f s', results.climb_time), 'FontSize', 14);
text(0.2, 0.5, sprintf('Avg Power: %.2f kW', results.avg_power), 'FontSize', 14);
text(0.2, 0.3, sprintf('Final Speed: %.2f km/h', results.final_speed), 'FontSize', 14);
axis off;
title('Summary');
end

function plot_wet_road_data(results)
figure('Name', 'Wet Road Test Results', 'Color', 'w', 'Position', [100 100 800 400]);

subplot(1,2,1);
bar([results.dry_distance, results.wet_distance]);
set(gca, 'XTickLabel', {'Dry Road', 'Wet Road'});
ylabel('Braking Distance (m)');
title('Braking Distance Comparison');
grid on;

subplot(1,2,2);
text(0.1, 0.7, sprintf('Wet Distance: %.2f m', results.wet_distance), 'FontSize', 12);
text(0.1, 0.5, sprintf('Dry Distance: %.2f m', results.dry_distance), 'FontSize', 12);
text(0.1, 0.3, sprintf('Increase: %.1f%%', results.distance_increase), 'FontSize', 12, 'Color', 'red');
axis off;
title('Summary');
end

function create_summary_plots(results_all)
figure('Name', 'Complete Test Suite Results', 'Color', 'w', 'Position', [50 50 1200 800]);

% Acceleration plot
subplot(2,3,1);
plot(results_all{1}.time_log, results_all{1}.speed_log, 'b-', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Speed (km/h)');
title('Acceleration Test');
grid on;

% Braking plot
subplot(2,3,2);
plot(results_all{2}.distance_log, results_all{2}.speed_log, 'r-', 'LineWidth', 2);
xlabel('Distance (m)'); ylabel('Speed (km/h)');
title('Braking Test');
grid on;

% Hill climb plot
subplot(2,3,3);
plot(results_all{3}.time_log, results_all{3}.power_log, 'g-', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Power (kW)');
title('Hill Climb Test');
grid on;

% Comparison bars
subplot(2,3,4);
bar([results_all{1}.time_to_60]);
set(gca, 'XTickLabel', {'0-60 Time'});
ylabel('Time (s)');
title('Acceleration Performance');
grid on;

subplot(2,3,5);
bar([results_all{2}.braking_distance]);
set(gca, 'XTickLabel', {'Brake Dist'});
ylabel('Distance (m)');
title('Braking Performance');
grid on;

subplot(2,3,6);
bar([results_all{4}.dry_distance, results_all{4}.wet_distance]);
set(gca, 'XTickLabel', {'Dry', 'Wet'});
ylabel('Distance (m)');
title('Road Condition Comparison');
grid on;
end

function export_results_to_csv(results_all)
filename = sprintf('vehicle_test_results_%s.csv', datestr(now, 'yyyymmdd_HHMMSS'));

fid = fopen(filename, 'w');
fprintf(fid, 'VEHICLE PERFORMANCE TEST RESULTS\n');
fprintf(fid, 'Test Date: %s\n\n', datestr(now));

fprintf(fid, 'ACCELERATION TEST\n');
fprintf(fid, 'Time to 60 km/h,%.2f,seconds\n', results_all{1}.time_to_60);
fprintf(fid, 'Distance,%.2f,meters\n', results_all{1}.distance);
fprintf(fid, 'Average Acceleration,%.2f,m/s2\n\n', results_all{1}.avg_accel);

fprintf(fid, 'BRAKING TEST\n');
fprintf(fid, 'Braking Distance,%.2f,meters\n', results_all{2}.braking_distance);
fprintf(fid, 'Braking Time,%.2f,seconds\n', results_all{2}.braking_time);
fprintf(fid, 'Average Deceleration,%.2f,m/s2\n\n', results_all{2}.avg_decel);

fprintf(fid, 'HILL CLIMB TEST\n');
fprintf(fid, 'Climb Time,%.2f,seconds\n', results_all{3}.climb_time);
fprintf(fid, 'Average Power,%.2f,kW\n', results_all{3}.avg_power);
fprintf(fid, 'Final Speed,%.2f,km/h\n\n', results_all{3}.final_speed);

fprintf(fid, 'WET ROAD TEST\n');
fprintf(fid, 'Wet Braking Distance,%.2f,meters\n', results_all{4}.wet_distance);
fprintf(fid, 'Dry Braking Distance,%.2f,meters\n', results_all{4}.dry_distance);
fprintf(fid, 'Distance Increase,%.1f,percent\n', results_all{4}.distance_increase);

fclose(fid);

disp(' ');
disp(['✔ Results exported to: ' filename]);
end


function display_results(results)
disp(' ');
disp(['Test: ' results.test_name]);
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
end