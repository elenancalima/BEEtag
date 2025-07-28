
for i = 1:nframes
    %for i = 1:numel(trackingData)
    %disp(trackingData(i).F);
    R = trackingData(i).F;
    Rnumber = [];
    for rIdx = 1:size(R,1)
        %disp(R(rIdx,1).number);
        Rnumber = [Rnumber R(rIdx,1).number];
    end


    curNumbers = [Rnumber];
    %%
    if i == 1
        allNumbers = [] ;
    else
        allNumbers = [allNumbers curNumbers];
    end
    %disp(allNumbers);
    codeVisList = unique(allNumbers);
    %disp(codelist);
end

%% if there's no 'codelist' object defined, extract it from all the unique codes tracked in the movie
%disp("codeListSize");
%disp(size(codelist));
if size(codelist,2) < 1
    %disp("noCodeList");
    codelist = codeVisList;
end
%%
disp(codeVisList);
%disp(codelist);
disp('rearranging data into easier format');
trackingDataReshaped = struct();
for i = 1:nframes
    %%
    %disp("frame:")
    %disp(i);
    F = trackingData(i).F;
    R = F;
    Rnumber = [];
    for rIdx = 1:size(R,1)
        %disp(R(rIdx,1).number);
        Rnumber = [Rnumber R(rIdx,1).number];
    end
    Rnumber = unique(Rnumber);
    %disp("Rnumber:");
    %disp(Rnumber);

    %disp("codelist");
    %disp(codelist);
    %disp(numel(codelist));

    for j = 1:numel(codelist)
        %%
        %disp("codeN");
        %disp(j);
        if ~isempty(F)
            %disp("FnotEmpty");
            if (codelist(j)==4656079)
                disp(F)
                disp(F(Rnumber == codelist(j)));
            end
            FS = F(Rnumber == codelist(j));
            %disp("FSsize")
            %disp(size(FS));
            if(size(FS,1) > 1)
                FS = FS(1,1);
            end
            %FS = FS(1,1);
            if ~isempty(FS)
                %disp("FS");
                %disp(FS);
                %disp("FS1.Centroid");
                %disp(FS(1).Centroid);
                trackingDataReshaped(j).CentroidX(i) = FS.Centroid(1);
                trackingDataReshaped(j).CentroidY(i) = FS.Centroid(2);
                trackingDataReshaped(j).FrontX(i) = FS.frontX;
                trackingDataReshaped(j).FrontY(i) = FS.frontY;
                trackingDataReshaped(j).number(i) = FS.number;
            end
        end
    end

end


%% Save data
save('trackingData.mat', 'trackingDataReshaped')

%% Replay video
disp('replaying video with tracking data shown');
TD = trackingDataReshaped;

outputMovieName = 'ExampleTrackingMovie.avi';
outputMovie = 0; %Set to 1 if you want to save a movie, set to 0 if not

%If we're in movie writing mode, output the video
if outputMovie == 0
    vidObj = VideoWriter(outputMovieName);
    open(vidObj)
end

for i = 1:nframes
    %%
    im =  read(mov, i);
    imshow(im);
    hold on;
    for j = 1:numel(TD)
        %disp(j);
        %disp(TD(j));
        if isfield(TD(j),"CentroidX")
            if numel(TD(j).CentroidX) >= i & ~isempty(TD(j).CentroidX(i))
                try
                    plot([TD(j).CentroidX(i) TD(j).FrontX(i)], [TD(j).CentroidY(i) TD(j).FrontY(i)], 'b-','LineWidth', 3);
                    text(TD(j).CentroidX(i), TD(j).CentroidY(i), num2str(TD(j).number(i)),'FontSize', 25, 'Color', 'r');
                catch
                    continue
                end
            end
        end
    end
    drawnow
    currFrame = getframe;
    writeVideo(vidObj, currFrame);
    hold off;
end

close(vidObj);

for sID = 1:size(TD,2)
    writestruct(TD(1,sID),sprintf('structTest_%03d.xml',sID));
end