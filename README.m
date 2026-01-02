function README()
% README - Vehicle Dynamics Simulator Project Information
% Run this file to learn about the project and how to use it
%
% Usage: Just type 'README' in the command window

clc;

%% Display Banner
disp(' ');
disp('╔════════════════════════════════════════════════════════════════╗');
disp('║                                                                ║');
disp('║          VEHICLE DYNAMICS SIMULATOR                            ║');
disp('║                                                                ║');
disp('║              Mechanical Engineering Project                    ║');
disp('║                     Portfolio Demo                             ║');
disp('║                                                                ║');
disp('╚════════════════════════════════════════════════════════════════╝');
disp(' ');

%% Project Overview
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('PROJECT OVERVIEW');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('A comprehensive vehicle dynamics simulation system featuring:');
disp(' ');
disp('  - Real-time interactive driving simulator');
disp('  - Physics-based vehicle modeling (ABS, Cruise Control)');
disp('  - Automated performance testing suite');
disp('  - Professional engineering reports and analysis');
disp('  - Data export (CSV, MATLAB, graphs)');
disp(' ');

%% Quick Start
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('QUICK START GUIDE');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('Run the complete demo (recommended):');
disp('  >> master_demo');
disp(' ');
disp('Or try individual features:');
disp(' ');
disp('  1. Interactive Driving:');
disp('     >> integrated_car_simulator');
disp(' ');
disp('  2. Automated Tests:');
disp('     >> scenario_test_suite');
disp(' ');
disp('  3. Build Simulink Model:');
disp('     >> build_car');
disp(' ');

%% Available Files
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('PROJECT FILES');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('Main Scripts:');
disp('  • master_demo.m                - Complete project demo');
disp('  • integrated_car_simulator.m   - Interactive driving');
disp('  • scenario_test_suite.m        - Automated testing');
disp(' ');
disp('Simulink Models:');
disp('  • build_car.m                  - Main vehicle model');
disp('  • car_builder.m                - Base physics');
disp('  • drivetrain_builder.m         - Powertrain system');
disp('  • cruise_control_builder.m     - PID cruise control');
disp('  • abs_builder.m                - ABS system');
disp(' ');
disp('Utilities:');
disp('  • phase1_car_simulator.m       - Standalone simulator');
disp('  • animate_car_3d.m             - 3D visualization');
disp('  • README.m                     - This file');
disp(' ');

%% Interactive Simulator Controls
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('INTERACTIVE SIMULATOR CONTROLS');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('  Up Arrow      = Throttle (Accelerate)');
disp('  Down Arrow    = Brake');
disp('  Left Arrow    = Steer Left');
disp('  Right Arrow   = Steer Right');
disp('  C Key         = Toggle Cruise Control');
disp('  ESC           = Exit/Continue');
disp(' ');
disp('Features:');
disp('  - Real-time dashboard with RPM, speed, forces');
disp('  - Visual ABS activation (car turns yellow)');
disp('  - Cruise control with PID controller');
disp('  - Performance metrics tracking');
disp(' ');

%% Automated Tests
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('AUTOMATED TEST SUITE');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('Four comprehensive performance tests:');
disp(' ');
disp('  1. Acceleration Test (0-60 km/h)');
disp('     -> Measures acceleration time and distance');
disp(' ');
disp('  2. Braking Distance (50->0 km/h)');
disp('     -> Emergency braking with ABS analysis');
disp(' ');
disp('  3. Hill Climb (15° slope, 100m)');
disp('     -> Power requirements for incline');
disp(' ');
disp('  4. Wet Road Handling');
disp('     -> Compares dry vs wet braking performance');
disp(' ');
disp('Results include:');
disp('  - Professional graphs (PNG format)');
disp('  - Text report (TXT)');
disp('  - Data export (CSV)');
disp('  - MATLAB data file (MAT)');
disp(' ');

%% Technical Details
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('TECHNICAL SPECIFICATIONS');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('Vehicle Parameters:');
disp('  • Mass:                1200 kg');
disp('  • Drag Coefficient:    0.32');
disp('  • Frontal Area:        2.2 m²');
disp('  • Wheelbase:           2.7 m');
disp('  • Gear Ratio:          9:1');
disp('  • Wheel Radius:        0.30 m');
disp(' ');
disp('Physics Model:');
disp('  • Aerodynamic drag force');
disp('  • Rolling resistance');
disp('  • Slope/gravity effects');
disp('  • Bicycle steering model');
disp(' ');
disp('Control Systems:');
disp('  • ABS (Anti-lock Braking System)');
disp('  • PID Cruise Control');
disp('  • Drivetrain modeling');
disp(' ');

%% Requirements
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('REQUIREMENTS');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('  • MATLAB R2020a or later (recommended)');
disp('  • Simulink (optional, for model building)');
disp('  • No additional toolboxes required');
disp(' ');

%% Sample Results
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('TYPICAL PERFORMANCE RESULTS');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('  Acceleration (0-60 km/h):    ~5.6 seconds');
disp('  Braking Distance (50->0):    ~21.5 meters');
disp('  Hill Climb Time (100m):      ~9.3 seconds');
disp('  Wet Road Increase:           ~47% longer');
disp(' ');

%% Output Files
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('GENERATED OUTPUT FILES');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('Running master_demo creates a timestamped folder with:');
disp(' ');
disp('  • test_results.mat           - MATLAB data');
disp('  • performance_report.txt     - Text summary');
disp('  • test_data.csv              - Excel-ready export');
disp('  • Fig1_Acceleration.png      - Speed/accel graphs');
disp('  • Fig2_Braking.png           - Braking analysis');
disp('  • Fig3_HillClimb.png         - Power curves');
disp('  • Fig4_WetRoad.png           - Road comparison');
disp('  • Fig5_Summary.png           - Overall summary');
disp(' ');

%% Author Info
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('PROJECT INFORMATION');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('  Author:    [Your Name]');
disp('  Course:    Mechanical Engineering');
disp('  Project:   Vehicle Dynamics Simulator');
disp('  Date:      January 2026');
disp('  GitHub:    github.com/yourusername/vehicle-dynamics-simulator');
disp(' ');

%% Interactive Menu
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp('WHAT WOULD YOU LIKE TO DO?');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('  1. Run Complete Demo (recommended)');
disp('  2. Interactive Driving Only');
disp('  3. Automated Tests Only');
disp('  4. View This Help Again');
disp('  5. Exit');
disp(' ');

choice = input('Enter your choice (1-5): ', 's');

switch choice
    case '1'
        disp(' ');
        disp('Starting complete demo...');
        disp(' ');
        pause(1);
        try
            master_demo();
        catch ME
            disp('Error running demo. Make sure all files are in the same folder.');
            disp(['Error: ' ME.message]);
        end
        
    case '2'
        disp(' ');
        disp('Starting interactive driving simulator...');
        disp(' ');
        pause(1);
        try
            integrated_car_simulator();
        catch ME
            disp('Error running simulator. Make sure all files are in the same folder.');
            disp(['Error: ' ME.message]);
        end
        
    case '3'
        disp(' ');
        disp('Starting automated test suite...');
        disp(' ');
        pause(1);
        try
            scenario_test_suite();
        catch ME
            disp('Error running tests. Make sure all files are in the same folder.');
            disp(['Error: ' ME.message]);
        end
        
    case '4'
        disp(' ');
        disp('Reloading README...');
        pause(1);
        README();
        
    case '5'
        disp(' ');
        disp('Thank you for checking out the Vehicle Dynamics Simulator!');
        disp(' ');
        disp('To run the demo later, type: master_demo');
        disp(' ');
        
    otherwise
        disp(' ');
        disp('Invalid choice. Please run README again and select 1-5.');
        disp(' ');
end

%% Footer
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');
disp('TIP: For quick access, bookmark these commands:');
disp('   • master_demo              -> Run everything');
disp('   • integrated_car_simulator -> Drive the car');
disp('   • scenario_test_suite      -> Run tests');
disp('   • README                   -> Show this help');
disp(' ');
disp('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
disp(' ');

end

