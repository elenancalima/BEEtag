function trackAntsInVideo(output_name_prefix)

%% --- 1. Initialization and File Selection ---
disp('--- Step 1: Initializing ---');
codelist = []; % This can be pre-populated if desired

[filename, pathname] = uigetfile('*'); % User selects the video file
if isequal(filename, 0) || isequal(pathname, 0)
    disp('User canceled file selection. Aborting.');
    return;
end

mov = VideoReader([pathname, filename]);
nframes = mov.NumberOfFrames;
trackingData = struct();

%% --- 2. Frame-by-Frame Tracking ---
disp('--- Step 2: Tracking tags in each frame ---');
for i = 1:nframes
    disp(['Tracking frame ', num2str(i), ' of ', num2str(nframes)]);
    im = read(mov, i);
    
    % The core tracking function with hardcoded parameters
    F = locateCodes(im, 'sizeThresh', [500, 2000], 'threshMode', 1, ...
        'bradleyFilterSize', [7 8; 8 7; 13 13], ...
        'bradleyThreshold', [1 2]);
        
    trackingData(i).F = F;
end

%% --- 3. Discover All Unique Tag Codes ---
disp('--- Step 3: Discovering all unique tags ---');
allNumbers = [];
for i = 1:nframes
    R = trackingData(i).F;
    Rnumber = [];
    if ~isempty(R)
        Rnumber = [R.number];
    end
    allNumbers = [allNumbers, Rnumber];
end
codeVisList = unique(allNumbers);

if isempty(codelist)
    codelist = codeVisList;
end

%% --- 4. Reshape Data into a "Per-Tag" Format ---
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
disp('--- Step 5: Saving data files ---');
matFileName = [output_name_prefix, '_trackingData.mat'];
save(matFileName, 'trackingDataReshaped');
disp(['Saved reshaped tracking data to: ', matFileName]);

TD = trackingDataReshaped;
for sID = 1:numel(TD)
    xmlFileName = sprintf('%s_tagData_%d.xml', output_name_prefix, TD(sID).number(find(~isnan(TD(sID).number), 1)));
    if isfield(TD(sID), 'CentroidX') % Check if the struct is not empty
        writestruct(TD(sID), xmlFileName);
    end
end
disp(['Saved individual tag data to XML files with prefix: ', output_name_prefix]);

%% --- 6. Replay Video with Tracking Overlay ---
disp('--- Step 6: Generating annotated video replay ---');
outputMovieName = [output_name_prefix, '_trackingMovie.avi'];
outputMovie = 1; % Set to 1 to save the movie, 0 to just display

if outputMovie
    vidObj = VideoWriter(outputMovieName);
    open(vidObj);
end

figure; % Create a new figure for the replay
for i = 1:nframes
    im = read(mov, i);
    imshow(im);
    hold on;
    
    for j = 1:numel(TD)
        if isfield(TD(j), 'CentroidX') && numel(TD(j).CentroidX) >= i && TD(j).CentroidX(i) ~= 0
            try
                plot([TD(j).CentroidX(i), TD(j).FrontX(i)], [TD(j).CentroidY(i), TD(j).FrontY(i)], 'b-', 'LineWidth', 3);
                text(TD(j).CentroidX(i), TD(j).CentroidY(i), num2str(TD(j).number(i)), 'FontSize', 25, 'Color', 'r');
            catch
                % Continue if there's an error plotting a single frame/tag
            end
        end
    end
    
    drawnow;
    
    if outputMovie
        currFrame = getframe(gcf);
        writeVideo(vidObj, currFrame);
    end
    
    hold off;
end

if outputMovie
    close(vidObj);
    disp(['Saved annotated movie to: ', outputMovieName]);
end

disp('--- Processing complete. ---');
end