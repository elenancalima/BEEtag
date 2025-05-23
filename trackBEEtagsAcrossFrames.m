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

    %Two example options for tracking in each frame (only comment in one at a time):

    %example 1, maybe a little more robust but slower

    %imr = bradley(rgb2gray(im), [6 6], 3);
    F = locateCodes(im, 'sizeThresh', [500, 2000], 'threshMode', 1, ...
        'bradleyFilterSize', [7 8; 8 7; 13 13], ...
        'bradleyThreshold', [1 2]);
    %F = locateCodes(im, 'sizeThresh', [500, 2000], 'threshMode', 1, ...
    %    'bradleyFilterSize', [7 8; 8 7; 13 13], ...
    %    'bradleyThreshold', [1 2], 'tagList', codelist, 'permissiveMode', 2);
    %F = locateCodes(im, 'robustTrack', im, 'sizeThresh', [500, 2000], 'threshMode', 1, 'bradleyFilterSize', [6 6; 7 7; 8 8; 13 13; 14 14; 15 15; 39 39], 'bradleyThreshold', 2);

    %example option 2, faster, simpler - just uses a simple threshold value instead
    %of doing adaptive filtering, less good for inhomogenously lit images

    %F = locateCodes(im, 'thresh', 0.25);

    %Append this single frame data to the master tracking output
    trackingData(i).F = F;

end


for i = 1:nframes
    %for i = 1:numel(trackingData)
    %disp(trackingData(i).F);
    R = trackingData(i).F;
    Rnumber = [];
    for rIdx = 1:size(R,1)
        %disp(R(rIdx,1).number);
        Rnumber = [Rnumber R(rIdx,1).number];
    end


    curNumbers = [Rnumber];
    %%
    if i == 1
        allNumbers = [] ;
    else
        allNumbers = [allNumbers curNumbers];
    end
    codeVisList = unique(allNumbers);
    %disp(codelist);
end

%% if there's no 'codelist' object defined, extract it from all the unique codes tracked in the movie
if size(codelist,2) < 1
    codeList = codeVisList;
end
%%
disp(codeVisList);
disp('rearranging data into easier format');
trackingDataReshaped = struct();
for i = 1:nframes
    %%
    F = trackingData(i).F;
    R = F;
    Rnumber = [];
    for rIdx = 1:size(R,1)
        %disp(R(rIdx,1).number);
        Rnumber = [Rnumber R(rIdx,1).number];
    end

    for j = 1:numel(codelist)
        %%
        if ~isempty(F)
            FS = F(Rnumber == codelist(j));
            %disp("FSsize")
            %disp(size(FS));
            if(size(FS,1) > 1)
                FS = FS(1,1);
            end
            %FS = FS(1,1);
            if ~isempty(FS)
                %disp("FS");
                %disp(FS);
                %disp("FS1.Centroid");
                %disp(FS(1).Centroid);
                trackingDataReshaped(j).CentroidX(i) = FS.Centroid(1);
                trackingDataReshaped(j).CentroidY(i) = FS.Centroid(2);
                trackingDataReshaped(j).FrontX(i) = FS.frontX;
                trackingDataReshaped(j).FrontY(i) = FS.frontY;
                trackingDataReshaped(j).number(i) = FS.number;
            end
        end
    end

end


%% Save data
save('trackingData.mat', 'trackingDataReshaped')

%% Replay video
disp('replaying video with tracking data shown');
TD = trackingDataReshaped;

outputMovieName = 'ExampleTrackingMovie.avi';
outputMovie = 0; %Set to 1 if you want to save a movie, set to 0 if not

%If we're in movie writing mode, output the video
if outputMovie == 0
    vidObj = VideoWriter(outputMovieName);
    open(vidObj)
end

for i = 1:nframes
    %%
    im =  read(mov, i);
    imshow(im);
    hold on;
    for j = 1:numel(TD)
        if isfield(TD(j),"CentroidX")
            if numel(TD(j).CentroidX) >= i & ~isempty(TD(j).CentroidX(i))
                try
                    plot([TD(j).CentroidX(i) TD(j).FrontX(i)], [TD(j).CentroidY(i) TD(j).FrontY(i)], 'b-','LineWidth', 3);
                    text(TD(j).CentroidX(i), TD(j).CentroidY(i), num2str(TD(j).number(i)),'FontSize', 25, 'Color', 'r');
                catch
                    continue
                end
            end
        end
    end
    drawnow
    currFrame = getframe;
    writeVideo(vidObj, currFrame);
    hold off;
end

close(vidObj);

for sID = 1:size(TD,2)
    writestruct(TD(1,sID),sprintf('structTest_%03d.xml',sID));
end