function scaleAtlas(imPathFull, atlasPathFull, maskPathFull)

    % This is a function to manipulate an atlas 

    im = imread(imPathFull);
    atlas = imread(atlasPathFull);
    
    fig = uifigure('position', [50 50 1500 1000]);
    s = size(atlas);
    s = s(1:2);
    s2 = size(im);
    if s(1) ~= s(2)
        error('Atlas image must be square');
    end
    if s2(1) ~= s2(2) 
        error('Histology image must be square');
    end
    if maskPathFull
        load(maskPathFull);
        s3 = size(mask);
        if s3(1) ~= s(1) || s3(2) ~= s(2)
            error('Mask and atlas must be the same size');
        end
        lmask = label2rgb(mask);
        atlas = 0.5*lmask + 0.5*atlas;
    end
    im1 = imresize(im, s);
    mix = 0.5*im1 + 0.5*atlas; 
    ax = uiaxes(fig, 'position', [50 50 900 900]);
    h = imshow(mix, 'parent', ax);
    uilabel(fig, 'position', [1020 820 150 20], 'Text', 'Rotate Atlas (degrees)');
    rotateSlider = uislider(fig, 'position', [1000 800 200 20],...
        'Value', 0, 'Limits', [-180 180]);
    rotateBox = uieditfield(fig, 'numeric', 'position', [1250 800 40 20],...
        'Value', 0, 'Limits', [-180 180]);
    uilabel(fig, 'position', [1020 720 150 20], 'Text', 'Scale Atlas');
    scaleSlider = uislider(fig, 'position', [1000 700 200 20],...
        'Value', 0, 'Limits', [-s(1)+1 s(1)-1]);
    scaleBox = uieditfield(fig, 'numeric', 'position', [1250 700 40 20],...
        'Value', 0, 'Limits', [-s(1)+1 s(1)-1]);
    uilabel(fig, 'position', [1020 620 150 20], 'Text', 'Shift Atlas (x)');
    xShiftSlider = uislider(fig, 'position', [1000 600 200 20],...
        'Value', 0, 'Limits', [-s(1)+1 s(1)-1]);
    xShiftBox = uieditfield(fig, 'numeric', 'position', [1250 600 40 20],...
        'Value', 0, 'Limits', [-s(1)+1 s(1)-1]);
    uilabel(fig, 'position', [1020 520 150 20], 'Text', 'Shift Atlas (y)');
    yShiftSlider = uislider(fig, 'position', [1000 500 200 20],...
        'Value', 0, 'Limits', [-s(1)+1 s(1)-1]);
    yShiftBox = uieditfield(fig, 'numeric', 'position', [1250 500 40 20],...
        'Value', 0, 'Limits', [-s(1)+1 s(1)-1]);
    rotateSlider.ValueChangedFcn = {@edit, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
        rotateBox, scaleBox, xShiftBox, yShiftBox, im1, atlas, h};
    scaleSlider.ValueChangedFcn = {@edit, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
        rotateBox, scaleBox, xShiftBox, yShiftBox, im1, atlas, h};
    xShiftSlider.ValueChangedFcn = {@edit, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
        rotateBox, scaleBox, xShiftBox, yShiftBox, im1, atlas, h};
    yShiftSlider.ValueChangedFcn = {@edit, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
        rotateBox, scaleBox, xShiftBox, yShiftBox, im1, atlas, h};
    rotateBox.ValueChangedFcn = {@edit, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
        rotateBox, scaleBox, xShiftBox, yShiftBox, im1, atlas, h};
    scaleBox.ValueChangedFcn = {@edit, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
        rotateBox, scaleBox, xShiftBox, yShiftBox, im1, atlas, h};
    xShiftBox.ValueChangedFcn = {@edit, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
        rotateBox, scaleBox, xShiftBox, yShiftBox, im1, atlas, h};
    yShiftBox.ValueChangedFcn = {@edit, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
        rotateBox, scaleBox, xShiftBox, yShiftBox, im1, atlas, h};
    applyButton = uibutton(fig, 'position', [1200 20 250 20], 'Text', 'Apply shift to mask and assign spot regions',...
        'ButtonPushedFcn', {@applyAndAssign, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider, im, fig});
    saveButton = uibutton(fig, 'position', [100 20 150 20], 'Text', 'Save shift object',...
        'ButtonPushedFcn', {@saveShifts, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
        imPathFull, atlasPathFull});
       
end

function edit(obj, ~, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
        rotateBox, scaleBox, xShiftBox, yShiftBox, im, atlas, h)

    if isa(obj, 'matlab.ui.control.Slider')
        set(rotateBox, 'Value', rotateSlider.Value);
        set(scaleBox, 'Value', round(scaleSlider.Value));
        set(xShiftBox, 'Value', round(xShiftSlider.Value));
        set(yShiftBox, 'Value', round(yShiftSlider.Value));
        set(scaleSlider, 'Value', round(scaleSlider.Value));
        set(xShiftSlider, 'Value', round(xShiftSlider.Value));
        set(yShiftSlider, 'Value', round(yShiftSlider.Value));
    elseif isa(obj, 'matlab.ui.control.NumericEditField')
        set(rotateSlider, 'Value', rotateBox.Value);
        set(scaleSlider, 'Value', round(scaleBox.Value));
        set(xShiftSlider, 'Value', round(xShiftBox.Value));
        set(yShiftSlider, 'Value', round(yShiftBox.Value));
        set(scaleBox, 'Value', round(scaleBox.Value));
        set(xShiftBox, 'Value', round(xShiftBox.Value));
        set(yShiftBox, 'Value', round(yShiftBox.Value));
    end
    
    left = round(xShiftSlider.Value);
    bot = round(yShiftSlider.Value);
    x = round(scaleSlider.Value);
    rot = rotateSlider.Value;
    atlas1 = shiftImage(atlas, left, bot, x, rot);
    mix = 0.5*atlas1+0.5*im;
    set(h, 'CData', mix);

end

function applyAndAssign(~, ~, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider, im, fig)

    left = round(xShiftSlider.Value);
    bot = round(yShiftSlider.Value);
    x = round(scaleSlider.Value);
    rot = rotateSlider.Value; 
    getMat = getPath('*.mat');
    [maskFile, maskPath] = uigetfile(getMat, 'Select mask .MAT file');
    load(fullfile(maskPath, maskFile));
    shiftedMask = shiftImage(mask, left, bot, x, rot);
    s = size(im);
    s = s(1:2);
    shiftedMask = imresize(shiftedMask, s, 'Method', 'nearest');
    [~,maskName,~] = fileparts(maskFile);
    getTbl = getPath('*.csv;*.txt');
    [tpFile, tpPath] = uigetfile(getTbl, 'Select tissue positions list file');
    tissuePositions = readtable(fullfile(tpPath, tpFile));
    if size(tissuePositions, 2) > 6
        aFig = uifigure('Name', 'Append or overwrite?',...
            'position', [360 198 320 100]); 
        appendButton = uibutton(aFig, 'position', [50 40 100 20],...
            'Text', 'Append', 'ButtonPushedFcn',... 
            {@append, shiftedMask, tissuePositions, maskName, fig, aFig});
        overwriteButton = uibutton(aFig, 'position', [170 40 100 20],...
            'Text', 'Overwrite', 'ButtonPushedFcn',... 
            {@overwrite, shiftedMask, tissuePositions, maskName, fig, aFig});
        uiwait(aFig);
        tissuePositions = get(fig, 'UserData');
    else
        tissuePositions = assignSpots(shiftedMask, tissuePositions, maskName, false);
    end
    [~,name,~] = fileparts(tpFile);
    name = [name '_regions.csv'];
    [name, path] = uiputfile(fullfile(tpPath, name));
    writetable(tissuePositions, fullfile(path, name),...
        'WriteVariableNames', false, 'Delimiter', ',');
    

end


function saveShifts(~, ~, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
    imPathFull, atlasPathFull)

    shift.left = round(xShiftSlider.Value);
    shift.bot = round(yShiftSlider.Value);
    shift.x = round(scaleSlider.Value);
    shift.rot = rotateSlider.Value; 
    [~,imName,~] = fileparts(imPathFull);
    [atlasPath,atlasName,~] = fileparts(atlasPathFull);
    name = [atlasName '_to_' imName '_shift.mat'];
    [name, path] = uiputfile(fullfile(atlasPath, name));
    save(fullfile(path, name), 'shift', '-v6');

end

function append(~, ~, shiftedMask, tissuePositions, maskName, fig, aFig)

    tissuePositions = assignSpots(shiftedMask, tissuePositions, maskName, true);
    set(fig, 'UserData', tissuePositions);
    close(aFig);

end

function overwrite(~, ~, shiftedMask, tissuePositions, maskName, fig, aFig)

    tissuePositions = assignSpots(shiftedMask, tissuePositions, maskName, false);
    set(fig, 'UserData', tissuePositions);
    close(aFig);

end

function getExt = getPath(getExt)

    % This is a function to get the 

    if getenv('HOMEPATH')
        homepath = getenv('HOMEPATH');
    elseif getenv('HOME')
        homepath = getenv('HOME');
    end
    if ~exist(fullfile(homepath, 'atlas_paths'), 'dir')
        mkdir(fullfile(homepath, 'atlas_paths'));
    end
    if exist(fullfile(homepath, 'atlas_paths', 'atlas_paths.txt'), 'file')
        try
            pathinfo = fileread(fullfile(homepath, 'atlas_paths', 'atlas_paths.txt'));
            pathinfo = regexp(pathinfo, '\n', 'split');
            getExt = fullfile(pathinfo{1}, getExt);
        catch
        end
    end

end






