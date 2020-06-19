function tissuePositions = assignSpots(mask, tissuePositions, maskName, append)


    nSpots = size(tissuePositions, 1);
    crow = round(table2array(tissuePositions(:, 5)));
    ccol = round(table2array(tissuePositions(:, 6)));
    if append
        region = table2array(tissuePositions(:, 7));
        maskLabel = table2array(tissuePositions(:, 8));
        for i = 1:nSpots
            region{i} = [region{i} ';' num2str(mask(crow, ccol))];
            maskLabel{i} = [maskLabel{i} ';' maskName];
        end
        tissuePositions = [tissuePositions(:,1:6) array2table(region) array2table(maskLabel)];
    else
        region = cell(nSpots, 1);
        maskLabel = cell(nSpots, 1);
        for i = 1:nSpots
            region{i} = num2str(mask(crow, ccol));
            maskLabel{i} = maskName;
        end
        tissuePositions = [tissuePositions array2table(region) array2table(maskLabel)];
    end
    

    

end

