fileName = 'flexibleArrangements.dxf';

FID = dxf_open(fileName);
FID = dxf_set(FID,'Color',[1 1 0],'Layer',10);

load masterCodeList4-r04.mat
flexibleDXFCodeMulti(FID, grand, 44, 104, 0.5, 0, 0);

load masterCodeList6-r23.mat
flexibleDXFCodeMulti(FID, grand, 7, 57, 1.0, 0, (44 + 1) * 1.7);

load masterCodeList7.mat
flexibleDXFCodeMulti(FID, grand, 6, 19, 1.5, (57 + 1) * 2.2 - 1.4, (44 + 1) * 1.7); 

load masterCodeList7-r02.mat
flexibleDXFCodeMulti(FID, grand, 5, 25, 0.5, 0, (44 + 1) * 1.7 + (7+1)*2.2);

load masterCodeList7-r03.mat
flexibleDXFCodeMulti(FID, grand, 5, 25, 0.5, (25 + 1) * 1.7, (44 + 1) * 1.7+ (7+1)*2.2);

load masterCodeList7-r04.mat
flexibleDXFCodeMulti(FID, grand, 5, 25, 0.5, 2 * (25 + 1) * 1.7, (44 + 1) * 1.7+ (7+1)*2.2);

load masterCodeList7-r05.mat
flexibleDXFCodeMulti(FID, grand, 5, 25, 0.5, 3 * (25 + 1) * 1.7, (44 + 1) * 1.7+ (7+1)*2.2);

%load masterCodeList7-r05.mat
%flexibleDXFCodeMulti(FID, grand, 11, 10, 0.5, 53 * 2.2 + 12 * 2.7 + 3 * 8 * 1.7 - 1.1, 51 * 1.7);

%load masterCodeList7-r06.mat
%flexibleDXFCodeMulti(FID, grand, 11, 10, 0.5, 53 * 2.2 + 12 * 2.7 + 4 * 8 * 1.7 - 1.1, 51 * 1.7);


cols = 4; % number of columns per row
dx = 26 * 1.7;
dy = 18 * 1.7;
offsetY = (44 + 1) * 1.7 + (6 + 1) * 2.7 - 1.1 + (5 + 1) * 1.7;
totalFiles = 16;

for i = 0:(totalFiles - 1)
    row = floor(i / cols);
    col = mod(i, cols);
    
    % Construct file name
    fileNum = i + 2; % starts at r02
    fileName = sprintf('masterCodeList6-r%02d.mat', fileNum);
    load(fileName);
    
    % Compute positions
    x = col * dx;
    y = offsetY + row * dy;
    
    % Call function
    flexibleDXFCodeMulti(FID, grand, 17, 25, 0.5, x, y);
end




%x2 = [2 5; 2 5; 8 8];
%y2 = [4 0; 8 2; 4 0];
%z2 = zeros(size(x2));
%fvc=patch(x2,y2,z2,'green');
%disp(fvc.Vertices);
%disp(fvc.Faces);
%dxf_polymesh(FID, fvc.Vertices, fvc.Faces);


FID = dxf_set(FID,'Color',[1 1 0],'TextThickness',0.5);
dxf_text(FID,3,-2,0,'CHROME DOWN   qU 3MO8H)','TextHeight',2);

dxf_close(FID);



