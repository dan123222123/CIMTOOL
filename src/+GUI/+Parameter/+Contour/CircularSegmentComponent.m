classdef CircularSegmentComponent < GUI.Parameter.Contour.ContourComponent
% Parameter panel for a CircularSegment contour.
%
% The angular span [theta(1), theta(2)] is set with a circular "arc picker":
% a schematic unit circle with two draggable rim handles (start/end) and a
% shaded segment. Center (gamma) and radius (rho) keep their numeric fields,
% and the start/end angles are also editable as degrees for precise entry.
% The contour stores theta in RADIANS; this component only converts for display.

    % GUI Properties
    properties (Access = private)
        GridLayout              matlab.ui.container.GridLayout
        gammaEditField          matlab.ui.control.EditField
        rhoEditField            matlab.ui.control.NumericEditField
        startEditField          matlab.ui.control.NumericEditField
        endEditField            matlab.ui.control.NumericEditField
        gammaEditFieldLabel     matlab.ui.control.Label
        rhoEditFieldLabel       matlab.ui.control.Label
        startEditFieldLabel     matlab.ui.control.Label
        endEditFieldLabel       matlab.ui.control.Label
        qrSwitch                matlab.ui.control.Switch   % CC <-> GL quadrature rule
        qrSwitchLabel           matlab.ui.control.Label
        DialAxes                matlab.ui.control.UIAxes
        % persistent dial graphics (created once, updated in refreshDial);
        % left untyped -- plot() returns chart.primitive.Line, patch() a
        % primitive.Patch, and an unset handle stays [] so isempty() guards work
        hCatcher                % transparent full-area patch: catches clicks to flip
        hCircle
        hSegment
        hChord
        hStartSpoke
        hEndSpoke
        hStartHandle
        hEndHandle
        hCenter
        % drag state: "start"/"end" (resize one angle), "rotate" (spin both
        % angles, preserving the span), or "" when idle
        ActiveHandle            string = ""
        RotateGrabOffset        double = 0   % angle (grab point - mid) at rotate start
    end

    properties (Access = public)
        CIMData                 Numerics.CIM
    end

    methods (Access = public)

        function obj = CircularSegmentComponent(Parent,CIMData)

            obj@GUI.Parameter.Contour.ContourComponent(Parent)
            obj.CIMData = CIMData;
            assert(isa(obj.CIMData.SampleData.Contour,'Numerics.Contour.CircularSegment'));

            obj.setDefaults();

            % reflect external changes (drag on the main plot, type switches,
            % programmatic edits) back into the fields and the dial
            addlistener(obj.CIMData.SampleData.Contour,'gamma','PostSet',@(src,event)obj.setDefaults);
            addlistener(obj.CIMData.SampleData.Contour,'rho','PostSet',@(src,event)obj.setDefaults);
            addlistener(obj.CIMData.SampleData.Contour,'theta','PostSet',@(src,event)obj.setDefaults);
            addlistener(obj.CIMData.SampleData.Contour,'qr','PostSet',@(src,event)obj.setDefaults);

        end

        function setDefaults(comp)
            contour = comp.CIMData.SampleData.Contour;
            comp.gammaEditField.Value = num2str(contour.gamma);
            comp.rhoEditField.Value = contour.rho;
            comp.startEditField.Value = rad2deg(contour.theta(1));
            comp.endEditField.Value = rad2deg(contour.theta(2));
            if contour.qr == "gauss"      % programmatic set -> no callback fired
                comp.qrSwitch.Value = 'GL';
            else
                comp.qrSwitch.Value = 'CC';
            end
            comp.refreshDial();
        end

        function updateFontSize(comp,update)
            fontsize(comp.GridLayout.Children,update,"points");
        end

    end

    % Callbacks that handle component events
    methods (Access = private)

        function rhoEditFieldValueChanged(comp,~)
            try
                comp.CIMData.SampleData.Contour.rho = comp.rhoEditField.Value;
            catch
                update(comp);
                errordlg("Invalid radius. Please check input and try again.")
            end
        end

        function startEditFieldValueChanged(comp,~)
            comp.setAngle("start", deg2rad(comp.startEditField.Value));
        end

        function endEditFieldValueChanged(comp,~)
            comp.setAngle("end", deg2rad(comp.endEditField.Value));
        end

        function gammaEditFieldValueChanged(comp,~)
            try
                comp.CIMData.SampleData.Contour.gamma = str2double(comp.gammaEditField.Value);
            catch
                update(comp);
                errordlg("Invalid center. Please check input and try again.")
            end
        end

        % toggle the quadrature rule on each boundary piece: CC (Clenshaw-Curtis,
        % nests under refinement) <-> GL (Gauss-Legendre, higher order, no nesting)
        function qrSwitchValueChanged(comp,~)
            if strcmp(comp.qrSwitch.Value,'GL'); rule = "gauss"; else; rule = "clencurt"; end
            try
                comp.CIMData.SampleData.Contour.qr = rule;
            catch
                comp.setDefaults();
                errordlg("Could not set the quadrature rule.")
            end
        end

        % Set one end of the angular span (radians), keeping the other fixed
        % and enforcing the contour's rules (start<end, span<=2*pi). On an
        % invalid request we revert the fields/dial rather than throw.
        function setAngle(comp, which, ang)
            minspan = deg2rad(0.5);   % keep a sliver so theta(2) > theta(1)
            t = comp.CIMData.SampleData.Contour.theta;
            if which == "start"
                ang = min(ang, t(2) - minspan);
                ang = max(ang, t(2) - 2*pi + minspan);
                t(1) = ang;
            else
                ang = max(ang, t(1) + minspan);
                ang = min(ang, t(1) + 2*pi - minspan);
                t(2) = ang;
            end
            try
                comp.CIMData.SampleData.Contour.theta = t;
            catch
                comp.setDefaults();
                errordlg("Invalid angle. Please check input and try again.")
            end
        end

        % --- dragging: rim handles resize one angle; the body rotates both ---
        function beginDrag(comp, which)
            comp.ActiveHandle = which;
            if which == "rotate"
                % remember where on the segment the user grabbed (relative to
                % the mid-angle) so that point stays under the cursor while spinning
                cp = comp.DialAxes.CurrentPoint;
                grabAng = atan2(cp(1,2), cp(1,1));
                t = comp.CIMData.SampleData.Contour.theta;
                comp.RotateGrabOffset = GUI.Parameter.Contour.CircularSegmentComponent.wrapToPiLocal(grabAng - (t(1)+t(2))/2);
            end
            fig = ancestor(comp, 'figure');
            if isempty(fig); return; end
            fig.WindowButtonMotionFcn = @(s,e)comp.doDrag();
            fig.WindowButtonUpFcn     = @(s,e)comp.endDrag();
        end

        function doDrag(comp)
            if comp.ActiveHandle == "" || ~isvalid(comp) ...
                    || ~isa(comp.CIMData.SampleData.Contour,'Numerics.Contour.CircularSegment')
                return;
            end
            cp = comp.DialAxes.CurrentPoint;
            mouseAng = atan2(cp(1,2), cp(1,1));
            t = comp.CIMData.SampleData.Contour.theta;
            if comp.ActiveHandle == "rotate"
                % spin so the grabbed point tracks the cursor; span is preserved
                mid = (t(1)+t(2))/2;
                delta = GUI.Parameter.Contour.CircularSegmentComponent.wrapToPiLocal(mouseAng - comp.RotateGrabOffset - mid);
                comp.rotate(delta);
            else
                % move one endpoint, following the mouse continuously (unwrapped)
                if comp.ActiveHandle == "start"; cur = t(1); else; cur = t(2); end
                ang = cur + GUI.Parameter.Contour.CircularSegmentComponent.wrapToPiLocal(mouseAng - cur);
                comp.setAngle(comp.ActiveHandle, ang);
            end
        end

        % Rotate the whole segment by delta radians, preserving the span.
        function rotate(comp, delta)
            t = comp.CIMData.SampleData.Contour.theta;
            span = t(2) - t(1);
            s = GUI.Parameter.Contour.CircularSegmentComponent.wrapToPiLocal(t(1) + delta);
            try
                comp.CIMData.SampleData.Contour.theta = [s, s + span];
            catch
                comp.setDefaults();
            end
        end

        function endDrag(comp)
            comp.ActiveHandle = "";
            fig = ancestor(comp, 'figure');
            if isempty(fig); return; end
            fig.WindowButtonMotionFcn = '';
            fig.WindowButtonUpFcn = '';
        end

        % --- click the un-shaded side to flip to the complementary segment --
        function onDiskClick(comp)
            if ~isvalid(comp) || ~isa(comp.CIMData.SampleData.Contour,'Numerics.Contour.CircularSegment')
                return;
            end
            cp = comp.DialAxes.CurrentPoint;
            ang = atan2(cp(1,2), cp(1,1));
            t = comp.CIMData.SampleData.Contour.theta;
            span = t(2) - t(1);
            % only flip when the click lands OUTSIDE the currently shaded arc
            if mod(ang - t(1), 2*pi) > span
                comp.flipSegment();
            end
        end

        % Select the complementary segment: keep both rim points but swap the
        % start/end (red/blue) roles, so the shaded arc jumps to the other side.
        function flipSegment(comp)
            t = comp.CIMData.SampleData.Contour.theta;
            newspan = 2*pi - (t(2) - t(1));
            s = GUI.Parameter.Contour.CircularSegmentComponent.wrapToPiLocal(t(2));
            try
                comp.CIMData.SampleData.Contour.theta = [s, s + newspan];
            catch
                comp.setDefaults();   % degenerate span (~0 or ~2*pi): revert quietly
            end
        end

        % redraw the schematic dial (unit circle; angles only -- gamma/rho
        % live in their own fields)
        function refreshDial(comp)
            if isempty(comp.hCircle) || ~isvalid(comp.hCircle); return; end
            t1 = comp.CIMData.SampleData.Contour.theta(1);
            t2 = comp.CIMData.SampleData.Contour.theta(2);
            arc = linspace(t1, t2, 128);
            comp.hSegment.XData = cos(arc);  comp.hSegment.YData = sin(arc);   % patch auto-closes (chord)
            comp.hChord.XData = [cos(t1) cos(t2)]; comp.hChord.YData = [sin(t1) sin(t2)];
            comp.hStartSpoke.XData = [0 cos(t1)]; comp.hStartSpoke.YData = [0 sin(t1)];
            comp.hEndSpoke.XData   = [0 cos(t2)]; comp.hEndSpoke.YData   = [0 sin(t2)];
            comp.hStartHandle.XData = cos(t1); comp.hStartHandle.YData = sin(t1);
            comp.hEndHandle.XData   = cos(t2); comp.hEndHandle.YData   = sin(t2);
        end

    end

    methods (Access = protected)

        function update(~)
            %nothing
        end

        % Create the underlying components
        function setup(comp)

            comp.GridLayout = uigridlayout(comp,[8 2]);
            comp.GridLayout.ColumnSpacing = 10;
            comp.GridLayout.Padding = [10 10 10 10];
            comp.GridLayout.RowHeight = {'fit','fit','1x','1x','1x','fit','fit','fit'};
            comp.GridLayout.ColumnWidth = {'1x','1x'};

            % --- center (gamma) ---
            comp.gammaEditField = uieditfield(comp.GridLayout, 'text');
            comp.gammaEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @gammaEditFieldValueChanged, true);
            comp.gammaEditField.HorizontalAlignment = 'center';
            comp.gammaEditField.Layout.Row = 1; comp.gammaEditField.Layout.Column = 1;
            comp.gammaEditField.Value = '0';

            comp.gammaEditFieldLabel = uilabel(comp.GridLayout);
            comp.gammaEditFieldLabel.HorizontalAlignment = 'center';
            comp.gammaEditFieldLabel.Layout.Row = 2; comp.gammaEditFieldLabel.Layout.Column = 1;
            comp.gammaEditFieldLabel.Text = 'center';

            % --- radius (rho) ---
            comp.rhoEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.rhoEditField.Limits = [0 Inf];
            comp.rhoEditField.LowerLimitInclusive = 'off';
            comp.rhoEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @rhoEditFieldValueChanged, true);
            comp.rhoEditField.HorizontalAlignment = 'center';
            comp.rhoEditField.Layout.Row = 1; comp.rhoEditField.Layout.Column = 2;
            comp.rhoEditField.Value = 1;

            comp.rhoEditFieldLabel = uilabel(comp.GridLayout);
            comp.rhoEditFieldLabel.HorizontalAlignment = 'center';
            comp.rhoEditFieldLabel.WordWrap = 'on';
            comp.rhoEditFieldLabel.Layout.Row = 2; comp.rhoEditFieldLabel.Layout.Column = 2;
            comp.rhoEditFieldLabel.Text = 'rho';

            % --- arc picker dial ---
            comp.DialAxes = uiaxes(comp.GridLayout);
            comp.DialAxes.Layout.Row = [3 5];
            comp.DialAxes.Layout.Column = [1 2];
            axis(comp.DialAxes, 'equal');
            comp.DialAxes.XLim = [-1.25 1.25]; comp.DialAxes.YLim = [-1.25 1.25];
            comp.DialAxes.XTick = []; comp.DialAxes.YTick = [];
            comp.DialAxes.XColor = 'none'; comp.DialAxes.YColor = 'none';
            comp.DialAxes.Toolbar.Visible = 'off';
            disableDefaultInteractivity(comp.DialAxes);
            hold(comp.DialAxes,'on');

            % transparent click-catcher covering the whole axes, drawn first so
            % it sits UNDER the handles (which stay grabbable on top). A click
            % here that lands on the un-shaded arc flips to the complementary
            % segment; PickableParts='all' keeps it clickable despite alpha 0.
            comp.hCatcher = patch(comp.DialAxes, 'XData',[-1.25 1.25 1.25 -1.25], ...
                'YData',[-1.25 -1.25 1.25 1.25], 'FaceColor',[1 1 1], 'FaceAlpha',0, ...
                'EdgeColor','none', 'PickableParts','all');
            comp.hCatcher.ButtonDownFcn = @(s,e)comp.onDiskClick();

            % full circle outline (reference); non-pickable so clicks fall through
            a = linspace(0,2*pi,256);
            comp.hCircle = plot(comp.DialAxes, cos(a), sin(a), ':', 'Color',[.6 .6 .6], 'PickableParts','none');
            % shaded segment -- grab its body to ROTATE the whole segment
            % (both angles together, preserving the span)
            comp.hSegment = patch(comp.DialAxes, 'XData',cos(a), 'YData',sin(a), ...
                'FaceColor',[0.30 0.55 0.95], 'FaceAlpha',0.25, 'EdgeColor','none', 'PickableParts','all');
            comp.hSegment.ButtonDownFcn = @(s,e)comp.beginDrag("rotate");
            % chord + spokes
            comp.hChord     = plot(comp.DialAxes, [0 0],[0 0], '-',  'Color',[0.30 0.55 0.95], 'LineWidth',1.5, 'PickableParts','none');
            comp.hStartSpoke= plot(comp.DialAxes, [0 0],[0 0], '-',  'Color',[.8 .8 .8], 'PickableParts','none');
            comp.hEndSpoke  = plot(comp.DialAxes, [0 0],[0 0], '-',  'Color',[.8 .8 .8], 'PickableParts','none');
            comp.hCenter    = plot(comp.DialAxes, 0,0, '+', 'Color',[.4 .4 .4], 'PickableParts','none');
            % draggable handles (drawn last => on top); grab to drag
            comp.hStartHandle = plot(comp.DialAxes, 1,0, 'o', 'MarkerSize',11, ...
                'MarkerFaceColor',[0.85 0.20 0.20], 'MarkerEdgeColor','k', 'LineWidth',1);
            comp.hEndHandle = plot(comp.DialAxes, 0,1, 'o', 'MarkerSize',11, ...
                'MarkerFaceColor',[0.20 0.45 0.85], 'MarkerEdgeColor','k', 'LineWidth',1);
            comp.hStartHandle.ButtonDownFcn = @(s,e)comp.beginDrag("start");
            comp.hEndHandle.ButtonDownFcn   = @(s,e)comp.beginDrag("end");

            % --- precise angle entry (degrees) ---
            comp.startEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.startEditField.ValueDisplayFormat = '%.1f';
            comp.startEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @startEditFieldValueChanged, true);
            comp.startEditField.HorizontalAlignment = 'center';
            comp.startEditField.Layout.Row = 6; comp.startEditField.Layout.Column = 1;

            comp.startEditFieldLabel = uilabel(comp.GridLayout);
            comp.startEditFieldLabel.HorizontalAlignment = 'center';
            comp.startEditFieldLabel.WordWrap = 'on';
            comp.startEditFieldLabel.Layout.Row = 7; comp.startEditFieldLabel.Layout.Column = 1;
            comp.startEditFieldLabel.Text = 'start (deg)';

            comp.endEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.endEditField.ValueDisplayFormat = '%.1f';
            comp.endEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @endEditFieldValueChanged, true);
            comp.endEditField.HorizontalAlignment = 'center';
            comp.endEditField.Layout.Row = 6; comp.endEditField.Layout.Column = 2;

            comp.endEditFieldLabel = uilabel(comp.GridLayout);
            comp.endEditFieldLabel.HorizontalAlignment = 'center';
            comp.endEditFieldLabel.WordWrap = 'on';
            comp.endEditFieldLabel.Layout.Row = 7; comp.endEditFieldLabel.Layout.Column = 2;
            comp.endEditFieldLabel.Text = 'end (deg)';

            % --- quadrature rule: CC (Clenshaw-Curtis) <-> GL (Gauss-Legendre) ---
            comp.qrSwitchLabel = uilabel(comp.GridLayout);
            comp.qrSwitchLabel.HorizontalAlignment = 'right';
            comp.qrSwitchLabel.Layout.Row = 8; comp.qrSwitchLabel.Layout.Column = 1;
            comp.qrSwitchLabel.Text = 'quad. rule';

            comp.qrSwitch = uiswitch(comp.GridLayout, 'slider');
            comp.qrSwitch.Items = {'CC','GL'};
            comp.qrSwitch.Value = 'CC';
            comp.qrSwitch.Tooltip = 'Clenshaw-Curtis (nests under refinement) vs Gauss-Legendre';
            comp.qrSwitch.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @qrSwitchValueChanged, true);
            comp.qrSwitch.Layout.Row = 8; comp.qrSwitch.Layout.Column = 2;

        end
    end

    methods (Static, Access = private)
        function y = wrapToPiLocal(x)
            % map an angle to (-pi, pi] without the Mapping Toolbox
            y = mod(x + pi, 2*pi) - pi;
        end
    end

end
