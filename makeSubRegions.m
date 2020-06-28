function makeSubRegions(atlasPathFull, nRegions)

    % This is a function to create a labeled mask from a atlas image from
    % the <name of atlas> mouse brain atlas.
    % Inputs:
    % atlasPathFull: full path to image from the <name of atlas> mouse
    % brain atlas
    % nRegions: the number of regions to identify from the atlas

    % read in atlas image
    atlas = imread(atlasPathFull);
    [path, name, ~] = fileparts(atlasPathFull);
    % red channel
    atlas_R = atlas(:,:,1);
    % blue channel
    atlas_B = atlas(:,:,3);
    % modified atlas image: subtract red from blue, borders of regions 
    % should be white and interior black
    im = double(atlas_B-atlas_R);
    % make figure
    f = figure('units', 'normalized', 'position', [0 0 1 1]);
    % display atlas image
    ax = imagesc(atlas); colormap gray; axis image;
    % create mask object
    mask = zeros(size(im));
    % set mask as UserData for axis and figure
    set(ax, 'UserData', mask);
    set(f, 'UserData', mask);
    % panel for region assignment
    uipanel('units', 'normalized', 'position', [0.095 0.005 0.18 0.05],...
        'Title', 'Region Assignment');
    % dialog and buttons for region assignment
    assignDialog = uicontrol('Style', 'edit', 'units', 'normalized',...
        'position', [0.15 0.01 0.075 0.02], 'String', 1);
    assignDown = uicontrol('Style', 'push', 'units', 'normalized',...
        'position', [0.1 0.01 0.03 0.02], 'String', '-');
    assignUp = uicontrol('Style', 'push', 'units', 'normalized',...
        'position', [0.24 0.01 0.03 0.02], 'String', '+');
    assign = str2double(get(assignDialog, 'String'));
    % disable up/down buttons if they reach upper/lower limits
    if assign==1
        set(assignDown, 'Enable', 'off');
    elseif assign==nRegions
        set(assignUp, 'Enable', 'off');
    else
        set(assignDown, 'Enable', 'on');
        set(assignUp, 'Enable', 'on');
    end
    % callback functions for changing region assignment
    assignDialog.Callback = {@changeAssign, assignDown, assignUp, assign, nRegions};
    assignDown.Callback = {@assignDownFcn, assignUp, assignDialog, nRegions};
    assignUp.Callback = {@assignUpFcn, assignDown, assignDialog, nRegions};
    % panel for dilation of modified atlas image
    uipanel('units', 'normalized', 'position', [0.28 0.005 0.18 0.045],...
        'Title', 'Dilation');
    % dialog and buttons for dilation
    jumpDialog = uicontrol('Style', 'edit', 'units', 'normalized',...
        'position', [0.335 0.01 0.06 0.02], 'String', 1);
    jumpDown = uicontrol('Style', 'push', 'units', 'normalized',...
        'position', [0.285 0.01 0.03 0.02], 'String', '-');
    jumpUp = uicontrol('Style', 'push', 'units', 'normalized',...
        'position', [0.415 0.01 0.03 0.02], 'String', '+');
    jump = str2double(get(jumpDialog, 'String'));
    % disable up/down buttons if they reach upper/lower limits
    if jump==0
        set(jumpDown, 'Enable', 'off');
    else
        set(jumpDown, 'Enable', 'on');
        set(jumpUp, 'Enable', 'on');
    end
    % callback functions for changing dilation
    jumpDialog.Callback = {@changeJump, jumpDown, jumpUp, jump};
    jumpDown.Callback = {@jumpDownFcn, jumpUp, jumpDialog};
    jumpUp.Callback = {@jumpUpFcn, jumpDown, jumpDialog};
    % make colormap
    cmap = hsv(nRegions);
    % click function for region assignment
    set(ax, 'ButtonDownFcn', {@click, f, im, assignDialog, jumpDialog, cmap});
    % button and callback for roiPoly region assignment
    polyButton = uicontrol('Style', 'push', 'units', 'normalized',...
        'position', [0.5 0.01 0.05 0.045], 'String', 'ROI Poly');
    polyButton.Callback = {@polyTool, f, atlas, assignDialog, cmap, im, jumpDialog};
    % button and callback function for saving mask
    saveButton = uicontrol('Style', 'push', 'units', 'normalized',...
        'position', [0.9 0.01 0.05 0.045], 'String', 'Save');
    saveButton.Callback = {@saveManual, f, fullfile(path, name)};
    hold on;

end

function click(hObj, Event, f, im, assignDialog, jumpDialog, cmap)

    % This is the click function for region assignment
    % Inputs:
    % hObj: axis or plot object
    % Event: click information
    % f: figure
    % im: modified atlas image
    % assignDialog: dialog to get region number
    % jumpDialog: dialog to get dilation 
    % cmap: colormap
    
    % dilation
    jump = str2double(get(jumpDialog, 'String'));
    % region number
    assign = str2double(get(assignDialog, 'String'));
    % dilate modified image
    se = strel('disk', jump);
    im = imdilate(im, se);
    % get coordinates of click
    x = floor(Event.IntersectionPoint(1));
    y = floor(Event.IntersectionPoint(2));
    % get mask from UserData
    mask = get(f, 'UserData');
    % if click occurred in already defined region
    if mask(y,x) > 0
        % get region idx of clicked area
        idx = mask(y,x);
        delete(hObj);
        % set clicked region to zero
        mask(mask==idx)=0;
        % set mask as figure UserData
        set(f, 'UserData', mask);
    else
        % region grow from clicked coordinate on modified atlas image
        tmp = imfill(regiongrowing(im, y, x, 0), 'holes');
        % assign region grown area to assign
        mask(tmp==1) = assign;
        % set mask as figure data
        set(f, 'UserData', mask);
        % get coordinates of new region
        [c,r] = find(mask==assign);
        % plot region coordinates as color
        hold on;
        hLine = scatter(r, c, 25, cmap(assign,:), 'filled', ...
            'ButtonDownFcn', {@click, f, im, assignDialog, jumpDialog, cmap});
        hold off;
        % set mask as UserData of plot object
        set(hLine, 'UserData', mask);
    end
end

function changeJump(hDialog, ~, jumpDown, jumpUp, prevJump)

    jump = str2double(get(hDialog, 'String'));
    if mod(jump, 1)~=0 || jump < 0 
        errordlg('Dilation must be non-negative integer');
        jump = prevJump;
    end
    set(hDialog, 'String', jump);
    if jump==0
        set(jumpDown, 'Enable', 'off');
    else
        set(jumpDown, 'Enable', 'on');
        set(jumpUp, 'Enable', 'on');
    end

end

function jumpDownFcn(jumpDown, ~, jumpUp, jumpDialog)

    jump = str2double(get(jumpDialog, 'String'))-1;
    set(jumpDialog, 'String', jump);
    if jump==0
        set(jumpDown, 'Enable', 'off');
    else
        set(jumpDown, 'Enable', 'on');
        set(jumpUp, 'Enable', 'on');
    end
end

function jumpUpFcn(jumpUp, ~, jumpDown, jumpDialog)

    jump = str2double(get(jumpDialog, 'String'))+1;
    set(jumpDialog, 'String', jump);
    if jump==0
        set(jumpDown, 'Enable', 'off');
    else
        set(jumpDown, 'Enable', 'on');
        set(jumpUp, 'Enable', 'on');
    end

end

function changeAssign(hDialog, ~, assignDown, assignUp, prevAssign, nRegions)

    assign = str2double(get(hDialog, 'String'));
    if mod(assign, 1)~=0 || assign < 1 || assign > nRegions
        errordlg(['Region assignment must be integer between 1 and ' num2str(nRegions)]);
        assign = prevAssign;
    end
    set(hDialog, 'String', assign);
    if assign==1
        set(assignDown, 'Enable', 'off');
    elseif assign==nRegions
        set(assignUp, 'Enable', 'off');
    else
        set(assignDown, 'Enable', 'on');
        set(assignUp, 'Enable', 'on');
    end

end

function assignDownFcn(assignDown, ~, assignUp, assignDialog, nRegions)

    assign = str2double(get(assignDialog, 'String'))-1;
    set(assignDialog, 'String', assign);
    if assign==1
        set(assignDown, 'Enable', 'off');
    elseif assign==nRegions
        set(assignUp, 'Enable', 'off');
    else
        set(assignDown, 'Enable', 'on');
        set(assignUp, 'Enable', 'on');
    end
end

function assignUpFcn(assignUp, ~, assignDown, assignDialog, nRegions)

    assign = str2double(get(assignDialog, 'String'))+1;
    set(assignDialog, 'String', assign);
    if assign==1
        set(assignDown, 'Enable', 'off');
    elseif assign==nRegions
        set(assignUp, 'Enable', 'off');
    else
        set(assignDown, 'Enable', 'on');
        set(assignUp, 'Enable', 'on');
    end

end

function polyTool(~, ~, f, atlas, assignDialog, cmap, im, jumpDialog)

    assign = str2double(get(assignDialog, 'String'));
    mask = get(f, 'UserData');
    f2 = figure;
    BW = roipoly(atlas); 
    close(f2);
    mask(BW) = assign;
    [c,r] = find(mask==assign);
    hold on;
    hLine = scatter(r, c, 25, cmap(assign,:), 'filled', 'ButtonDownFcn', {@click, f, im, assignDialog, jumpDialog, cmap});
    hold off;
    set(hLine, 'UserData', mask);
    set(f, 'UserData', mask);
    
end

function saveManual(~, ~, f, name)

    mask = get(f, 'UserData');
    mask(mod(mask,1)~=0) = 0;
    %se = strel('disk', 10);
    %mask = imdilate(mask, se);
    mask = imfill(mask, 'holes');
    name = [name '_mask.mat'];
    [name, path] = uiputfile(name);
    save(fullfile(path, name), 'mask', '-v6');
    
end

