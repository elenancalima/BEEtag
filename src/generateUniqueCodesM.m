
for seqSet = 1:24
    disp(seqSet);
    codesFinal = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
    codeList = reshape(createCode(1)', 1, 25);

    load masterCodeList7-r01.mat
    grandPast = grand;

    pgUpTo = seqSet;

    for i = 1:pgUpTo
        fileName = sprintf('masterCodeList7-r%02d.mat', i);
        load(fileName, 'grand');  
        grandPast = [grandPast grand]; 
    end

    saveName = sprintf('masterCodeList7-r%02d.mat', pgUpTo + 1);



    grand = [];

    for dd = 1:(2^15-1) %Highest possible number is 32767 with 15 bits
        %%
        if sum(grandPast==dd) == 0
            test = createCode(dd);

            [pass code or codes] = checkOrs25(test);

            if pass == 1

                %Find pairwise distances between all stored codes and current code

                distM = zeros(size(codesFinal,1),1);

                for ee = 1:numel(distM)
                    distM(ee) = sum(abs(codesFinal(ee,:) - code));
                end

                if (min(distM)) > 6
                    %if  min(distM) > 6  %%Comment in to generate "robustCodeList"
                    grand = [grand dd];
                    codesFinal = [codesFinal ; codes];
                    codeList = [codeList; reshape(test', 1, 25)];
                end
            end
            if mod(dd, 1000) == 0
                disp(dd);
            end
        end
    end
    %% Optional saving to overwrite stored codelist
    codeList = codeList(2:end,:);
    save(saveName, 'grand');
    %save('robustCodeList.mat', 'grand')

    disp(size(grand));

end

% 468
% 478
% 456
% 453
% 464

