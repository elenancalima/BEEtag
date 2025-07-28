%% Beta/example code to track beetags across all frames of a video

codelist = [];
%codelist = [9557 9170 8016 6893 13235 12740];
%codelist = [109 36]; %List of codes in the frame - supplying this is more robust, but optional

[filename pathname] = uigetfile('*'); %User-specified file input - this can be modified to be automated if you need to track over lots of files
mov = VideoReader([pathname filename]); %Make a VideoReader object for the movie

nframes = mov.NumberOfFrames; %how many frames are in the video?

%nframes = 20; %debug

%Create empty frame for tracking output
trackingData = struct();

%% Loop across frames
for i = 1:nframes

    %% Read in each frames and track codes in it
    disp(strcat('tracking frame_', num2str(i), '_of_', num2str(nframes)));
    im = read(mov, i);

    %Two example options for tracking in each frame (oRnly comment in one at a time):

    %example 1, maybe a little more robust but slower

    %imr = bradley(rgb2gray(im), [6 6], 3);
    F = locateCodes(im, 'sizeThresh', [500, 2000], 'threshMode', 1, ...
        'bradleyFilterSize', [15 15], ...
        'bradleyThreshold', [3], ...
        'robustTrack', 2); % made trackMode 2 to accept all white Squares
    %F = locateCodes(im, 'sizeThresh', [500, 2000], 'threshMode', 1, ...
    %    'bradleyFilterSize', [7 8; 8 7; 13 13], ...
    %    'bradleyThreshold', [1 2], 'tagList', codelist, 'permissiveMode', 2);
    %F = locateCodes(im, 'robustTrack', im, 'sizeThresh', [500, 2000], 'threshMode', 1, 'bradleyFilterSize', [6 6; 7 7; 8 8; 13 13; 14 14; 15 15; 39 39], 'bradleyThreshold', 2);

    %example option 2, faster, simpler - just uses a simple threshold value instead
    %of doing adaptive filtering, less good for inhomogenously lit images

    %F = locateCodes(im, 'thresh', 0.25);

    %Append this single frame data to the master tracking output



    trackingData(i).F = F;


    encoded = jsonencode(F);
    fName = sprintf('frameStruct_%05d.json',i);
    fid = fopen(fName,'w');
    fprintf(fid,'%s',encoded);
    fclose(fid);

end

%%% omitted later parts corresponding to  trackVideo_postDataProcessing.m