function makeSubRegions(atlasPathFull, nRegions)

    atlas = imread(atlasPathFull);
    [path, name, ~] = fileparts(atlasPathFull);
    atlas_R = atlas(:,:,1);
    atlas_B = atlas(:,:,3);
    im = double(atlas_B-atlas_R);
    f = figure('units', 'normalized', 'position', [0 0 1 1]);
    ax = imagesc(atlas); colormap gray; axis image;
    mask = zeros(size(im));
    set(ax, 'UserData', mask);
    set(f, 'UserData', mask);
    uipanel('units', 'normalized', 'position', [0.095 0.005 0.18 0.05], 'Title', 'Sub Region Assignment');
    assignDialog = uicontrol('Style', 'edit', 'units', 'normalized', 'position', [0.15 0.01 0.075 0.02], 'String', 1);
    assignDown = uicontrol('Style', 'push', 'units', 'normalized', 'position', [0.1 0.01 0.03 0.02], 'String', '-');
    assignUp = uicontrol('Style', 'push', 'units', 'normalized', 'position', [0.24 0.01 0.03 0.02], 'String', '+');
    assign = str2double(get(assignDialog, 'String'));
    if assign==1
        set(assignDown, 'Enable', 'off');
    elseif assign==nRegions
        set(assignUp, 'Enable', 'off');
    else
        set(assignDown, 'Enable', 'on');
        set(assignUp, 'Enable', 'on');
    end
    assignDialog.Callback = {@changeAssign, assignDown, assignUp, assign, nRegions};
    assignDown.Callback = {@assignDownFcn, assignUp, assignDialog, nRegions};
    assignUp.Callback = {@assignUpFcn, assignDown, assignDialog, nRegions};
    uipanel('units', 'normalized', 'position', [0.28 0.005 0.18 0.045], 'Title', 'Dilation');
    jumpDialog = uicontrol('Style', 'edit', 'units', 'normalized', 'position', [0.335 0.01 0.06 0.02], 'String', 0);
    jumpDown = uicontrol('Style', 'push', 'units', 'normalized', 'position', [0.285 0.01 0.03 0.02], 'String', '-');
    jumpUp = uicontrol('Style', 'push', 'units', 'normalized', 'position', [0.415 0.01 0.03 0.02], 'String', '+');
    jump = str2double(get(jumpDialog, 'String'));
    if jump==0
        set(jumpDown, 'Enable', 'off');
    else
        set(jumpDown, 'Enable', 'on');
        set(jumpUp, 'Enable', 'on');
    end
    jumpDialog.Callback = {@changeJump, jumpDown, jumpUp, jump};
    jumpDown.Callback = {@jumpDownFcn, jumpUp, jumpDialog};
    jumpUp.Callback = {@jumpUpFcn, jumpDown, jumpDialog};
    cmap = hsv(nRegions);
    set(ax, 'ButtonDownFcn', {@click, f, im, assignDialog, jumpDialog, cmap});
    polyButton = uicontrol('Style', 'push', 'units', 'normalized', 'position', [0.5 0.01 0.05 0.045], 'String', 'ROI Poly');
    polyButton.Callback = {@polyTool, f, atlas, assignDialog, cmap, im, jumpDialog};
    saveButton = uicontrol('Style', 'push', 'units', 'normalized', 'position', [0.9 0.01 0.05 0.045], 'String', 'Save');
    saveButton.Callback = {@saveManual, f, fullfile(path, name)};
    hold on;

end

function click(hObj, Event, f, im, assignDialog, jumpDialog, cmap)
    
    jump = str2double(get(jumpDialog, 'String'));
    assign = str2double(get(assignDialog, 'String'));
    se = strel('disk', jump);
    im = imdilate(im, se);
    x = floor(Event.IntersectionPoint(1));
    y = floor(Event.IntersectionPoint(2));
    mask = get(f, 'UserData');
    if mask(y,x) > 0
        maskLab = bwlabel(mask);
        idx = maskLab(y,x);
        delete(hObj);
        mask(maskLab==idx)=0;
        set(f, 'UserData', mask);
    else
        tmp = imfill(regiongrowing(im, y, x, 0), 'holes');
        mask(tmp==1) = assign;
        %figure; imshow(mask);
        set(f, 'UserData', mask);
        [c,r] = find(mask==assign);
        hold on;
        hLine = scatter(r, c, 25, cmap(assign,:), 'filled', 'ButtonDownFcn', {@click, f, im, assignDialog, jumpDialog, cmap});
        hold off;
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

