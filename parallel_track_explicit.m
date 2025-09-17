function parallel_track_explicit(image_folder_path, output_prefix, combos)
% parallel_track_explicit(image_folder_path, output_prefix, combos)
% combos: N×2 matrix where each row is [n t].
% Runs trackBEEtags_universal(image_folder_path, output_prefix, [n n], t)
% for each row in PARFOR.

    % Start a pool if needed (local defaults)
    if isempty(gcp('nocreate')); parpool; end

    N = size(combos, 1);

    parfor k = 1:N
        n = combos(k, 1);
        t = combos(k, 2);
        try
            trackBEEtags_universal(image_folder_path, output_prefix, [n n], t);
        catch ME
            warning('track failed for row %d (n=%g, t=%g): %s', k, n, t, ME.message);
        end
    end
end
