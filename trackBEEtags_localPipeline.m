image_folder_path = 'Z:\Woncheol\HOI_samples_for_BEEtag';
output_prefix = 'LocalTest';
trackBEEtags_universal(image_folder_path, output_prefix, [15 15], 3);

trackData = load('trackingData_LocalTest_WIP.mat');
trackData.trackingData;







% --- 1. Setup & Pre-computation ---

% Assume 'trackData' is your loaded struct in the workspace.
% The actual data is one level deeper, as we discovered.
data_to_process = trackData.trackingData;

% First, loop through once to count the total number of detections (rows).
total_detections = 0;
for i = 1:numel(data_to_process)
    if isfield(data_to_process(i), 'F') && ~isempty(data_to_process(i).F)
        total_detections = total_detections + numel(data_to_process(i).F);
    end
end

% --- 2. Pre-allocate the Table ---
% Define the names for all the columns you want to create.
% We will dynamically create names for the multi-value fields.
var_names = {'Frame', 'AntIndexInFrame', 'TagNumber', 'Area', 'CentroidX', 'CentroidY', ...
             'BBoxX', 'BBoxY', 'BBoxWidth', 'BBoxHeight'};

% Add names for the 4 corner points (8 columns total)
for i = 1:4
    var_names{end+1} = ['Corner' num2str(i) 'X'];
    var_names{end+1} = ['Corner' num2str(i) 'Y'];
end

% Add names for the 25 points (50 columns total)
for i = 1:25
    var_names{end+1} = ['Pt' num2str(i) 'X'];
    var_names{end+1} = ['Pt' num2str(i) 'Y'];
end

% Add names for the 25 code bits (25 columns total)
for i = 1:25
    var_names{end+1} = ['Code' num2str(i)];
end

% Create an empty table with the correct size and column names.
sz = [total_detections, numel(var_names)];
var_types = repmat({'double'}, 1, numel(var_names));
flat_table = table('Size', sz, 'VariableTypes', var_types, 'VariableNames', var_names);

% --- 3. Data Extraction Loop ---
% Loop through the data again to fill the pre-allocated table.
row_counter = 1;
for frameNumber = 1:numel(data_to_process)
    
    if isfield(data_to_process(frameNumber), 'F') && ~isempty(data_to_process(frameNumber).F)
        frame_detections = data_to_process(frameNumber).F;
        
        for antIndex = 1:numel(frame_detections)
            ant_data = frame_detections(antIndex);
            
            % --- Fill the table row ---
            
            % Simple scalar fields
            flat_table.Frame(row_counter) = frameNumber;
            flat_table.AntIndexInFrame(row_counter) = antIndex;
            flat_table.TagNumber(row_counter) = ant_data.number;
            flat_table.Area(row_counter) = ant_data.Area;
            
            % Unroll 1D vector fields
            flat_table.CentroidX(row_counter) = ant_data.Centroid(1);
            flat_table.CentroidY(row_counter) = ant_data.Centroid(2);
            flat_table.BBoxX(row_counter) = ant_data.BoundingBox(1);
            flat_table.BBoxY(row_counter) = ant_data.BoundingBox(2);
            flat_table.BBoxWidth(row_counter) = ant_data.BoundingBox(3);
            flat_table.BBoxHeight(row_counter) = ant_data.BoundingBox(4);
            
            % Unroll 2D matrix fields by reshaping them into a row
            % Note the transpose (') to get points in (X1, Y1, X2, Y2, ...) order
            flat_table{row_counter, 11:18} = reshape(ant_data.corners', 1, []);
            flat_table{row_counter, 19:68} = reshape(ant_data.pts', 1, []);
            flat_table{row_counter, 69:93} = ant_data.code;
            
            row_counter = row_counter + 1;
        end
    end
    
    % Display progress
    if mod(frameNumber, 50) == 0
        disp(['Processed frame ', num2str(frameNumber), ' of ', num2str(numel(data_to_process))]);
    end
end

% --- 4. Save to CSV ---
disp('Saving data to CSV file...');
writetable(flat_table, 'tracking_data.csv');
disp('Done.');