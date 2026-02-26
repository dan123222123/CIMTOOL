%% clear_style_preferences.m
% Clear saved CIMTOOL style preferences
%
% Use this script if you encounter errors related to corrupted or
% incompatible saved preferences (e.g., from an older version).
%
% This will reset to factory defaults on next CIMTOOL launch.

if ispref('CIMTOOL', 'StylePreferences')
    rmpref('CIMTOOL', 'StylePreferences');
    fprintf('Cleared saved CIMTOOL style preferences.\n');
    fprintf('Next launch will use factory defaults.\n');
else
    fprintf('No saved preferences found.\n');
end
