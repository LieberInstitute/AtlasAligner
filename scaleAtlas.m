function scaleAtlas(imPathFull, atlasPathFull, maskPathFull)

    % This is a function to manipulate an atlas from a GUI
    % Inputs:
    % imPathFull: full path to histology image
    % atlasPathFull: full path to atlas image
    % maskPathFull: full path to labeled mask

    % read in histology and atlas images
    im = imread(imPathFull);
    atlas = imread(atlasPathFull);
    
    % launch figure
    fig = uifigure('position', [50 50 1500 1000]);
    % get sizes of atlas image and histology image
    s = size(atlas);
    s = s(1:2);
    s2 = size(im);
    % atlas and histology images must be square
    if s(1) ~= s(2)
        error('Atlas image must be square');
    end
    if s2(1) ~= s2(2) 
        error('Histology image must be square');
    end
    % if mask was included, load mask, ensure it is the same size as
    % atlas image, and overlay mask onto atlas image
    if maskPathFull
        load(maskPathFull);
        s3 = size(mask);
        if s3(1) ~= s(1) || s3(2) ~= s(2)
            error('Mask and atlas must be the same size');
        end
        lmask = label2rgb(mask);
        atlas = 0.5*lmask + 0.5*atlas;
    end
    % resize histology image to size of atlas image
    im1 = imresize(im, s);
    % create image with histology and atlas images overlayed
    mix = 0.5*im1 + 0.5*atlas; 
    % display overlayed image
    ax = uiaxes(fig, 'position', [50 50 900 900]);
    h = imshow(mix, 'parent', ax);
    % make slider and dialog box for rotation
    uilabel(fig, 'position', [1020 820 150 20], 'Text', 'Rotate Atlas (degrees)');
    rotateSlider = uislider(fig, 'position', [1000 800 200 20],...
        'Value', 0, 'Limits', [-180 180]);
    rotateBox = uieditfield(fig, 'numeric', 'position', [1250 800 40 20],...
        'Value', 0, 'Limits', [-180 180]);
    % make slider and dialog box for scale
    uilabel(fig, 'position', [1020 720 150 20], 'Text', 'Scale Atlas');
    scaleSlider = uislider(fig, 'position', [1000 700 200 20],...
        'Value', 0, 'Limits', [-s(1)+1 s(1)-1]);
    scaleBox = uieditfield(fig, 'numeric', 'position', [1250 700 40 20],...
        'Value', 0, 'Limits', [-s(1)+1 s(1)-1]);
    % make slider and dialog box for x shift
    uilabel(fig, 'position', [1020 620 150 20], 'Text', 'Shift Atlas (x)');
    xShiftSlider = uislider(fig, 'position', [1000 600 200 20],...
        'Value', 0, 'Limits', [-s(1)+1 s(1)-1]);
    xShiftBox = uieditfield(fig, 'numeric', 'position', [1250 600 40 20],...
        'Value', 0, 'Limits', [-s(1)+1 s(1)-1]);
    % make slider and dialog box for y shift
    uilabel(fig, 'position', [1020 520 150 20], 'Text', 'Shift Atlas (y)');
    yShiftSlider = uislider(fig, 'position', [1000 500 200 20],...
        'Value', 0, 'Limits', [-s(1)+1 s(1)-1]);
    yShiftBox = uieditfield(fig, 'numeric', 'position', [1250 500 40 20],...
        'Value', 0, 'Limits', [-s(1)+1 s(1)-1]);
    % assign callback functions for sliders and dialog boxes
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
    % button with callback function to apply a shift and assign spots to
    % regions
    applyButton = uibutton(fig, 'position', [1200 20 250 20], 'Text', 'Apply shift to mask and assign spot regions',...
        'ButtonPushedFcn', {@applyAndAssign, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider, im, fig});
    % button with callback function to save shift object to .MAT file
    saveButton = uibutton(fig, 'position', [100 20 150 20], 'Text', 'Save shift object',...
        'ButtonPushedFcn', {@saveShifts, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
        imPathFull, atlasPathFull});
       
end

function edit(obj, ~, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
        rotateBox, scaleBox, xShiftBox, yShiftBox, im, atlas, h)
    
    % This is a callback function to shift and scale atlas image
    % Inputs:
    % obj: the dialog box or slider
    % rotateSlider: slider object for rotation
    % scaleSlider: slider object for scale
    % xShiftSlider: slider object for x shift
    % yShiftSlider: slider object for y shift
    % rotateBox: dialog box for rotation
    % scaleBox: dialog box for scale
    % xShiftBox: dialog box for x shift
    % yShiftBox: dialog box for y shift
    % im: histology image resized to size of atlas image
    % atlas: atlas image
    % h: axis object where overlayed image is displayed
    
    % if a slider was changed, set all dialog boxes to slider values
    if isa(obj, 'matlab.ui.control.Slider')
        set(rotateBox, 'Value', rotateSlider.Value);
        set(scaleBox, 'Value', round(scaleSlider.Value));
        set(xShiftBox, 'Value', round(xShiftSlider.Value));
        set(yShiftBox, 'Value', round(yShiftSlider.Value));
        set(scaleSlider, 'Value', round(scaleSlider.Value));
        set(xShiftSlider, 'Value', round(xShiftSlider.Value));
        set(yShiftSlider, 'Value', round(yShiftSlider.Value));
    % if a dialog box was changed, set all sliders to dialog box values
    elseif isa(obj, 'matlab.ui.control.NumericEditField')
        set(rotateSlider, 'Value', rotateBox.Value);
        set(scaleSlider, 'Value', round(scaleBox.Value));
        set(xShiftSlider, 'Value', round(xShiftBox.Value));
        set(yShiftSlider, 'Value', round(yShiftBox.Value));
        set(scaleBox, 'Value', round(scaleBox.Value));
        set(xShiftBox, 'Value', round(xShiftBox.Value));
        set(yShiftBox, 'Value', round(yShiftBox.Value));
    end
    
    % save slider values
    left = round(xShiftSlider.Value);
    bot = round(yShiftSlider.Value);
    x = round(scaleSlider.Value);
    rot = rotateSlider.Value;
    % rotate, shift, and scale atlas 
    atlas1 = shiftImage(atlas, left, bot, x, rot);
    % overlay images
    mix = 0.5*atlas1+0.5*im;
    % set axis to display new overlayed image
    set(h, 'CData', mix);

end

function applyAndAssign(~, ~, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider, im, fig)

    % This is a callback function to apply atlas shifting and assign spots
    % Inputs:
    % rotateSlider: slider object for rotation
    % scaleSlider: slider object for scale
    % xShiftSlider: slider object for x shift
    % yShiftSlider: slider object for y shift
    % im: original histology image
    % fig: main GUI figure

    % store slider values
    left = round(xShiftSlider.Value);
    bot = round(yShiftSlider.Value);
    x = round(scaleSlider.Value);
    rot = rotateSlider.Value; 
    % prompt user to get labeled mask file
    getMat = getPath('*.mat');
    [maskFile, maskPath] = uigetfile(getMat, 'Select mask .MAT file');
    % load the mask
    load(fullfile(maskPath, maskFile));
    % shift the mask
    shiftedMask = shiftImage(mask, left, bot, x, rot);
    % resize the shifted mask to size of full histology image
    s = size(im);
    s = s(1:2);
    shiftedMask = imresize(shiftedMask, s, 'Method', 'nearest');
    % get name (no path or ext) of mask file
    [~,maskName,~] = fileparts(maskFile);
    % prompt user to get tissue positions list
    getTbl = getPath('*.csv;*.txt');
    [tpFile, tpPath] = uigetfile(getTbl, 'Select tissue positions list file');
    % load the tissue positions list as a table
    tissuePositions = readtable(fullfile(tpPath, tpFile));
    % if there are more than 6 columns assume the last ones are previous
    % assignments, and prompt user to select if values should be
    % overwritten or appended
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
        % new tissuePositions table is saved as figure user data
        tissuePositions = get(fig, 'UserData');
    % if there are not more than 6 columns, assign the spots with append
    % set to false
    else
        tissuePositions = assignSpots(shiftedMask, tissuePositions, maskName, false);
    end
    % get name (no path or ext) of tissue positions list
    [~,name,~] = fileparts(tpFile);
    % use <tissue positions list name>_regions.csv as suggested name
    name = [name '_regions.csv'];
    % prompt user to select file to save new table (start with suggested
    % name but it can be changed)
    [name, path] = uiputfile(fullfile(tpPath, name));
    % write new table to file
    writetable(tissuePositions, fullfile(path, name),...
        'WriteVariableNames', false, 'Delimiter', ',');
    

end


function saveShifts(~, ~, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
    imPathFull, atlasPathFull)

    % This is a callback function to save atlas shift object
    % Inputs:
    % rotateSlider: slider object for rotation
    % scaleSlider: slider object for scale
    % xShiftSlider: slider object for x shift
    % yShiftSlider: slider object for y shift
    % imPathFull: full path to histology image
    % atlasPathFull: full path to atlas image

    % store shift values to struct
    shift.left = round(xShiftSlider.Value);
    shift.bot = round(yShiftSlider.Value);
    shift.x = round(scaleSlider.Value);
    shift.rot = rotateSlider.Value; 
    % get name (no path or ext) of histology and atlas images
    [~,imName,~] = fileparts(imPathFull);
    [atlasPath,atlasName,~] = fileparts(atlasPathFull);
    % create suggested name for shift object
    name = [atlasName '_to_' imName '_shift.mat'];
    % prompt user to select file to save shift object to
    [name, path] = uiputfile(fullfile(atlasPath, name));
    % save shift object
    save(fullfile(path, name), 'shift', '-v6');

end

function append(~, ~, shiftedMask, tissuePositions, maskName, fig, aFig)

    % This is a callback function to apply atlas shifting and assign spots
    % when append option is selected
    % Inputs:
    % shiftedMask: shifted labeled mask
    % tissuePositions: table object of tissue positions list
    % maskName: name of labeled mask
    % fig: GUI figure
    % aFig: append or overwrite figure
    
    % assign spots with append set to true
    tissuePositions = assignSpots(shiftedMask, tissuePositions, maskName, true);
    % set main figure GUI data to new tissuePositions table
    set(fig, 'UserData', tissuePositions);
    % close the append or overwrite figure
    close(aFig);

end

function overwrite(~, ~, shiftedMask, tissuePositions, maskName, fig, aFig)

    % This is a callback function to apply atlas shifting and assign spots
    % when append option is selected
    % Inputs:
    % shiftedMask: shifted labeled mask
    % tissuePositions: table object of tissue positions list
    % maskName: name of labeled mask
    % fig: GUI figure
    % aFig: append or overwrite figure

    % assign spots with append set to false
    tissuePositions = assignSpots(shiftedMask, tissuePositions, maskName, false);
    % set main figure GUI data to new tissuePositions table
    set(fig, 'UserData', tissuePositions);
    % close the append or overwrite figure
    close(aFig);

end

function getExt = getPath(getExt)

    % This is a function to get the previous path accessed from this
    % application and append the extension(s) for a uigetfile call

    % get HOMEPATH environment variable (Windows)
    if getenv('HOMEPATH')
        homepath = getenv('HOMEPATH');
    % if HOMEPATH doesn't exist, get HOME environment variable (Unix)
    elseif getenv('HOME')
        homepath = getenv('HOME');
    end
    % Make atlas_paths directory in the HOMEPATH/HOME directory if it
    % doesn't already exist
    if ~exist(fullfile(homepath, 'atlas_paths'), 'dir')
        mkdir(fullfile(homepath, 'atlas_paths'));
    end
    % If atlas_paths.txt exists in the atlas_paths directory, read the path
    % from that text file
    if exist(fullfile(homepath, 'atlas_paths', 'atlas_paths.txt'), 'file')
        try
            pathinfo = fileread(fullfile(homepath, 'atlas_paths', 'atlas_paths.txt'));
            pathinfo = regexp(pathinfo, '\n', 'split');
            getExt = fullfile(pathinfo{1}, getExt);
        catch
        end
    end

end






