function tissuePositions = assignSpots(mask, tissuePositions, maskName, append)

    % This is a function to assign spots to sub-regions identified in this
    % tool. 
    % Inputs:
    % mask: labeled mask sized to the same size as the histology image
    % tissuePositions: table object from tissue_positions_list of spot
    % coordinates 
    % maskName: name of the mask file (used for saving)
    % append: logical of whether to append regions to tissuePositions or
    % overwrite
    % Output:
    % tissuePositions: table object with regions and mask labels added

    % Number of spots
    nSpots = size(tissuePositions, 1);
    % row and column coordinates
    crow = table2array(tissuePositions(:, 5));
    ccol = table2array(tissuePositions(:, 6));
    if append
        % get previous regions
        region = table2array(tissuePositions(:, 7));
        % get previous mask labels
        maskLabel = table2array(tissuePositions(:, 8));
        % if not read in as cell array, convert region to cell array
        if ~isa(region, 'cell')
            region = num2cell(region);
        end
        % for each spot append region and mask label to previous region and
        % mask label, separated by '\'
        for i = 1:nSpots
            region{i} = [num2str(region{i}) '\' num2str(mask(crow(i), ccol(i)))];
            maskLabel{i} = [maskLabel{i} '\' maskName];
        end
        % replace region and mask label with appended values
        tissuePositions = [tissuePositions(:,1:6) array2table(region) array2table(maskLabel)];
    else
        region = cell(nSpots, 1);
        maskLabel = cell(nSpots, 1);
        % for each spot assign region and mask label 
        for i = 1:nSpots
            region{i} = num2str(mask(crow(i), ccol(i)));
            maskLabel{i} = maskName;
        end
        % add region and mask label columns to tissuePositions table
        tissuePositions = [tissuePositions array2table(region) array2table(maskLabel)];
    end
    

    

end

