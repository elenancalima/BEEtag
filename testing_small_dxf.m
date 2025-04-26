fileName = 'smallArrangements.dxf';

FID = dxf_open(fileName);
FID = dxf_set(FID,'Color',[1 1 0],'Layer',10);

load masterCodeList4-r04.mat
flexibleDXFCodeMulti(FID, grand, 4, 10, 0.5, 0, 0);


FID = dxf_set(FID,'Color',[1 1 0],'TextThickness',0.5);
dxf_text(FID,3,-2,0,'CHROME DOWN   qU 3MO8H)','TextHeight',2);

dxf_close(FID);



