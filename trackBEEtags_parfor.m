function trackBEEtags_parfor()
disp('function called');

try
        addpath('C:/Users/Woncheol/Documents/MATLAB');  % folder containing your pathdef.m
        path(pathdef);
    catch ME
        warning('Could not load pathdef');
end

disp('after add pathdef');

image_folder_path = 'C:\Users\Woncheol\BEEtag\BEEtag\tempLocalSamples';

condition_path = 'C:\Users\Woncheol\HOI\HOI_Analysis\conditionCrossTalk.txt';
fileID_1 = fopen(condition_path, 'r');
line_content = fgetl(fileID_1);
fclose(fileID_1);

output_prefix = line_content;


%trackBEEtags_universal(image_folder_path, output_prefix, [15 15], 3);


parallel_track(image_folder_path, output_prefix, [6 31], [7 10]);
end
