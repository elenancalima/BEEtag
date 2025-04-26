function output=printVertex(FID, i, VERTICES, COLOURS, vertextype)

output = '0\nVERTEX\n';

if vertextype ~= 128
    %disp('vertextype not 128');
    % = 128+64 dump as polyface mesh vertex (called by dxf_polymesh).
    % = 32 dump as polyline vertex (called by dxf_polyline)
    % Per-vertex colouring does not work for DXF files.
    output=append(output,dxf_print_layer(FID));
    %disp('layer print done');
    %disp(FID);
    output=append(output,dxf_print_point(0,VERTICES(i,1),VERTICES(i,2),VERTICES(i,3)));
    %disp('point print done');
else
    %disp('vertextype 128');
    % =128 - dump faces of polyface mesh.
    % Setup different per-face colour depending on COLOURS matrix.
    currentcolor = FID.color;
    if nargin == 4
        FID.color = COLOURS(i);
    end
    output=append(output,dxf_print_layer(FID));
    FID.color = currentcolor;
    output=append(output,dxf_print_point(0,0,0,0));
end

%disp('mid for for vertextype ~=128 or not');

% 70 Vertex flags:
% 1 = Extra vertex created by curve-fitting
% 2 = Curve-fit tangent defined for this vertex. A curve-fit tangent direction of 0 may be
%     omitted from DXF output but is significant if this bit is set
% 4 = Not used
% 8 = Spline vertex created by spline-fitting
% 16 = Spline frame control point
% 32 = 3D polyline vertex
% 64 = 3D polygon mesh
% 128 = Polyface mesh vertex

%fprintf(FID.fid,'70\n');
%fprintf(FID.fid,'%d\n',vertextype); % layer
output=sprintf('%s70\n%d\n',output,vertextype); % layer

% =128, dump faces of polyface mesh.
if vertextype == 128
    output=sprintf('%s71\n%d\n72\n%d\n73\n%d\n', output, VERTICES(i,1:3)); % layer
    if size(VERTICES,2) == 4
        output=sprintf('%s74\n%d\n',output,VERTICES(i,4)); % layer
    else
        output=sprintf('%s74\n0\n',output); % layer
    end
end
%disp(output);
%strOut = append(output{1});
%disp(strOut);
%fprintf(FID.fid, output);
end
