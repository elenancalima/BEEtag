%% Example for generating 110 separated high resolution jpegs for single tags
load robustCodeList.mat

%% disp(grand);
ntags = numel(grand); %How many tags to print?

%f = figure('Visible', 'Off'); %Tells the figure not to print to the screen, so that resoluiton won't be limited by screen size
%set(f, 'Position', [0 0 4000 4000])

nClusterPerRow = 12;
nClusterPerCol = 10;
tagPadSize = 1090;
for i = 1: ceil(ntags / (nClusterPerRow*nClusterPerCol))
    imRow = zeros(tagPadSize * nClusterPerCol + 1,1);
    for j = 1:nClusterPerRow
        imColumn = zeros(1,tagPadSize);
        for k = 1:nClusterPerCol
            idnum = (i - 1) * (nClusterPerRow * nClusterPerCol) + (j - 1) * 7 + k;
            if idnum <= 110
                num = grand(idnum);
            
                im = createPrintableCode(num, 5);
                im = padarray(im,[2 2], 0, 'both');
                im = padarray(im,[30 30], 1, 'both');
                im = repmat(im,10,10);
                %imshow(im);
                %print(strcat(num2str(k, '%06d'), 'testC.png'), '-dpng', '-r1200');
                disp(size(im));
                disp(size(imColumn));
                imColumn = [imColumn ; im];
            end
        end

        disp(size(imColumn));

        %set(gcf,'PaperUnits','inches','PaperPosition',[0 0 size(imColumn,2)/1000 size(imColumn,1)/1000])
        %imwrite(imColumn, strcat(num2str(j, '%06d'), 'testCC.png'));
        %imshow(imColumn);
        %print(strcat(num2str(j, '%06d'), 'testCC.png'), '-dpng', '-r1000');
        

        %disp(size(imRow));
        %disp(size(imColumn));
        imRow = imRow(1:size(imColumn,1),:);
        imRow = [imRow imColumn];
    end
    
    %imshow(imRow);
    %text(-25, 150, num2str(num), 'FontSize', 30, 'Rotation', 90);
    %text(380, 180, '->', 'FontSize', 30);
    %print(strcat(num2str(i, '%06d'), 'multi.png'), '-dpng', '-r1200');
    imwrite(imRow, strcat(num2str(i, '%06d'), 'multi.png'));
    
end

