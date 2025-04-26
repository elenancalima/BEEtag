function code = createDXFCodeMulti(codesList, nRow, nCol, sizeArray, nSzCluster, nCpCluster, fileName)

scale = 0.5; % code size in milimeters
baseFeatureScale = scale / 9;
spacingScale = 1.35;

nCode = length(codesList);
disp(nCode);
disp(nRow);
disp(nCol);

f = figure();
set(f, 'Visible', 'off');
cla reset;


FID = dxf_open(fileName);
FID = dxf_set(FID,'Color',[1 1 0],'Layer',10);

for ovlIdx = 1:nCpCluster
    for szrIdx = 1:nSzCluster
        featureScale = baseFeatureScale * sizeArray(szrIdx);

        for i = 1:nRow
            disp('i:');
            disp(i);
            for j = 1:nCol
                %disp('j:');
                %disp(j);
                idNum = ((i - 1) * nCol + j);
                %disp(idNum);
                if idNum <= nRow * nCol
                    code = createCode(codesList(idNum));
                    code = code';

                    %code = flip(code);
                    % flip when the print is on the film
                    % and the paper liner is glued on the print surface

                    % no flipping if the print is on the paper and the
                    % protection layer is simply over them

                    code = padarray(code,[1 1], 1, 'both');
                    code = padarray(code, [2 2],'both');
                    code = padarray(code,[2 2], 1, 'both');

                    %disp(code);

                    [cx,cy] = find(code == 1);
                    cx = cx * featureScale;
                    cy = cy * featureScale;

                    cx = cx + j * 20 * baseFeatureScale * spacingScale + (szrIdx - 1) * 1.67 * (1 + nCol) * (1.35/1.5);
                    cy = cy + i * 20 * baseFeatureScale * spacingScale + (ovlIdx - 1) * 1.67 * (1 + nRow) * (1.35/1.5);


                    % not going to use feature dot sizing as that might
                    % confuse communication
                    lx = cx - 0.5 * featureScale; % * (0.8 + ovlIdx * 0.1);
                    rx = cx + 0.5 * featureScale; % * (0.8 + ovlIdx * 0.1);
                    uy = cy + 0.5 * featureScale; % * (0.8 + ovlIdx * 0.1);
                    ly = cy - 0.5 * featureScale; % * (0.8 + ovlIdx * 0.1);



                    n = length(lx);
                    %disp(n);
                    for k=1:n
                        fvc=patch([lx(k),rx(k),rx(k),lx(k)],[uy(k),uy(k),ly(k),ly(k)],[0,0,0,0],'red');
                        dxf_polymesh(FID, fvc.Vertices, fvc.Faces);
                        dxf_polyline_closed(FID, fvc.Vertices, fvc.Faces);
                    end
                end
                cla reset; % periodical clearing is needed to prevent matlab from hanging. dxf is still going
            end
            
        end
    end
end

FID = dxf_set(FID,'Color',[1 1 0],'TextThickness',0.5);
dxf_text(FID,3,-2,0,'CHROME DOWN   qU 3MO8H)','TextHeight',2);

dxf_close(FID);

end


