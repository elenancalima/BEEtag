for seqSet = 1:6
    fileName = sprintf('masterCodeList4-r%02d.mat', seqSet);
    load(fileName, 'grand');  
    fprintf('%d, %d %d %d %d %d \n', size(grand,2), grand(1,1:5));
end
