classdef MethodTab < matlab.ui.componentcontainer.ComponentContainer
    
    properties
        GridLayout                          matlab.ui.container.GridLayout
        ComputationalModeButtonGroup        GUI.GridLayoutButtonGroup
        MPLoewnerButton                     GUI.GridLayoutToggleButton
        SPLoewnerButton                     GUI.GridLayoutToggleButton
        HankelButton                        GUI.GridLayoutToggleButton
        %
        RankRuleGrid                        matlab.ui.container.GridLayout
        EstimateMCheckbox
        RankRuleDropDown
        EigSearchEditFieldLabel
        EigSearchEditField
        %
        MethodComponent                     GUI.Parameter.Method.MethodComponent
    end

    properties (Access = public)
        CIMData Numerics.CIM
    end

    properties (Access = private)
        listeners = []  % Store listener handles for cleanup
    end
    
    methods

        function obj = MethodTab(Parent,CIMData)

            obj@matlab.ui.componentcontainer.ComponentContainer(Parent)
            obj.CIMData = CIMData;

            obj.updateMethodParameters();

            obj.updateMethodComponent();

            obj.addListeners();

        end

        function updateMethodComponent(comp)
            switch(comp.CIMData.RealizationData.ComputationalMode)
                case Numerics.ComputationalMode.Hankel
                    comp.HankelButton.Value = true;
                case Numerics.ComputationalMode.SPLoewner
                    comp.SPLoewnerButton.Value = true;
                case Numerics.ComputationalMode.MPLoewner
                    comp.MPLoewnerButton.Value = true;
            end
            comp.MethodComponent = GUI.Parameter.Method.GenericMethodComponent(comp.GridLayout,comp.CIMData);
            comp.MethodComponent.Layout.Row = [1 5];
            comp.MethodComponent.Layout.Column = [3 5];
        end

        function addListeners(comp)
            % Store listener handles for cleanup
            comp.listeners = [
                GUI.SubObjectListener(comp.CIMData,"RealizationData",'ComputationalMode',@(src,event)comp.updateMethodParameters)
                GUI.SubObjectListener(comp.CIMData,"RealizationData",'RealizationSize',@(src,event)comp.updateMethodParameters)
                GUI.SubObjectListener(comp.CIMData,"RealizationData",'AutoRank',@(src,event)comp.updateMethodParameters)
                GUI.SubObjectListener(comp.CIMData,"RealizationData",'RankRule',@(src,event)comp.updateMethodParameters)
                GUI.SubObjectListener(comp.CIMData,"ResultData",'m',@(src,event)comp.updateMethodParameters)
            ];
        end

        function delete(comp)
            Visual.deleteListeners(comp.listeners);
        end

        function updateFontSize(comp,update)
            fontsize(comp.GridLayout.Children,update,"points");
            comp.ComputationalModeButtonGroup.updateFontSize(update);
            comp.MethodComponent.updateFontSize(update);
        end

        function ComputationalModeChangedFcn(comp,~)
            switch comp.ComputationalModeButtonGroup.SelectedObject.Text
                case "Hankel"
                    cm = Numerics.ComputationalMode.Hankel;
                case "SPLoewner"
                    cm = Numerics.ComputationalMode.SPLoewner;
                case "MPLoewner"
                    cm = Numerics.ComputationalMode.MPLoewner;
            end
            comp.CIMData.setComputationalMode(cm);
        end

    end

    methods % CIM -> GUI

        function updateMethodParameters(comp,~)
            % under AutoRank the field is read-only and shows the m chosen by the last compute;
            % only Value/Enable are set here, which never fire the ValueChangedFcn callbacks
            auto = comp.CIMData.RealizationData.AutoRank;
            comp.EstimateMCheckbox.Value = auto;
            comp.RankRuleDropDown.Value = comp.CIMData.RealizationData.RankRule;
            comp.RankRuleDropDown.Enable = auto;
            comp.EigSearchEditField.Enable = ~auto;
            if auto && ~isempty(comp.CIMData.ResultData.m)
                comp.EigSearchEditField.Value = comp.CIMData.ResultData.m;
            else
                comp.EigSearchEditField.Value = comp.CIMData.RealizationData.RealizationSize.m;
            end
            switch(comp.CIMData.RealizationData.ComputationalMode)
                case Numerics.ComputationalMode.Hankel
                    comp.HankelButton.Value = true;
                case Numerics.ComputationalMode.SPLoewner
                    comp.SPLoewnerButton.Value = true;
                case Numerics.ComputationalMode.MPLoewner
                    comp.MPLoewnerButton.Value = true;
            end
        end

    end

    methods % GUI -> CIM

        function MethodParametersChanged(comp,~)
            % the automatic m is never written into RealizationSize.m, so the manual m survives toggling
            if ~comp.CIMData.RealizationData.AutoRank
                comp.CIMData.RealizationData.RealizationSize.m = comp.EigSearchEditField.Value;
            end
            % computational mode is changed in separate callback
            % (buttongroup)
        end

        function AutoRankChanged(comp,~)
            % separate from the m field, which may still show the automatic m when this is unticked
            comp.CIMData.RealizationData.AutoRank = comp.EstimateMCheckbox.Value;
        end

        function RankRuleChanged(comp,~)
            comp.CIMData.RealizationData.RankRule = comp.RankRuleDropDown.Value;
        end

    end

    methods (Access = protected)

        function update(~)
            %TODO
        end

        function setup(comp)
            comp.GridLayout = uigridlayout(comp.Parent,[5,5]);
            comp.GridLayout.Padding = [10 10 10 10];
            %
            comp.ComputationalModeButtonGroup = GUI.GridLayoutButtonGroup(comp.GridLayout);
            comp.ComputationalModeButtonGroup.SelectionChangedFcn = matlab.apps.createCallbackFcn(comp, @ComputationalModeChangedFcn, true);
            comp.ComputationalModeButtonGroup.TitlePosition = 'centertop';
            comp.ComputationalModeButtonGroup.Title = 'Computational Mode';
            comp.ComputationalModeButtonGroup.Layout.Row = [1 5];
            comp.ComputationalModeButtonGroup.Layout.Column = 1;
            % %
            comp.HankelButton = comp.ComputationalModeButtonGroup.addButton('Hankel');
            % %
            comp.SPLoewnerButton = comp.ComputationalModeButtonGroup.addButton('SPLoewner');
            % %
            comp.MPLoewnerButton = comp.ComputationalModeButtonGroup.addButton('MPLoewner');
            %
            comp.EigSearchEditFieldLabel = uilabel(comp.GridLayout);
            comp.EigSearchEditFieldLabel.HorizontalAlignment = 'center';
            comp.EigSearchEditFieldLabel.Layout.Row = [1 2];
            comp.EigSearchEditFieldLabel.Layout.Column = 2;
            comp.EigSearchEditFieldLabel.Text = '# Eig Search';
            %
            % directly above the m field: the checkbox says whether m is chosen automatically, the dropdown by which rule
            comp.RankRuleGrid = uigridlayout(comp.GridLayout,[1,2]);
            comp.RankRuleGrid.ColumnWidth = {'fit','1x'};
            comp.RankRuleGrid.Padding = [0 0 0 0];
            comp.RankRuleGrid.ColumnSpacing = 5;
            comp.RankRuleGrid.Layout.Row = 3;
            comp.RankRuleGrid.Layout.Column = 2;
            % %
            comp.EstimateMCheckbox = uicheckbox(comp.RankRuleGrid);
            comp.EstimateMCheckbox.Text = 'Auto';
            comp.EstimateMCheckbox.Value = false;
            comp.EstimateMCheckbox.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @AutoRankChanged, true);
            comp.EstimateMCheckbox.Layout.Row = 1;
            comp.EstimateMCheckbox.Layout.Column = 1;
            % %
            comp.RankRuleDropDown = uidropdown(comp.RankRuleGrid);
            comp.RankRuleDropDown.Items = {'Largest Gap','Tolerance'};
            comp.RankRuleDropDown.ItemsData = {Numerics.RankRule.Gap, Numerics.RankRule.Tolerance};
            comp.RankRuleDropDown.Value = Numerics.RankRule.Gap;
            comp.RankRuleDropDown.Enable = false;
            comp.RankRuleDropDown.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @RankRuleChanged, true);
            comp.RankRuleDropDown.Layout.Row = 1;
            comp.RankRuleDropDown.Layout.Column = 2;
            %
            comp.EigSearchEditField = uieditfield(comp.GridLayout, 'numeric');
            comp.EigSearchEditField.Limits = [0 Inf];
            comp.EigSearchEditField.HorizontalAlignment = 'center';
            comp.EigSearchEditField.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @MethodParametersChanged, true);
            comp.EigSearchEditField.Value = 0;
            comp.EigSearchEditField.Layout.Row = [4 5];
            comp.EigSearchEditField.Layout.Column = 2;

        end

    end

end