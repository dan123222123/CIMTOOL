# GridLayoutButtonGroup Implementation

## Overview

This file documents the `GridLayoutButtonGroup` and `GridLayoutToggleButton` classes, which provide a resizable replacement for MATLAB's standard `uibuttongroup` that uses `GridLayout` for automatic resizing behavior.

## Motivation

MATLAB's standard `uibuttongroup` requires fixed positioning for buttons using the `Position` property (e.g., `[10 90 150 30]`). Additionally, MATLAB's `uitogglebutton` can only be parented to a `ButtonGroup`, not to a `GridLayout`. These limitations create issues in resizable GUIs where components should scale proportionally with the window size.

The `GridLayoutButtonGroup` and `GridLayoutToggleButton` solve these problems by:
1. Using MATLAB's `GridLayout` system where components automatically resize to fill available space
2. Providing a custom toggle button implementation that can be parented to `GridLayout`

## Implementation Details

### File Locations
- **GridLayoutButtonGroup**: `src/+GUI/GridLayoutButtonGroup.m`
- **GridLayoutToggleButton**: `src/+GUI/GridLayoutToggleButton.m`

### GridLayoutToggleButton

The `GridLayoutToggleButton` is a custom component that extends MATLAB's toggle button functionality to work with `GridLayout` containers.

#### Why It's Needed
MATLAB's standard `uitogglebutton` can only be created with a `ButtonGroup` parent. It cannot be directly parented to a `GridLayout`, which is required for our resizable button group implementation.

#### Implementation
`GridLayoutToggleButton` is a `ComponentContainer` that:
- Contains a standard `uibutton` internally (which CAN be parented to GridLayout)
- Maintains a `Value` property (logical) for selection state
- Updates button styling based on selection state:
  - **Selected**: Blue background (#4D9FFF), bold white text
  - **Unselected**: Light gray background, normal black text
- Provides the same interface as `uitogglebutton`:
  - `Text` property for button label
  - `Value` property (SetObservable) for selection state
  - Toggles value on button press

#### Visual Styling
```matlab
% Selected state
BackgroundColor = [0.3 0.6 1.0]  % Blue
FontWeight = 'bold'
FontColor = [1 1 1]              % White

% Unselected state
BackgroundColor = [0.96 0.96 0.96]  % Light gray
FontWeight = 'normal'
FontColor = [0 0 0]                 % Black
```

### GridLayoutButtonGroup Architecture

The `GridLayoutButtonGroup` is a `ComponentContainer` that:
1. Creates an internal `GridLayout` with dynamic row sizing
2. Displays a title label in row 1
3. Stacks buttons vertically in subsequent rows (2, 3, 4, etc.)
4. Implements mutual exclusivity (radio button behavior)
5. Provides callback support via `SelectionChangedFcn`

### Key Features

#### Resizable Layout
- Buttons use GridLayout row heights (`'1x'`) to share space equally
- Automatically adapts to parent container size changes
- No fixed pixel positions required

#### API Compatibility
Maintains compatibility with standard `uibuttongroup`:
- **Properties**:
  - `Title`: Button group title text
  - `TitlePosition`: Title positioning (currently supports 'centertop')
  - `SelectionChangedFcn`: Callback function for selection changes
  - `SelectedObject`: (read-only) Currently selected button

- **Methods**:
  - `addButton(text)`: Add a new toggle button with the specified text
  - Constructor accepts standard parent argument

#### Mutual Exclusivity
- Implements radio button behavior using property listeners
- Only one button can be selected at a time
- Prevents deselecting the last button (maintains selection)
- Triggers `SelectionChangedFcn` when selection changes

### Usage Example

```matlab
% Create button group in a grid layout
buttonGroup = GUI.GridLayoutButtonGroup(parentGrid);
buttonGroup.Title = 'Options';
buttonGroup.SelectionChangedFcn = @(src, event) disp(event.Value.Text);
buttonGroup.Layout.Row = [1 5];
buttonGroup.Layout.Column = 1;

% Add buttons dynamically
button1 = buttonGroup.addButton('Option 1');
button2 = buttonGroup.addButton('Option 2');
button3 = buttonGroup.addButton('Option 3');

% Set initial selection
button1.Value = true;

% Get selected button
selected = buttonGroup.SelectedObject;
disp(selected.Text);
```

## Files Modified

### 1. `src/+GUI/+Parameter/ContourTab.m`

**Changes**:
- Line 5: Changed `ContourTypeButtonGroup` property type from `matlab.ui.container.ButtonGroup` to `GUI.GridLayoutButtonGroup`
- Lines 6-8: Changed button property types from `matlab.ui.control.ToggleButton` to `GUI.GridLayoutToggleButton`
- Lines 89-106: Replaced fixed-position button creation with `addButton()` calls

**Before**:
```matlab
ContourTypeButtonGroup    matlab.ui.container.ButtonGroup
CircleButton              matlab.ui.control.ToggleButton
% ...
comp.ContourTypeButtonGroup = uibuttongroup(comp.GridLayout);
% ... property setup ...
comp.CircleButton = uitogglebutton(comp.ContourTypeButtonGroup);
comp.CircleButton.Text = 'Circle';
comp.CircleButton.Position = [10 90 150 30];
% ... similar for other buttons ...
```

**After**:
```matlab
ContourTypeButtonGroup    GUI.GridLayoutButtonGroup
CircleButton              GUI.GridLayoutToggleButton
% ...
comp.ContourTypeButtonGroup = GUI.GridLayoutButtonGroup(comp.GridLayout);
% ... property setup ...
comp.CircleButton = comp.ContourTypeButtonGroup.addButton('Circle');
comp.EllipseButton = comp.ContourTypeButtonGroup.addButton('Ellipse');
comp.CircularSegmentButton = comp.ContourTypeButtonGroup.addButton('CircularSegment');
```

### 2. `src/+GUI/+Parameter/MethodTab.m`

**Changes**:
- Line 3: Changed `ComputationalModeButtonGroup` property type to `GUI.GridLayoutButtonGroup`
- Lines 4-6: Changed button property types from `matlab.ui.control.ToggleButton` to `GUI.GridLayoutToggleButton`
- Lines 108-130: Replaced fixed-position button creation with `addButton()` calls

**Before**:
```matlab
ComputationalModeButtonGroup    matlab.ui.container.ButtonGroup
HankelButton                    matlab.ui.control.ToggleButton
% ...
comp.ComputationalModeButtonGroup = uibuttongroup(comp.GridLayout);
% ... property setup ...
comp.HankelButton = uitogglebutton(comp.ComputationalModeButtonGroup);
comp.HankelButton.Text = 'Hankel';
comp.HankelButton.Position = [10 90 150 30];
% ... similar for other buttons ...
```

**After**:
```matlab
ComputationalModeButtonGroup    GUI.GridLayoutButtonGroup
HankelButton                    GUI.GridLayoutToggleButton
% ...
comp.ComputationalModeButtonGroup = GUI.GridLayoutButtonGroup(comp.GridLayout);
% ... property setup ...
comp.HankelButton = comp.ComputationalModeButtonGroup.addButton('Hankel');
comp.SPLoewnerButton = comp.ComputationalModeButtonGroup.addButton('SPLoewner');
comp.MPLoewnerButton = comp.ComputationalModeButtonGroup.addButton('MPLoewner');
```

## Benefits

1. **Automatic Resizing**: Buttons resize proportionally with GUI window
2. **Maintainability**: No manual position calculations needed
3. **Consistency**: Follows MATLAB's modern GridLayout paradigm
4. **Extensibility**: Easy to add more buttons dynamically
5. **Compatibility**: Drop-in replacement for existing code

## Implementation Notes

### GridLayoutToggleButton Design
The custom toggle button uses a `ComponentContainer` wrapping a standard `uibutton` because:
- `uitogglebutton` requires a `ButtonGroup` parent and cannot be used in `GridLayout`
- `uibutton` can be parented to `GridLayout` and provides button click events
- The `Value` property is tracked manually with a `SetObservable` attribute
- Visual feedback (colors, font weight) indicates selection state
- Button clicks toggle the `Value` property, which triggers `PostSet` listeners

### Button Listeners
Each `GridLayoutToggleButton` has a `PostSet` listener on its `Value` property that:
- Deselects all other buttons when one is selected
- Prevents deselecting the last button (maintains selection)
- Triggers the `SelectionChangedFcn` callback

### Grid Layout Structure
```
Row 1 (fit):   [Title Label]
Row 2 (1x):    [Button 1   ]
Row 3 (1x):    [Button 2   ]
Row 4 (1x):    [Button 3   ]
...
```

The `'fit'` row height for the title ensures it takes only necessary space, while `'1x'` rows share remaining space equally among buttons.

### Callback Event Structure
The `SelectionChangedFcn` callback receives an event structure with:
- `PreviousValue`: Previously selected button (may be empty)
- `Value`: Currently selected button

This matches the interface of standard `uibuttongroup` for compatibility.

## Future Enhancements

Potential improvements:
- Support horizontal button layouts
- Support `TitlePosition` options beyond 'centertop'
- Add button icons support
- Support button tooltips
- Add programmatic button removal method

## Testing

To test the implementation:
1. Launch CIMTOOL with `CIMTOOL(cim)` where `cim` is a CIM data structure
2. Navigate to the Contour tab
3. Resize the window - buttons should resize proportionally
4. Click buttons to verify mutual exclusivity works
5. Verify selection callbacks trigger correctly

## References

- MATLAB GridLayout documentation: https://www.mathworks.com/help/matlab/ref/matlab.ui.container.gridlayout.html
- ComponentContainer documentation: https://www.mathworks.com/help/matlab/ref/matlab.ui.componentcontainer.componentcontainer.html
