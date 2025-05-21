function dxf_print_layer_new(FID,layerStr,colStr)
%DXF_PRINT_LAYER Dump entity properties.
%   Internal function: Not usable directly.
%
%   Copyright 2010-2011 Grzegorz Kwiatek.
%   $Revision: 1.0.3 $  $Date: 2011.08.25 $%
fprintf(FID.fid,append('8\n',layerStr,'\n62\n',colStr,'\n'));
end