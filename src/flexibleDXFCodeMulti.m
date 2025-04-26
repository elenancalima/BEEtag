function code = flexibleDXFCodeMulti(dxf, codesList, nRow, nCol, codeSize, oriX, oriY)

scale = codeSize; % code size in milimeters
featureScale = scale / 9;
spacingScale = 1.2; % space between codes


f = figure();
set(f, 'Visible', 'off');
cla reset;

for i = 1:nRow
    disp('i:');
    disp(i);
    for j = 1:nCol
        idNum = ((i - 1) * nCol + j);
        if idNum <= nRow * nCol && idNum <= size(codesList,2)
            code = createCode(codesList(idNum));
            code = code';

            %code = flip(code);
            % flip when the print is on the film
            % and the paper liner is glued on the print surface

            % no flipping if the print is on the paper and the
            % protection layer is simply over them
            % also no flipping if the mirroring is delegated to a
            % printing service

            code = padarray(code,[1 1], 1, 'both');
            code = padarray(code, [1 1],'both');
            code = padarray(code,[2 2], 1, 'both');

            %disp(code);

            [cx,cy] = find(code == 1);
            cx = cx * featureScale;
            cy = cy * featureScale;

            cx = oriX + cx;
            cy = oriY + cy;
            
            cx = cx + (j - 1) * (scale + spacingScale);
            cy = cy + (i - 1) * (scale + spacingScale);

            lx = cx - 0.5 * featureScale; % * (0.8 + ovlIdx * 0.1);
            rx = cx + 0.5 * featureScale; % * (0.8 + ovlIdx * 0.1);
            uy = cy + 0.5 * featureScale; % * (0.8 + ovlIdx * 0.1);
            ly = cy - 0.5 * featureScale; % * (0.8 + ovlIdx * 0.1);


            n = length(lx);
            %disp(n);
            xCors = zeros([5,n]); % should be 4 for polymeshes
            yCors = zeros([5,n]);
            
            for k=1:n
                %xCors(:,k) = [lx(k),rx(k),rx(k),lx(k)];
                %yCors(:,k) = [uy(k),uy(k),ly(k),ly(k)];

                xCors(:,k) = [lx(k),rx(k),rx(k),lx(k),lx(k)];
                yCors(:,k) = [uy(k),uy(k),ly(k),ly(k),uy(k)];
            end
            zCors = zeros(size(xCors));
            %fvc = patch(xCors,yCors, zCors, 'red');
            %dxf_polymesh(dxf, fvc.Vertices, fvc.Faces);
            dxf_polyline_closed(dxf, xCors, yCors, zCors);
        end
        cla reset; % periodical clearing is needed to prevent matlab from hanging. dxf is still going
    end

end

end


