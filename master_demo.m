function master_demo()
% MASTER_DEMO - Complete Vehicle Dynamics Simulator Portfolio Demo
% This script showcases all features of the Vehicle Dynamics project
%
% Author: Uday Aditya Jain
% Project: Interactive Vehicle Dynamics Simulator
% Date: January 2026

clc; close all;

%% ═══════════════════════════════════════════════════════════════
%%                    WELCOME SCREEN
%% ═══════════════════════════════════════════════════════════════

disp('╔════════════════════════════════════════════════════════════════╗');
disp('║                                                                ║');
disp('║        VEHICLE DYNAMICS SIMULATOR - MASTER DEMO                ║');
disp('║        Mechanical Engineering Portfolio Project               ║');
disp('║                                                                ║');
disp('╚════════════════════════════════════════════════════════════════╝');
disp(' ');
disp('This demo showcases:');
disp('  ✓ Real-time interactive driving simulator');
disp('  ✓ Simulink-based physics engine (ABS, Cruise Control)');
disp('  ✓ Automated performance testing suite');
disp('  ✓ Engineering analysis and reporting');
disp(' ');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');

%% ═══════════════════════════════════════════════════════════════
%%              CREATE RESULTS DIRECTORY
%% ═══════════════════════════════════════════════════════════════

timestamp = datestr(now, 'yyyymmdd_HHMMSS');
results_dir = ['Results_' timestamp];

if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

disp(['📁 Results will be saved to: ' results_dir]);
disp(' ');

%% ═══════════════════════════════════════════════════════════════
%%              PART 1: INTERACTIVE SIMULATOR
%% ═══════════════════════════════════════════════════════════════

disp('╔════════════════════════════════════════════════════════════════╗');
disp('║  PART 1: INTERACTIVE DRIVING SIMULATOR                         ║');
disp('╚════════════════════════════════════════════════════════════════╝');
disp(' ');
disp('You will now drive the car interactively!');
disp(' ');
disp('CONTROLS:');
disp('  ↑ = Throttle   ↓ = Brake');
disp('  ← = Left       → = Right');
disp('  C = Cruise Control Toggle');
disp('  ESC = Continue to next section');
disp(' ');

choice = input('Ready to drive? (Press Enter to start, or "s" to skip): ', 's');

if ~strcmpi(choice, 's')
    try
        integrated_car_simulator();
        disp(' ');
        disp('✔ Interactive driving complete!');
    catch
        disp('⚠ Interactive simulator not available. Continuing...');
    end
else
    disp('⊳ Skipped interactive driving.');
end

disp(' ');
pause(1);

%% ═══════════════════════════════════════════════════════════════
%%         PART 2: AUTOMATED PERFORMANCE TESTS
%% ═══════════════════════════════════════════════════════════════

disp('╔════════════════════════════════════════════════════════════════╗');
disp('║  PART 2: AUTOMATED PERFORMANCE TESTING                         ║');
disp('╚════════════════════════════════════════════════════════════════╝');
disp(' ');
disp('Running comprehensive test suite...');
disp(' ');

% Run all tests
test_results = run_all_performance_tests();

% Save test data
save([results_dir '/test_results.mat'], 'test_results');
disp(['✔ Test data saved to: ' results_dir '/test_results.mat']);
disp(' ');

%% ═══════════════════════════════════════════════════════════════
%%            PART 3: GENERATE COMPREHENSIVE REPORT
%% ═══════════════════════════════════════════════════════════════

disp('╔════════════════════════════════════════════════════════════════╗');
disp('║  PART 3: GENERATING ENGINEERING REPORT                         ║');
disp('╚════════════════════════════════════════════════════════════════╝');
disp(' ');

% Create comprehensive plots
create_report_figures(test_results, results_dir);

% Generate text report
generate_text_report(test_results, results_dir);

% Export to CSV
export_to_csv(test_results, results_dir);

disp(' ');
disp('✔ All reports generated!');
disp(' ');

%% ═══════════════════════════════════════════════════════════════
%%                   FINAL SUMMARY
%% ═══════════════════════════════════════════════════════════════

disp('╔════════════════════════════════════════════════════════════════╗');
disp('║                    DEMO COMPLETE!                              ║');
disp('╚════════════════════════════════════════════════════════════════╝');
disp(' ');
disp('📊 SUMMARY OF RESULTS:');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('Acceleration Performance:');
disp(['  • 0-60 km/h time: ' num2str(test_results.accel.time_to_60, '%.2f') ' seconds']);
disp(['  • Distance: ' num2str(test_results.accel.distance, '%.2f') ' meters']);
disp(' ');
disp('Braking Performance:');
disp(['  • Stopping distance (50→0 km/h): ' num2str(test_results.brake.braking_distance, '%.2f') ' meters']);
disp(['  • ABS activations: ' num2str(test_results.brake.abs_interventions)]);
disp(' ');
disp('Hill Climb Performance:');
disp(['  • 100m climb time: ' num2str(test_results.hill.climb_time, '%.2f') ' seconds']);
disp(['  • Average power: ' num2str(test_results.hill.avg_power, '%.2f') ' kW']);
disp(' ');
disp('Wet Road Performance:');
disp(['  • Wet vs Dry increase: +' num2str(test_results.wet.distance_increase, '%.1f') '%']);
disp(' ');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('📁 All results saved to:');
disp(['   ' pwd '/' results_dir]);
disp(' ');
disp('Files generated:');
disp('  ✓ test_results.mat       - MATLAB data file');
disp('  ✓ performance_report.txt - Text summary');
disp('  ✓ test_data.csv          - CSV export');
disp('  ✓ Figure 1-5             - Performance graphs');
disp(' ');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('🎓 Portfolio Project by [Your Name]');
disp('   Vehicle Dynamics Simulator - Mechanical Engineering');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');

% Open results folder
if ispc
    winopen(results_dir);
elseif ismac
    system(['open ' results_dir]);
else
    disp(['Results saved in: ' results_dir]);
end

end

%% ═══════════════════════════════════════════════════════════════
%%                    HELPER FUNCTIONS
%% ═══════════════════════════════════════════════════════════════

function results = run_all_performance_tests()
    % Run all four performance tests
    
    disp('Running Test 1/4: Acceleration Test...');
    results.accel = run_acceleration_test();
    
    disp('Running Test 2/4: Braking Test...');
    results.brake = run_braking_test();
    
    disp('Running Test 3/4: Hill Climb Test...');
    results.hill = run_hill_climb_test();
    
    disp('Running Test 4/4: Wet Road Test...');
    results.wet = run_wet_road_test(results.brake);
    
    disp('✔ All tests complete!');
end

function results = run_acceleration_test()
    m = 1200;
    dragGain = 0.4365;
    rollGain = 176.58;
    engine_force = 4000 * 350 * (9/0.3);
    
    dt = 0.01;
    v = 0;
    t = 0;
    distance = 0;
    target_speed = 60 / 3.6;
    
    n_steps = ceil(30/dt);
    time_log = zeros(n_steps, 1);
    speed_log = zeros(n_steps, 1);
    accel_log = zeros(n_steps, 1);
    idx = 0;
    
    while v < target_speed && t < 30
        F_net = engine_force - dragGain * v^2 - rollGain;
        a = F_net / m;
        v = v + a * dt;
        distance = distance + v * dt;
        t = t + dt;
        
        idx = idx + 1;
        time_log(idx) = t;
        speed_log(idx) = v * 3.6;
        accel_log(idx) = a;
    end
    
    results.time_to_60 = t;
    results.distance = distance;
    results.avg_accel = mean(accel_log(1:idx));
    results.time_log = time_log(1:idx);
    results.speed_log = speed_log(1:idx);
    results.accel_log = accel_log(1:idx);
end

function results = run_braking_test()
    m = 1200;
    brake_force_max = 5000 * 9000;
    g = 9.81;
    
    v = 50 / 3.6;
    dt = 0.001;
    t = 0;
    distance = 0;
    
    n_steps = ceil(10/dt);
    time_log = zeros(n_steps, 1);
    speed_log = zeros(n_steps, 1);
    distance_log = zeros(n_steps, 1);
    abs_log = zeros(n_steps, 1);
    idx = 0;
    
    while v > 0.1 && t < 10 && idx < n_steps
        slip = (brake_force_max / m) / g;
        if slip > 0.2
            F_brake = brake_force_max * 0.25;
            abs_active = 1;
        else
            F_brake = brake_force_max;
            abs_active = 0;
        end
        
        a = -F_brake / m;
        v = v + a * dt;
        v = max(0, v);
        distance = distance + v * dt;
        t = t + dt;
        
        idx = idx + 1;
        time_log(idx) = t;
        speed_log(idx) = v * 3.6;
        distance_log(idx) = distance;
        abs_log(idx) = abs_active;
    end
    
    results.braking_distance = distance;
    results.braking_time = t;
    results.abs_interventions = sum(diff([0; abs_log(1:idx)]) > 0);
    results.time_log = time_log(1:idx);
    results.speed_log = speed_log(1:idx);
    results.distance_log = distance_log(1:idx);
end

function results = run_hill_climb_test()
    m = 1200;
    g = 9.81;
    slope = 15 * pi/180;
    dragGain = 0.4365;
    rollGain = 176.58;
    engine_force = 4000 * 350 * (9/0.3);
    
    dt = 0.01;
    v = 10;
    t = 0;
    distance = 0;
    
    n_steps = ceil(60/dt);
    time_log = zeros(n_steps, 1);
    power_log = zeros(n_steps, 1);
    idx = 0;
    
    while distance < 100 && t < 60 && v > 0
        F_slope = m * g * sin(slope);
        F_net = engine_force - dragGain * v^2 - rollGain - F_slope;
        a = F_net / m;
        v = v + a * dt;
        v = max(0, v);
        distance = distance + v * dt;
        t = t + dt;
        
        idx = idx + 1;
        time_log(idx) = t;
        power_log(idx) = engine_force * v / 1000;
    end
    
    results.climb_time = t;
    results.avg_power = mean(power_log(1:idx));
    results.time_log = time_log(1:idx);
    results.power_log = power_log(1:idx);
end

function results = run_wet_road_test(dry_results)
    m = 1200;
    brake_force_max = 5000 * 9000 * 0.5;  % Wet friction
    
    v = 50 / 3.6;
    dt = 0.001;
    t = 0;
    distance = 0;
    
    while v > 0.1 && t < 15
        F_brake = brake_force_max;
        a = -F_brake / m;
        v = v + a * dt;
        v = max(0, v);
        distance = distance + v * dt;
        t = t + dt;
    end
    
    results.wet_distance = distance;
    results.dry_distance = dry_results.braking_distance;
    results.distance_increase = ((distance - dry_results.braking_distance) / dry_results.braking_distance) * 100;
end

function create_report_figures(results, results_dir)
    % Figure 1: Acceleration Performance
    figure('Name', 'Acceleration Test', 'Position', [100 100 1200 400]);
    
    subplot(1,3,1);
    plot(results.accel.time_log, results.accel.speed_log, 'b-', 'LineWidth', 2);
    xlabel('Time (s)'); ylabel('Speed (km/h)');
    title('Speed vs Time'); grid on;
    
    subplot(1,3,2);
    plot(results.accel.time_log, results.accel.accel_log, 'r-', 'LineWidth', 2);
    xlabel('Time (s)'); ylabel('Acceleration (m/s²)');
    title('Acceleration vs Time'); grid on;
    
    subplot(1,3,3);
    text(0.1, 0.7, sprintf('0-60 km/h: %.2f s', results.accel.time_to_60), 'FontSize', 14);
    text(0.1, 0.5, sprintf('Distance: %.2f m', results.accel.distance), 'FontSize', 14);
    text(0.1, 0.3, sprintf('Avg Accel: %.2f m/s²', results.accel.avg_accel), 'FontSize', 14);
    axis off; title('Summary');
    
    saveas(gcf, [results_dir '/Fig1_Acceleration.png']);
    
    % Figure 2: Braking Performance
    figure('Name', 'Braking Test', 'Position', [150 150 1200 400]);
    
    subplot(1,3,1);
    plot(results.brake.time_log, results.brake.speed_log, 'b-', 'LineWidth', 2);
    xlabel('Time (s)'); ylabel('Speed (km/h)');
    title('Braking: Speed vs Time'); grid on;
    
    subplot(1,3,2);
    plot(results.brake.distance_log, results.brake.speed_log, 'r-', 'LineWidth', 2);
    xlabel('Distance (m)'); ylabel('Speed (km/h)');
    title('Speed vs Distance'); grid on;
    
    subplot(1,3,3);
    text(0.1, 0.7, sprintf('Distance: %.2f m', results.brake.braking_distance), 'FontSize', 14);
    text(0.1, 0.5, sprintf('Time: %.2f s', results.brake.braking_time), 'FontSize', 14);
    text(0.1, 0.3, sprintf('ABS: %d times', results.brake.abs_interventions), 'FontSize', 14);
    axis off; title('Summary');
    
    saveas(gcf, [results_dir '/Fig2_Braking.png']);
    
    % Figure 3: Hill Climb
    figure('Name', 'Hill Climb Test', 'Position', [200 200 800 400]);
    
    subplot(1,2,1);
    plot(results.hill.time_log, results.hill.power_log, 'g-', 'LineWidth', 2);
    xlabel('Time (s)'); ylabel('Power (kW)');
    title('Power Output During Hill Climb'); grid on;
    
    subplot(1,2,2);
    text(0.1, 0.7, sprintf('Climb Time: %.2f s', results.hill.climb_time), 'FontSize', 14);
    text(0.1, 0.5, sprintf('Avg Power: %.2f kW', results.hill.avg_power), 'FontSize', 14);
    axis off; title('Summary');
    
    saveas(gcf, [results_dir '/Fig3_HillClimb.png']);
    
    % Figure 4: Wet vs Dry Comparison
    figure('Name', 'Wet Road Comparison', 'Position', [250 250 800 400]);
    
    subplot(1,2,1);
    bar([results.wet.dry_distance, results.wet.wet_distance]);
    set(gca, 'XTickLabel', {'Dry', 'Wet'});
    ylabel('Braking Distance (m)');
    title('Dry vs Wet Road Braking'); grid on;
    
    subplot(1,2,2);
    text(0.1, 0.7, sprintf('Dry: %.2f m', results.wet.dry_distance), 'FontSize', 14);
    text(0.1, 0.5, sprintf('Wet: %.2f m', results.wet.wet_distance), 'FontSize', 14);
    text(0.1, 0.3, sprintf('Increase: +%.1f%%', results.wet.distance_increase), 'FontSize', 14, 'Color', 'red');
    axis off; title('Comparison');
    
    saveas(gcf, [results_dir '/Fig4_WetRoad.png']);
    
    % Figure 5: Overall Summary
    figure('Name', 'Performance Summary', 'Position', [300 300 1000 600]);
    
    subplot(2,2,1);
    bar(results.accel.time_to_60);
    ylabel('Time (s)'); title('0-60 km/h Time');
    set(gca, 'XTickLabel', {''}); grid on;
    
    subplot(2,2,2);
    bar(results.brake.braking_distance);
    ylabel('Distance (m)'); title('50-0 km/h Braking');
    set(gca, 'XTickLabel', {''}); grid on;
    
    subplot(2,2,3);
    bar(results.hill.climb_time);
    ylabel('Time (s)'); title('100m Hill Climb');
    set(gca, 'XTickLabel', {''}); grid on;
    
    subplot(2,2,4);
    bar([results.wet.dry_distance, results.wet.wet_distance]);
    set(gca, 'XTickLabel', {'Dry', 'Wet'});
    ylabel('Distance (m)'); title('Braking Comparison');
    grid on;
    
    saveas(gcf, [results_dir '/Fig5_Summary.png']);
    
    disp('✔ 5 figures saved as PNG files');
end

function generate_text_report(results, results_dir)
    filename = [results_dir '/performance_report.txt'];
    fid = fopen(filename, 'w');
    
    fprintf(fid, '════════════════════════════════════════════════════════════\n');
    fprintf(fid, '           VEHICLE PERFORMANCE TEST REPORT\n');
    fprintf(fid, '    Mechanical Engineering Portfolio Project\n');
    fprintf(fid, '════════════════════════════════════════════════════════════\n\n');
    fprintf(fid, 'Test Date: %s\n\n', datestr(now));
    
    fprintf(fid, '────────────────────────────────────────────────────────────\n');
    fprintf(fid, 'TEST 1: ACCELERATION PERFORMANCE (0-60 km/h)\n');
    fprintf(fid, '────────────────────────────────────────────────────────────\n');
    fprintf(fid, 'Time to 60 km/h:        %.2f seconds\n', results.accel.time_to_60);
    fprintf(fid, 'Distance covered:       %.2f meters\n', results.accel.distance);
    fprintf(fid, 'Average acceleration:   %.2f m/s²\n\n', results.accel.avg_accel);
    
    fprintf(fid, '────────────────────────────────────────────────────────────\n');
    fprintf(fid, 'TEST 2: BRAKING PERFORMANCE (50-0 km/h)\n');
    fprintf(fid, '────────────────────────────────────────────────────────────\n');
    fprintf(fid, 'Braking distance:       %.2f meters\n', results.brake.braking_distance);
    fprintf(fid, 'Braking time:           %.2f seconds\n', results.brake.braking_time);
    fprintf(fid, 'ABS interventions:      %d times\n\n', results.brake.abs_interventions);
    
    fprintf(fid, '────────────────────────────────────────────────────────────\n');
    fprintf(fid, 'TEST 3: HILL CLIMB PERFORMANCE (15° slope, 100m)\n');
    fprintf(fid, '────────────────────────────────────────────────────────────\n');
    fprintf(fid, 'Climb time:             %.2f seconds\n', results.hill.climb_time);
    fprintf(fid, 'Average power output:   %.2f kW\n\n', results.hill.avg_power);
    
    fprintf(fid, '────────────────────────────────────────────────────────────\n');
    fprintf(fid, 'TEST 4: WET ROAD HANDLING\n');
    fprintf(fid, '────────────────────────────────────────────────────────────\n');
    fprintf(fid, 'Dry braking distance:   %.2f meters\n', results.wet.dry_distance);
    fprintf(fid, 'Wet braking distance:   %.2f meters\n', results.wet.wet_distance);
    fprintf(fid, 'Distance increase:      +%.1f%%\n\n', results.wet.distance_increase);
    
    fprintf(fid, '════════════════════════════════════════════════════════════\n');
    fprintf(fid, '                      END OF REPORT\n');
    fprintf(fid, '════════════════════════════════════════════════════════════\n');
    
    fclose(fid);
    disp(['✔ Text report saved: ' filename]);
end

function export_to_csv(results, results_dir)
    filename = [results_dir '/test_data.csv'];
    fid = fopen(filename, 'w');
    
    fprintf(fid, 'Test,Metric,Value,Unit\n');
    fprintf(fid, 'Acceleration,0-60 Time,%.2f,seconds\n', results.accel.time_to_60);
    fprintf(fid, 'Acceleration,Distance,%.2f,meters\n', results.accel.distance);
    fprintf(fid, 'Acceleration,Avg Accel,%.2f,m/s2\n', results.accel.avg_accel);
    fprintf(fid, 'Braking,Distance,%.2f,meters\n', results.brake.braking_distance);
    fprintf(fid, 'Braking,Time,%.2f,seconds\n', results.brake.braking_time);
    fprintf(fid, 'Braking,ABS Events,%d,count\n', results.brake.abs_interventions);
    fprintf(fid, 'Hill Climb,Time,%.2f,seconds\n', results.hill.climb_time);
    fprintf(fid, 'Hill Climb,Avg Power,%.2f,kW\n', results.hill.avg_power);
    fprintf(fid, 'Wet Road,Wet Distance,%.2f,meters\n', results.wet.wet_distance);
    fprintf(fid, 'Wet Road,Dry Distance,%.2f,meters\n', results.wet.dry_distance);
    fprintf(fid, 'Wet Road,Increase,%.1f,percent\n', results.wet.distance_increase);
    
    fclose(fid);
    disp(['✔ CSV data saved: ' filename]);
end