function trackBEEtags_parfor_production()
disp('function called');

try
        addpath('C:/Users/Woncheol/Documents/MATLAB');  % folder containing your pathdef.m
        path(pathdef);
    catch ME
        warning('Could not load pathdef');
end

disp('after add pathdef');

imagePath_info = 'C:\Users\Woncheol\HOI\HOI_Analysis\imagePathCrossTalk.txt';

image_folder_path = fileread(imagePath_info);

condition_path = 'C:\Users\Woncheol\HOI\HOI_Analysis\conditionCrossTalk.txt';
fileID_1 = fopen(condition_path, 'r');
line_content = fgetl(fileID_1);
fclose(fileID_1);

output_prefix = line_content;

parameter_path = 'C:\Users\Woncheol\HOI\HOI_Analysis\parameterCrossTalk.txt';

% Read entire file (works even if the matrix spans multiple lines)
txt = fileread(parameter_path);

% Parse MATLAB matrix literal -> numeric matrix
combos = str2num(txt);  %#ok<ST2NM>

parallel_track_explicit(image_folder_path, output_prefix, combos);

end
