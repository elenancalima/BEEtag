% webcam test
cam = webcam('GENERAL - UVC');
cam.Resolution = '1280x720';
cam.Brightness = 49;
while(true)
    img = snapshot(cam);
    img = imresize(img, 0.75);
    Rwc = locateCodes(img, 'threshMode',1, 'colMode', 1, 'sizeThresh', [500, 2000], ...
        'bradleyFilterSize',[13 13; 15 15], ...
        'bradleyThreshold', [3 4]);
    %disp(Rwc);
end
