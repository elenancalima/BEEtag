

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


%[filename pathname] = uigetfile('*'); %User-specified file input - this can be modified to be automated if you need to track over lots of files
%mov = VideoReader([pathname filename]); %Make a VideoReader object for the movie
%test401 = read(mov, 19);

test401 = imread("Z:\Images_captured_backup\IMAGING\F\image_files_that_will_get_Backedup_on_Synology\Woncheol\Main_HOI_test\Starv1D_gR0019_acclimation\2025_06_09_test_1\betterChoice.png");

R1 = locateCodes(test401, 'threshMode',1, 'vis', 0, 'sizeThresh', [500, 2000], ...
    'bradleyFilterSize',[21 21], ...
        'bradleyThreshold', [2 3 4 5 6 7]);

R2 = locateCodes(test401, 'threshMode',1, 'vis', 0, 'sizeThresh', [500, 2000], ...
    'bradleyFilterSize',[11 11; 13 13; 15 15; 17 17; 19 19], ...
        'bradleyThreshold', [7]);

R3 = locateCodes(test401, 'threshMode',1, 'vis', 0, 'sizeThresh', [500, 2000], ...
    'bradleyFilterSize',[11 11;], ...
        'bradleyThreshold', [2 3 4 5 6]);

R4 = locateCodes(test401, 'threshMode',1, 'vis', 0, 'sizeThresh', [500, 2000], ...
    'bradleyFilterSize',[13 13; 15 15; 17 17; 19 19], ...
        'bradleyThreshold', [2]);

R5 = locateCodes(test401, 'threshMode',1, 'colMode', 1, 'sizeThresh', [500, 2000], ...
    'bradleyFilterSize',[14 14; 15 15; 16 16], ...
        'bradleyThreshold', [3 4]);


Rall = [R1; R2; R3; R4; R5];
Rall = [R1; R2; R4; R5];
Rnumber = [];
for idx=1:size(Rall,1)
    Rnumber = [Rnumber Rall(idx).number];
end

disp(unique(Rnumber));

visualizeCodes(Rall, 10);




%locateCodes(test401, 'threshMode',0, 'colMode', 1, 'sizeThresh', [500, 2000], 'thresh', ...
%    ((30:270) / 300));