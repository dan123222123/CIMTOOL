%% test_style_preferences_persistence.m
% Test that StylePreferences can be saved to and loaded from MATLAB preferences
%
% This script verifies:
% 1. Save/load roundtrip preserves all property values
% 2. fromStruct/toStruct conversion works correctly
% 3. Factory defaults can be restored
% 4. Validation catches invalid values

clear; clc;
fprintf('Testing Visual.StylePreferences save/load persistence...\n\n');

%% Test 1: Save/Load Roundtrip
fprintf('Test 1: Save/load roundtrip\n');

% Create preferences with custom values
sp1 = Visual.StylePreferences();
sp1.ContourColor = "cyan";
sp1.ContourLineWidth = 3;
sp1.QuadratureMarker = "square";
sp1.ReferenceEigenvalueColor = "#FF00FF";
sp1.LegendLocation = "best";
sp1.LegendFontSize = 14;

% Save to preferences
sp1.save();
fprintf('  Saved custom preferences\n');

% Load from preferences
sp2 = Visual.StylePreferences.load();
fprintf('  Loaded preferences from disk\n');

% Verify all properties match
props = properties(sp1);
allMatch = true;
for i = 1:length(props)
    prop = props{i};
    val1 = sp1.(prop);
    val2 = sp2.(prop);

    % Handle different types
    if isnumeric(val1) && isnumeric(val2)
        if ~isequal(val1, val2)
            fprintf('  FAILED: %s mismatch (%.2f vs %.2f)\n', prop, val1, val2);
            allMatch = false;
        end
    elseif isstring(val1) || ischar(val1)
        if ~strcmp(char(val1), char(val2))
            fprintf('  FAILED: %s mismatch ("%s" vs "%s")\n', prop, char(val1), char(val2));
            allMatch = false;
        end
    end
end

if allMatch
    fprintf('  PASSED: All properties preserved\n');
else
    fprintf('  FAILED: Some properties were not preserved\n');
end
fprintf('\n');

%% Test 2: Struct Conversion
fprintf('Test 2: toStruct/fromStruct conversion\n');

s = sp1.toStruct();
fprintf('  Converted to struct (%d fields)\n', length(fieldnames(s)));

sp3 = Visual.StylePreferences.fromStruct(s);
fprintf('  Created from struct\n');

% Verify match
allMatch = true;
for i = 1:length(props)
    prop = props{i};
    if ~isequal(sp1.(prop), sp3.(prop))
        fprintf('  FAILED: %s mismatch after struct conversion\n', prop);
        allMatch = false;
    end
end

if allMatch
    fprintf('  PASSED: Struct conversion preserves all properties\n');
else
    fprintf('  FAILED: Struct conversion lost some properties\n');
end
fprintf('\n');

%% Test 3: Factory Defaults
fprintf('Test 3: Factory defaults\n');

sp4 = Visual.StylePreferences.factoryDefaults();
fprintf('  Created factory defaults\n');

% Check that some key defaults match expected values
checks = struct(...
    'ContourColor', "blue", ...
    'ContourLineWidth', 5, ...
    'QuadratureColor', "red", ...
    'QuadratureMarker', "x", ...
    'ReferenceEigenvalueColor', "#E66100", ...
    'ComputedEigenvalueColor', "#1AFF1A", ...
    'LegendLocation', "northoutside" ...
);

checkFields = fieldnames(checks);
allMatch = true;
for i = 1:length(checkFields)
    field = checkFields{i};
    expected = checks.(field);
    actual = sp4.(field);
    if ~isequal(expected, actual)
        fprintf('  FAILED: %s = "%s", expected "%s"\n', field, string(actual), string(expected));
        allMatch = false;
    end
end

if allMatch
    fprintf('  PASSED: All factory defaults match expected values\n');
else
    fprintf('  FAILED: Some factory defaults are incorrect\n');
end
fprintf('\n');

%% Test 4: Validation
fprintf('Test 4: Validation catches invalid values\n');

testsPassed = 0;
testsTotal = 0;

% Test invalid color
try
    testsTotal = testsTotal + 1;
    sp5 = Visual.StylePreferences();
    sp5.ContourColor = "not_a_real_color";
    sp5.validate();
    fprintf('  FAILED: Did not catch invalid color\n');
catch ME
    if contains(ME.identifier, 'InvalidColor')
        testsPassed = testsPassed + 1;
        fprintf('  PASSED: Caught invalid color\n');
    else
        fprintf('  FAILED: Wrong error for invalid color: %s\n', ME.identifier);
    end
end

% Test negative size
try
    testsTotal = testsTotal + 1;
    sp6 = Visual.StylePreferences();
    sp6.QuadratureSize = -10;
    sp6.validate();
    fprintf('  FAILED: Did not catch negative size\n');
catch ME
    if contains(ME.identifier, 'InvalidSize')
        testsPassed = testsPassed + 1;
        fprintf('  PASSED: Caught negative size\n');
    else
        fprintf('  FAILED: Wrong error for negative size: %s\n', ME.identifier);
    end
end

% Test invalid line style
try
    testsTotal = testsTotal + 1;
    sp7 = Visual.StylePreferences();
    sp7.ContourLineStyle = "wavy";
    sp7.validate();
    fprintf('  FAILED: Did not catch invalid line style\n');
catch ME
    if contains(ME.identifier, 'InvalidLineStyle')
        testsPassed = testsPassed + 1;
        fprintf('  PASSED: Caught invalid line style\n');
    else
        fprintf('  FAILED: Wrong error for invalid line style: %s\n', ME.identifier);
    end
end

% Test invalid marker
try
    testsTotal = testsTotal + 1;
    sp8 = Visual.StylePreferences();
    sp8.QuadratureMarker = "smiley";
    sp8.validate();
    fprintf('  FAILED: Did not catch invalid marker\n');
catch ME
    if contains(ME.identifier, 'InvalidMarker')
        testsPassed = testsPassed + 1;
        fprintf('  PASSED: Caught invalid marker\n');
    else
        fprintf('  FAILED: Wrong error for invalid marker: %s\n', ME.identifier);
    end
end

fprintf('  Validation: %d/%d tests passed\n', testsPassed, testsTotal);
fprintf('\n');

%% Test 5: Partial Struct (fromStruct with missing fields)
fprintf('Test 5: fromStruct with partial struct\n');

partialStruct = struct('ContourColor', 'magenta', 'QuadratureSize', 150);
sp9 = Visual.StylePreferences.fromStruct(partialStruct);

if strcmp(sp9.ContourColor, "magenta") && sp9.QuadratureSize == 150
    fprintf('  PASSED: Partial struct applied correctly\n');
else
    fprintf('  FAILED: Partial struct not applied correctly\n');
end

% Check that other properties have defaults
if strcmp(sp9.QuadratureMarker, "x")
    fprintf('  PASSED: Unspecified properties have defaults\n');
else
    fprintf('  FAILED: Unspecified properties do not have defaults\n');
end
fprintf('\n');

%% Summary
fprintf('======================================\n');
fprintf('All persistence tests completed!\n');
fprintf('======================================\n');
