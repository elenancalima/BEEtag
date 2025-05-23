function dxf_print_vertex(FID, VERTICES, vertextype, varargin)
%DXF_PRINT_VERTEX Dump entity properties.
%   Internal function: Not usable directly.
%
%   Copyright 2011 Grzegorz Kwiatek.
%   $Revision: 1.0.0 $  $Date: 2011.08.25 $%

try
  if nargin == 4
    % only per-face colouring is accepted.
    COLOURS = varargin{1};
    % if COLOURS is (N x 3) matrix, reduce it to ACI colour index table (N x 1).
    if size(COLOURS,2) == 3
      COLOURS = dxf_rgb2aci(COLOURS);
    end
  end

  layerStr = int2str(FID.layer);
  colStr = int2str(FID.color);
  layerPrint = append('8\n',layerStr,'\n62\n',colStr,'\n');

  zeroPointPrint = sprintf('1%1d\n%1.8g\n2%1d\n%1.8g\n3%1d\n%1.8g\n',0,0,0,0,0,0);
  for i=1:size(VERTICES,1)
    
    fprintf(FID.fid,'0\nVERTEX\n');

    if vertextype ~= 128
      % = 128+64 dump as polyface mesh vertex (called by dxf_polymesh).
      % = 32 dump as polyline vertex (called by dxf_polyline)
      % Per-vertex colouring does not work for DXF files.
      fprintf(FID.fid,layerPrint);
      pointPrint = sprintf('10\n%1.8g\n20\n%1.8g\n30\n%1.8g\n',0,VERTICES(i,1),0,VERTICES(i,2),0,VERTICES(i,3));
      fprintf(FID.fid, pointPrint);
    else
      % =128 - dump faces of polyface mesh.
      % Setup different per-face colour depending on COLOURS matrix.
      currentcolor = FID.color;
      if nargin == 4
        FID.color = COLOURS(i);
      end
      fprintf(FID.fid,layerPrint);
      FID.color = currentcolor;
      %dxf_print_point(FID,0,0,0,0);
      fprintf(FID.fid,zeroPointPrint);
    end
    
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

    fprintf(FID.fid,'70\n%d\n',vertextype); % layer  
    
    % =128, dump faces of polyface mesh.
    if vertextype == 128
      fprintf(FID.fid,'71\n');  
      fprintf(FID.fid,'%d\n',VERTICES(i,1)); % layer  
      fprintf(FID.fid,'72\n');  
      fprintf(FID.fid,'%d\n',VERTICES(i,2)); % layer  
      fprintf(FID.fid,'73\n');  
      fprintf(FID.fid,'%d\n',VERTICES(i,3)); % layer  
      if size(VERTICES,2) == 4
        fprintf(FID.fid,'74\n');  
        fprintf(FID.fid,'%d\n',VERTICES(i,4)); % layer  
      else
        fprintf(FID.fid,'74\n');  
        fprintf(FID.fid,'0\n'); % layer  
      end
    end
  end
  
catch exception
  if FID.fid >= 0
    fclose(FID.fid);
  end
  rethrow(exception);
end  