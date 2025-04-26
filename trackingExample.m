%Example to locate and identify visual barcodes within a picture
%Remember to add folder with code to your matlab path

%Read in example file
%im = imread('scaleExample.png');
%im = imread('scaleExample_B.png');
%im = imread('1000005978i.png');
im = imread('deconvolve.png');
figure(1); 
subplot(1,2,1);
imshow(im);
title('Original image 1');

%Locate codes using the default values
subplot(1,2,2);
codes = locateCodes(im, 'threshMode', 1, 'sizeThresh', 300, 'bradleyFilterSize', [20 20], 'bradleyThreshold',-3);
disp(codes);
title('Tracked image 1');


%look at 'help locateCodes' to figure out what these 
%parameters are - most important for functionality is the thresholding
%mode/value, other stuff is just useful visualizing for error-checking,
%etc.

%The id number will show up in the picture in red if vis==1, otherwise it
%will show up in the codes structure (i.e. type 'codes.number')
