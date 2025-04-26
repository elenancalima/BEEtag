

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


%test401 = imread("ms_good_1.tif");

%test401 = imread("microFilm_inverted.png");
%test401 = imread("printRDC.tif");

%test401 = imread("driedRaw.tif");
%test401 = imread("laminated_c.png");
%test401 = imread("laminated_c_s.png");
%test401 = imread("pp_vn_dr_zi.tif");
%test401 = imread("piece1_dryRaw.tif");
%test401 = imread("piece1_glued.tif");
%test401 = imread("piece2_dryRaw.tif");
%test401 = imread("piece2_taped.tif");
%test401 = imread("piece3_dryRaw.tif");
%test401 = imread("piece3_filmed.tif");
%test401 = imread("cutTagsZ3.tif");
%test401 = imread("12min_glued.tif");
%test401 = imread("sup12reCut.tif");
%test401 = imread("bottomTagDebug.png");
test401 = imread("rightTagDebug.png");



% reference size is about 1000

%{
locateCodes(test401, 'threshMode',1, 'sizeThresh', 300, ...
    'bradleyFilterSize', [13 13], 'bradleyThreshold',0, ...
    'robustTrack', test401);
%}

%{
locateCodes(test401, 'threshMode',1, 'sizeThresh', [300, 2000], ...
    'bradleyFilterSize', [10 10; 11 11; 12 12; 13 13; 14 14; 15 15; 16 16; 17 17; 18 18; 19 19], ...
    'bradleyThreshold',4);
%}


%locateCodes(test401, 'threshMode',1, 'sizeThresh', [500, 2000], ...
%    'bradleyFilterSize', [9 9; 11 11; 13 13; 15 15; 17 17; 19 19; 21 21], ...
%    'bradleyThreshold',4);


%{
locateCodes(test401, 'threshMode',1, 'sizeThresh', [500, 2000], ...
    'bradleyFilterSize', [9 9; 13 13; 18 18; 24 24; 31 31; 39 39; ], ...
    'bradleyThreshold',4);
%}


%{
locateCodes(test401, 'threshMode',1, 'sizeThresh', [500, 2000], ...
    'bradleyFilterSize', [13 13], ...
    'bradleyThreshold',2, 'robustTrack', bradley(test401,[7 7], 0));
%}


%{
locateCodes(test401, 'threshMode',1, 'sizeThresh', [500, 2l000], ...
    'bradleyFilterSize', [15 15], ...
    'bradleyThreshold',2);
%}

%{
locateCodes(test401, 'threshMode',1, 'sizeThresh', [500, 2000], ...
    'bradleyFilterSize', [7 7; 8 8; 9 9; 13 13; 14 14; 15 15; 16 16], ...
    'bradleyThreshold', [1 3]);
%}

locateCodes(test401, 'threshMode',1, 'sizeThresh', [500, 2000], ...
    'bradleyFilterSize', [7 8; 8 7; 9 10; 10 9; 13 14; 14 13; 16 17; 17 16], ...
    'bradleyThreshold', [1 2 3 4]);