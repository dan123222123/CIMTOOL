function [Ql,Qr,Qlr] = samplequadrature_progress(T,L,R,z,sample_mode)

if sample_mode == Numerics.SampleMode.Direct
    sample_function = @sample_T;
elseif sample_mode == Numerics.SampleMode.Inverse
    sample_function = @sample_Ti;
end


% BEGIN NUMERICS
N = length(z); f(1:N) = parallel.FevalFuture;
% start function evaluations

h = waitbar(0, 'Sampling Quadrature Data...', 'CreateCancelBtn', ...
                   @(src, event) setappdata(gcbf(), 'Cancelled', true));
setappdata(h, 'Cancelled', false); h.UserData = [0 N];
% start all futures
for i=1:N
    f(i) = parfeval(backgroundPool,sample_function,1,T(z(i)),L,R);
end
afterEach(f,@(~)updateWaitbar(h),0); afterAll(f,@(~)delete(h),0);
% % update progress bar until cancelled or done
% while mean({f.State} == "finished") < 1
%     if getappdata(h, 'Cancelled')
%         cancel(f); delete(h);
%         error("Canceled Quadrature Sampling...");
%     end
%     disp(mean({f.State} == "finished")); drawnow('update');
%     waitbar(mean({f.State} == "finished"),h);
% end
% delete(h);
s = fetchOutputs(f); Ql = cat(3,s.Ql); Qr = cat(3,s.Qr); Qlr = cat(3,s.Qlr);
% END NUMERICS
end

function s = sample_Ti(Tz,L,R)
    Ql = L' / Tz; Qr = Tz \ R; Qlr = L' * Qr;
    s.Ql = Ql; s.Qr = Qr; s.Qlr = Qlr;
end

function s = sample_T(Tz,L,R)
    Ql = L'*Tz; Qr = Tz*R; Qlr = L'*Qr;
    s.Ql = Ql; s.Qr = Qr; s.Qlr = Qlr;
end

function updateWaitbar(h)
    % Update a waitbar using the UserData property.

    % Check if the waitbar is a reference to a deleted object
    if isvalid(h)
        % Increment the number of completed iterations 
        h.UserData(1) = h.UserData(1) + 1;

        % Calculate the progress
        progress = h.UserData(1) / h.UserData(2);

        % Update the waitbar
        waitbar(progress,h);

        drawnow;
    end
end