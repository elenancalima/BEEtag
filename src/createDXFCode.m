function code = createDXFCode(num)

scale = 0.5; % code size in milimeters
featureScale = scale / 7;
code = createCode(num);
code = code';
code = padarray(code,[1 1], 1, 'both');
code = padarray(code, [1 1],'both');
code = padarray(code,[1 1], 1, 'both');

disp(code);

[cx,cy] = find(code == 1);
cx = cx * featureScale;
cy = cy * featureScale;

lx = cx - 0.5 * featureScale;
rx = cx + 0.5 * featureScale;
uy = cy + 0.5 * featureScale;
ly = cy - 0.5 * featureScale;

FID = dxf_open('exampleCode_polymesh.dxf');
FID = dxf_set(FID,'Color',[1 1 0],'Layer',10);

n = length(lx);
disp(n);
for i=1:n
    fvc = patch([lx(i),rx(i),rx(i),lx(i)],[uy(i),uy(i),ly(i),ly(i)],[0,0,0,0],'black');
    dxf_polymesh(FID, fvc.Vertices, fvc.Faces);
end


dxf_close(FID);

end


