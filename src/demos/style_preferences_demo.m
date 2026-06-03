%% add "lines" color pallete from matlab

%% style_preferences_demo.m
% Demonstration of CIMTOOL style preferences system
%
% This demo shows:
% 1. Default behavior (uses saved preferences or factory defaults)
% 2. Programmatic customization via struct
% 3. GUI-based customization via Edit > Preferences menu
% 4. Saving and loading preferences across sessions

clear; clc;
fprintf('CIMTOOL Style Preferences Demo\n');
fprintf('================================\n\n');

%% Setup: Create a simple CIM problem
fprintf('Setting up CIM problem...\n');
import Visual.*;

% Create a simple operator (using omnicam1 example)
operatorData = OperatorData([], 'omnicam1');

% Create a circular contour
contour = Contour.Circle(0.4, 0.2, 8);

% Create CIM object
cim = CIM(operatorData, contour);

% Set some parameters
cim.SampleData.ell = 3;
cim.SampleData.r = 3;
cim.RealizationData.RealizationSize = Numerics.RealizationSize(3, 3);
cim.setComputationalMode(Numerics.ComputationalMode.Hankel);

% Compute eigenvalues
fprintf('Computing eigenvalues...\n\n');
cim.compute();

%% Example 1: Default Behavior
fprintf('Example 1: Default behavior (factory defaults or saved preferences)\n');
fprintf('--------------------------------------------------------------------\n');
fprintf('Starting CIMTOOL with default preferences...\n');
fprintf('Close the window to continue to the next example.\n\n');

app1 = CIMTOOL(cim);

%% Example 2: Programmatic Customization (Magenta Theme)
fprintf('\nExample 2: Programmatic customization - Magenta theme\n');
fprintf('--------------------------------------------------------\n');
fprintf('Applying custom style via struct argument...\n');
fprintf('  - Magenta contour\n');
fprintf('  - Cyan computed eigenvalues\n');
fprintf('  - Large markers\n\n');

magentaTheme = struct(...
    'ContourColor', '#FF00FF', ...
    'ContourLineWidth', 4, ...
    'QuadratureColor', '#FF00FF', ...
    'QuadratureMarker', 'o', ...
    'ComputedEigenvalueColor', '#00FFFF', ...
    'ComputedEigenvalueMarker', 'pentagram', ...
    'ComputedEigenvalueSize', 80, ...
    'ReferenceEigenvalueMarker', 'hexagram', ...
    'LegendLocation', 'northeast' ...
);

delete(app1);
app2 = CIMTOOL(cim, magentaTheme);

%% Example 3: Dark Theme
fprintf('\nExample 3: Programmatic customization - Dark theme\n');
fprintf('----------------------------------------------------\n');
fprintf('Applying dark color scheme...\n');
fprintf('  - Light colors on dark background\n');
fprintf('  - Yellow/Orange palette\n\n');

darkTheme = struct(...
    'ContourColor', '#FFD700', ...              % Gold
    'ContourLineWidth', 3, ...
    'QuadratureColor', '#FFA500', ...           % Orange
    'ReferenceEigenvalueColor', '#FF8C00', ...  % Dark orange
    'ComputedEigenvalueColor', '#FFFF00', ...   % Yellow
    'AxesBackgroundColor', [0.1 0.1 0.1], ...  % Dark gray
    'AxesGridColor', [0.3 0.3 0.3], ...        % Light gray
    'LegendLocation', 'southwest' ...
);

delete(app2);
app3 = CIMTOOL(cim, darkTheme);

%% Example 4: Minimal/Clean Theme
fprintf('\nExample 4: Programmatic customization - Minimal theme\n');
fprintf('-------------------------------------------------------\n');
fprintf('Applying minimal/clean aesthetic...\n');
fprintf('  - Thin lines\n');
fprintf('  - Small markers\n');
fprintf('  - No grid\n\n');

minimalTheme = struct(...
    'ContourColor', 'black', ...
    'ContourLineWidth', 1.5, ...
    'QuadratureSize', 50, ...
    'ReferenceEigenvalueSize', 40, ...
    'ComputedEigenvalueSize', 20, ...
    'ComputedEigenvalueColor', 'black', ...
    'AxesGridVisible', 'off', ...
    'LegendLocation', 'none' ...
);

delete(app3);
app4 = CIMTOOL(cim, minimalTheme);

%% Example 5: GUI-Based Customization
fprintf('\nExample 5: GUI-based customization\n');
fprintf('------------------------------------\n');
fprintf('Instructions:\n');
fprintf('1. Click Edit > Preferences (or press Ctrl+,)\n');
fprintf('2. Modify any styles in the tabbed interface\n');
fprintf('3. Click "Apply" to see changes immediately\n');
fprintf('4. Click "OK" to save and close\n');
fprintf('5. Preferences are automatically saved to disk\n\n');

delete(app4);
app5 = CIMTOOL(cim);
fprintf('CIMTOOL opened. Try the preferences dialog!\n\n');

%% Example 6: Verify Persistence
fprintf('\nExample 6: Verify persistence across sessions\n');
fprintf('-----------------------------------------------\n');
fprintf('Re-opening CIMTOOL without arguments...\n');
fprintf('Should use the preferences you just saved.\n\n');

delete(app5);
app6 = CIMTOOL(cim);

%% Demo Complete
fprintf('\n================================\n');
fprintf('Demo complete! The last CIMTOOL window is still open.\n');
fprintf('Close it when you are done exploring.\n');
fprintf('================================\n\n');

fprintf('Summary:\n');
fprintf('  - Default behavior: CIMTOOL() uses saved preferences\n');
fprintf('  - Programmatic: CIMTOOL(cim, styleStruct) applies custom styles\n');
fprintf('  - GUI: Edit > Preferences allows interactive customization\n');
fprintf('  - Persistence: Preferences are saved to MATLAB settings\n\n');

fprintf('To reset to factory defaults:\n');
fprintf('  1. Open CIMTOOL\n');
fprintf('  2. Edit > Preferences\n');
fprintf('  3. Click "Reset Defaults"\n');
fprintf('  4. Click "OK"\n\n');
