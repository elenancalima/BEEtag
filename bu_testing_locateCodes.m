

%%test321 = imread("Z:\Images_captured_backup\IMAGING\F\image_files_that_will_get_Backedup_on_Synology\Sean\blackfly_setup\test_7\_1\Default\img_channel000_position000_time000000000_z000.tif");

%{
test322 = imread("deadTags.tif");
test323 = imread("deadTags_cropped.png");
test324 = imread("deadTags_cropped_upsized.png");
test325 = imread("uncutTags.tif");

test326 = imread("uncut_good_1.tif");
test327 = imread("uncut_good_2.tif");
test328 = imread("uncut_good_3.tif");
test329 = imread("uncut_good_4.tif");
test330 = imread("uncut_good_4_res.tif");
%}


test401 = imread("x1.4.tif");

%{
locateCodes(test401, 'threshMode',1, 'sizeThresh', 300, ...
    'bradleyFilterSize', [13 13], 'bradleyThreshold',0, ...
    'robustTrack', test401);
%}

locateCodes(test401, 'threshMode',1, 'sizeThresh', 300, ...
    'bradleyFilterSize', [15 15], 'bradleyThreshold',4);


result = locateCodes(test401, 'threshMode',1, 'sizeThresh', 300, ...
    'bradleyFilterSize', [15 15], 'bradleyThreshold',2);


result2 = locateCodes(test401, 'threshMode',1, 'sizeThresh', 300, ...
    'bradleyFilterSize', [14 14], 'bradleyThreshold',2);

%disp(result);
%disp(result2);
cr = cat(1,result,result2);
%disp(cr);

[~, idx] = unique([cr.frontX].', 'rows', 'stable');
%disp(cr(idx));
cr = cr(idx);

%disp(unique(cat(1,result,result2), 'rows'));




%Display requested image
imshow(test401);


cornerSize = 10;
for i = 1:numel(cr)
    corners = cr(i).corners;
    cornersP = [corners(2,:) ;corners(1,:)];
    text(cr(i).Centroid(1), cr(i).Centroid(2), num2str(cr(i).number), 'FontSize',30, 'color','r');
    hold on
    for bb = 1:4
        plot(cornersP(1,bb), cornersP(2,bb),'g.', 'MarkerSize', cornerSize)
    end

    plot(cr(i).frontX, cr(i).frontY, 'b.', 'MarkerSize', cornerSize);
end

hold off;




%% [~, idx] = unique([a.fit].', 'rows', 'stable');  %stable optional if you don't care about the order.
%% a = a(idx)




%%locateCodes(test401, 'threshMode',1, 'sizeThresh', 1500, 'bradleyFilterSize', [15 15], 'bradleyThreshold',0);
%%locateCodes(test330, 'threshMode',0, 'sizeThresh', 1500, 'thresh', 0.65);

%%result = locateCodes(test401, 'threshMode',1, 'sizeThresh', 300, 'bradleyFilterSize', [20 20], 'bradleyThreshold',2);
%%disp(result);


