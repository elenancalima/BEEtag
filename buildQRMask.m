function [roiMaskFull, boxesFull, roiMaskLow, s] = buildQRMask(I, approxCodeSize, minFeature)
% Build a binary ROI mask highlighting QR-like regions.
% I: grayscale or RGB image (double/single/uint*)
% approxCodeSize: ~50 (pixels, full-res)
% minFeature: ~5-6 (smallest module width in pixels, full-res)
%
% Returns:
%   roiMaskFull : logical mask same size as I (true = candidate ROI)
%   boxesFull   : Nx4 bounding boxes [x y w h] in full-res coordinates
%   roiMaskLow  : low-res mask (debug/inspection)
%   s           : scale factor used (low-res / full-res)

if nargin < 2 || isempty(approxCodeSize), approxCodeSize = 50; end
if nargin < 3 || isempty(minFeature),     minFeature     = 6;  end

% --- 0) Grayscale + normalize to [0,1]
if ndims(I) == 3, I = rgb2gray(I); end
I = im2single(I);
I = mat2gray(I);

% --- 1) Choose downscale so min feature -> ~3 px (clamped for stability)
targetFeat = 2;                         % aim for 3 px at low-res
s = max(0.25, min(0.7, targetFeat / max(minFeature,1)));  % e.g., 0.5~0.6 for 5-6 px

% Anti-aliased downsample (box filter is fast & stable)
Ilow = imresize(I, s, 'box');

% --- 2) High-pass / “detail energy”
% (a) Difference-from-blur (fast high-pass)
HP = abs(Ilow - imgaussfilt(Ilow, 2.0));
% (b) Gradient magnitude (edges)
%[Gx, Gy] = imgradientxy(Ilow, 'sobel');
%Gmag = hypot(Gx, Gy);

% Combine and smooth a bit
Resp = mat2gray(HP); %+ 0.4*mat2gray(Gmag);
Resp = imgaussfilt(Resp, 1.0);

% --- 3) Threshold + morphology
%T = graythresh(Resp);              % Otsu on low-res response
BW = Resp > 0.1;


% --- 6) Pad ROI a bit (so downstream ops see full codes)
pad = max(1, round(0.15 * approxCodeSize * s));   % ~15% padding at low-res
BW = imdilate(BW, strel('square', 2*pad+1));

roiMaskLow  = BW;

% --- 7) Upsample mask back to full size (nearest to keep binary)
roiMaskFull = imresize(roiMaskLow, size(I), 'nearest');

% --- 8) Full-res bounding boxes (scaled up)
Rlow  = regionprops(roiMaskLow, 'BoundingBox');
boxesFull = zeros(numel(Rlow), 4, 'single');
for k = 1:numel(Rlow)
    bb = Rlow(k).BoundingBox;
    boxesFull(k,:) = single([bb(1:2)/s, bb(3:4)/s]);  % scale positions + sizes
end
end
