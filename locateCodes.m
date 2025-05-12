function R = locateCodes(im, varargin)
%locates optical tags and spits out regionprops info for all tags
%
% Input form is locateCodes(im, varargin)
%
% Required input:
%
%'im' is an image containing tags, can be rgb or grayscale - currently not
%supported to directly input
%
%
% Optional inputs include:
%
%'colMode' - determines whether to show gray (1)  or bw (0) image, 2 is
%   rgb, anything else (i.e. 3) plots on whatever background is already plotted
%
%'thresh' - thresholding value to turn grayscale into a binary image,
%   ranges from 0 to 1, default is to calculate threshold value automatically
%
%'vis' - whether or not to visualize results, 0 being no visualization, 1
%   being visualization. Default is visualization
%
%'sizeThresh' - one element vector sets the mimimum size threshold, two
%   element vector sets the minimum and maximum size threshold. Only really
%   helps to clean out noise - start with a low number at first!
%   Default is a minimum threshold of 100
%
%'robustTrack' - whether or not to identify binary values for tracking codes
%   from black and white binary image, or to track over a range of values from
%   an original grayscale image with intelligent thresholding. The latter
%   produces more false positives, and it is recommended to only use this in
%   conjunction with a pre-specificed list of tags for tracking. Adding size
%   restrictions on valied tags is also recommended. When using this option,
%   you must specify a grayscale image to take the pixel values from (can
%   be the same as 'im');
%
%'tagList'- option to add list of pre-specified valid tags to track. The
%   taglist should be a vector of tag numbers that are actually in im.
%   Output from any other tags found in the picture is ignored
%
%'threshMode' - options for black-white thresholding. Default is 0, which
%   uses supplied threshold and above techniques. Alternative option is
%   Bradley local adaptive thresholding, which helps account for local
%   variation in illumination within the image.
%
% 'bradleyFilterSize' - two element vector defining the X and Y
%   (respectively) size of locally adaptive filter. Only supply when
%   'threshMode' is 1 (using adaptive thresholding).
%
% 'bradleyThreshold' - black-white threshold value after local filtering.
%   Default value is 3, lower values produce darker images, and vice versa.
%
%
%
% Outputs are:
% Area: area of tag in pixel:
%
% Centroid: X and Y coordinates of tag center
%
% Bounding Box: Boundig region of image containing tag
%
% corners: Coordinates of four calculated corner points of tag
%
% code: 25 bit binary code read from tag
%
% number: original identification number of tag
%
% frontX: X coordiante (in pixels) of tag "front"
%
% frontY: Y coordinate (in pixels) of tag "front"
%

%% Extract optional inputs, do initial image conversion, and display thresholded value

%Check for manually supplied 'vis' value
v = strcmp('vis', varargin);

if sum(v) == 0
    vis = 1;
else
    vis = cell2mat(varargin(find(v == 1) + 1));
end


%Check for manually supplied 'colMode' argument
colM = strcmp('colMode', varargin);

if sum(colM) == 0
    colMode = 0;
else
    colMode = cell2mat(varargin(find(colM == 1) + 1));
end


%tag size threshold value
tagTh = strcmp('sizeThresh', varargin);

if sum(tagTh) == 0
    sizeThresh = 100;
else
    sizeThresh = cell2mat(varargin(find(tagTh == 1) + 1));
end


% threshMode value
threshM = strcmp('threshMode', varargin);

if sum(threshM) == 0
    threshMode = 0;
else
    threshMode = cell2mat(varargin(find(threshM == 1) + 1));
end


% If using adaptive thresholding, define filter size
bradleyP = strcmp('bradleyFilterSize', varargin);

if sum(bradleyP) == 0
    smP = [15 15];
else
    smP = cell2mat(varargin(find(bradleyP == 1) + 1));
end

%disp(smP);


% If using adaptive thresholding, define threshold value
bradleyT = strcmp('bradleyThreshold', varargin);
if sum(bradleyT) == 0
    brT = 3;
else
    brT = cell2mat(varargin(find(bradleyT == 1) + 1));
end


% Convert image to grayscale if RGB
if ndims(im) > 2
    GRAY = rgb2gray(im);
elseif ndims(im) == 2
    GRAY = im;
end


%Check for manually supplied threshold value
th = strcmp('thresh', varargin);

if sum(th) == 0
    thresh=graythresh(GRAY);
else
    thresh = cell2mat(varargin(find(th == 1) + 1));
end


%Do B-W conversion
if threshMode == 0
    BW=im2bw(GRAY, thresh);
elseif threshMode  == 1
    nrowSMP = size(smP,1);
    ncolT = size(brT,2);
    %disp(nrowSMP);
    %disp(size(brT,2));
    BW = bradley(GRAY, smP(1,:), brT(1,1));
    if nrowSMP * ncolT > 1
        altBW = cell(nrowSMP * ncolT - 1,1);
        for smpIdx = 2:(nrowSMP * ncolT)
            %disp(mod(smpIdx,nrowSMP));
            %disp(brT(ceil(smpIdx/nrowSMP)));
            altBW{smpIdx - 1} = bradley(GRAY, smP(1 + mod(smpIdx - 1,nrowSMP),:), brT(1,ceil(smpIdx/nrowSMP)));
        end
        %disp(altBW);
    end
end


%Display requested image
if colMode == 1 && vis == 1
    imshow(GRAY);
end

if colMode == 0 && vis== 1
    imshow(BW);
end

if colMode == 2 && vis == 1
    imshow(im);
end


% Define tracking mode
trackM = strcmp('robustTrack', varargin);

if sum(trackM) == 0
    trackMode = 0;
    imo = 0;
else
    trackMode = 1;
    imo = cell2mat(varargin(find(trackM == 1) + 1));
end


% Define optional list of valid codes
listM = strcmp('tagList', varargin);

if sum(listM) == 0
    listMode = 0;
    validTagList = [];
else
    listMode = 1;
    validTagList = cell2mat(varargin(find(listM == 1) + 1));
end


%Marker size for green points on potential tag corners
cornerSize = 10;

sizeThreshDef = [200 3000];

if numel(sizeThresh) == 1 %If one element is input for sizeThresh, replace minimum

    sizeThreshDef(1) = sizeThresh;

elseif numel(sizeThresh) == 2 %If input for sizeThresh has two values, replace min and max

    sizeThreshDef = sizeThresh;

end

%% Find contiguous white regions

R = findCodes(BW, sizeThreshDef, vis, cornerSize, trackMode, validTagList, imo, varargin);

%disp('R before');
%disp(R);
if nrowSMP * ncolT > 1
    altR = cell((nrowSMP * ncolT) - 1,1);
    for smpIdx = 1:(nrowSMP * ncolT - 1)
        %disp('addingR');
        %disp(smpIdx);
        %imshow(altBW{smpIdx,1});
        %dummy=input('check image');
        tempR = findCodes(altBW{smpIdx,1}, sizeThreshDef, vis, cornerSize, trackMode, validTagList, imo, varargin);
        %disp(tempR);
        altR{smpIdx,1} = findCodes(altBW{smpIdx,1}, sizeThreshDef, vis, cornerSize, trackMode, validTagList, imo, varargin);
        %disp(altR{smpIdx,1});
    end
    %disp(altR);
end


    if nrowSMP * ncolT > 1
        %disp(altR);
        for smpIdx = 1:(nrowSMP * ncolT - 1)
            %visualizeCodes(altR{smpIdx,1}, cornerSize);
            %disp("R");
            %disp(R);
            %disp(size(R));
            %disp("altR");
            %disp(altR{smpIdx,1});
            %disp(size(altR{smpIdx,1}));
            if size(R,1) > 0
                if size(altR{smpIdx,1},1) > 0
                    R = [R ; altR{smpIdx,1}];
                end
            else
                R = altR{smpIdx,1};
            end
        end
    end

    
%% Optional code visualization



if vis==1
    %disp(R);
    visualizeCodes(R, cornerSize);


end

if isfield(R, 'passCode')
    R = rmfield(R, {'FilledImage', 'isQuad', 'passCode', 'orientation'});
end
%R = rmfield(R, {'FilledImage', 'isQuad', 'orientation'});


Rnumber = [];
for rIdx = 1:size(R,1)
    %disp(R(rIdx,1).number);
    Rnumber = [Rnumber R(rIdx,1).number];
end
%disp("Rnumber");
%disp(Rnumber == 12740);
disp(Rnumber);



hold off;
%%