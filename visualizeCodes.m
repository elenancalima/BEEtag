function visualizeCodes(R, cornerSize)
for i = 1:numel(R)
    corners = R(i).corners;
    cornersP = [corners(2,:) ;corners(1,:)];
    text(R(i).Centroid(1), R(i).Centroid(2), num2str(R(i).number), 'FontSize',30, 'color','r');
    hold on
    for bb = 1:4
        plot(cornersP(1,bb), cornersP(2,bb),'g.', 'MarkerSize', cornerSize)
    end

    plot(R(i).frontX, R(i).frontY, 'b.', 'MarkerSize', cornerSize);
end
end