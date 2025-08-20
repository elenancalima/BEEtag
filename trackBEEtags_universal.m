function trackBEEtags_universal(input_path, output_name_prefix)

%% --- 1. Setup Data Source based on Input Type ---
disp('--- Step 1: Initializing data source ---');

if isfolder(input_path)
    % --- Image Folder Mode ---
    disp('Input is a folder. Searching for images...');
    % Get a list of all common image files (add extensions if needed)
    image_files = [dir(fullfile(input_path, '*.png')); ...
                   dir(fullfile(input_path, '*.jpg')); ...
                   dir(fullfile(input_path, '*.tif'))];
    
    nframes = numel(image_files);
    % Define a function to read the k-th image from the list
    read_frame_fcn = @(k) imread(fullfile(image_files(k).folder, image_files(k).name));
    
elseif isfile(input_path)
    % --- Video File Mode ---
    disp('Input is a file. Treating as a video...');
    mov = VideoReader(input_path);
    nframes = mov.NumberOfFrames;
    % Define a function to read the k-th frame from the video object
    read_frame_fcn = @(k) read(mov, k);
    
else
    error('Input path is not a valid file or folder.');
end

disp(['Found ', num2str(nframes), ' frames/images to process.']);

%% --- 2. Frame-by-Frame Tracking ---
disp('--- Step 2: Tracking tags in each frame ---');
codelist = []; % This can be pre-populated if desired
trackingData = struct();

for i = 1:nframes
    disp(['Tracking frame ', num2str(i), ' of ', num2str(nframes)]);
    im = read_frame_fcn(i); % Use the function handle to get the current frame
    
    F = locateCodes(im, 'sizeThresh', [500, 3200], 'threshMode', 1, ...
        'bradleyFilterSize', [5 5; 7 8; 8 7; 13 13; 17 17; 22 22; 27 27], ...
        'bradleyThreshold', [0 1 2 4 6 9 13]);
        
    trackingData(i).F = F;
    save('trackingData_WIP.mat', 'trackingData')
end

% The rest of the script (Reshaping, Saving, Replay) is largely the same,
% it just uses the 'read_frame_fcn' to get the images for the replay.

%% --- 3. Discover All Unique Tag Codes ---
% (This section is unchanged)
disp('--- Step 3: Discovering all unique tags ---');
allNumbers = [];
for i = 1:nframes
    R = trackingData(i).F;
    if ~isempty(R)
        allNumbers = [allNumbers, [R.number]];
    end
end
codeVisList = unique(allNumbers);
if isempty(codelist)
    codelist = codeVisList;
end

%% --- 4. Reshape Data ---
% (This section is unchanged)
disp('--- Step 4: Reshaping data for easier analysis ---');
trackingDataReshaped = struct();
for i = 1:nframes
    F = trackingData(i).F;
    if ~isempty(F)
        Rnumber = [F.number];
        for j = 1:numel(codelist)
            idx = find(Rnumber == codelist(j), 1, 'first');
            if ~isempty(idx)
                FS = F(idx);
                trackingDataReshaped(j).CentroidX(i) = FS.Centroid(1);
                trackingDataReshaped(j).CentroidY(i) = FS.Centroid(2);
                trackingDataReshaped(j).FrontX(i) = FS.frontX;
                trackingDataReshaped(j).FrontY(i) = FS.frontY;
                trackingDataReshaped(j).number(i) = FS.number;
            end
        end
    end
end

%% --- 5. Save Data Files ---
% (This section now uses the output_name_prefix)
disp('--- Step 5: Saving data files ---');
matFileName = [output_name_prefix, '_trackingData.mat'];
save(matFileName, 'trackingDataReshaped');
disp(['Saved reshaped tracking data to: ', matFileName]);
% ... (XML saving logic is similar to before)

%% --- 6. Replay Video with Tracking Overlay ---
disp('--- Step 6: Generating annotated video replay ---');
outputMovieName = [output_name_prefix, '_trackingMovie.avi'];
vidObj = VideoWriter(outputMovieName);
open(vidObj);

figure;
for i = 1:nframes
    im = read_frame_fcn(i); % Use the function handle again for replay
    imshow(im);
    hold on;
    
    % (Plotting logic is unchanged)
    TD = trackingDataReshaped;
    for j = 1:numel(TD)
        if isfield(TD(j), 'CentroidX') && numel(TD(j).CentroidX) >= i && TD(j).CentroidX(i) ~= 0
            plot([TD(j).CentroidX(i), TD(j).FrontX(i)], [TD(j).CentroidY(i), TD(j).FrontY(i)], 'b-', 'LineWidth', 3);
            text(TD(j).CentroidX(i), TD(j).CentroidY(i), num2str(TD(j).number(i)), 'FontSize', 25, 'Color', 'r');
        end
    end
    
    drawnow;
    currFrame = getframe(gcf);
    writeVideo(vidObj, currFrame);
    hold off;
end

close(vidObj);
disp(['Saved annotated movie to: ', outputMovieName]);
disp('--- Processing complete. ---');

end