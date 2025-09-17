function parallel_track(image_folder_path, output_prefix, bFilterBounds, bThresholdBounds)
% parallel_track(image_folder_path, output_prefix, [fmin fmax], [tmin tmax])
% Runs trackBEEtags_universal over the integer grid:
%   n = fmin:fmax (passed as [n n])
%   t = tmin:tmax
% Each combo runs in PARFOR and should save to a unique .mat inside
% trackBEEtags_universal (e.g., using sprintf in the callee).

    %--- expand bounds to integer vectors (also accepts explicit value lists) ---
    fVals = expandInts(bFilterBounds);
    tVals = expandInts(bThresholdBounds);

    % Grid of combinations (column vectors)
    [F,T] = ndgrid(fVals, tVals);
    F = F(:);  T = T(:);
    N = numel(F);

    % Start a pool if needed (local defaults)
    if isempty(gcp('nocreate')); parpool; end

    % Parallel sweep
    parfor k = 1:N
        n = F(k);
        t = T(k);
        try
            trackBEEtags_universal(image_folder_path, output_prefix, [n n], t);
        catch ME
            % Keep the pool running even if one combo fails
            warning('track failed for n=%d, t=%d: %s', n, t, ME.message);
        end
    end
end