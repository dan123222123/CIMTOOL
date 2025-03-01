function Nbode(w,varargin)
    if isempty(w)
        w = logspace(-6,6,5000);
    end
    for i=1:length(varargin)
        nbode(varargin{i},w); hold on;
    end
    hold off; %linestyleorder(gca,"mixedstyles");
end
