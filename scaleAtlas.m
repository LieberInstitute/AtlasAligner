function scaleAtlas(imPathFull, atlasPathFull, maskPathFull)

    im = imread(imPathFull);
    atlas = imread(atlasPathFull);
    if maskPathFull
        load(maskPathFull);
        lmask = label2rgb(mask);
        atlas = 0.5*lmask + 0.5*atlas;
    end
    fig = uifigure('position', [50 50 1500 1000]);
    s = size(atlas);
    s = s(1:2);
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
        'ButtonPushedFcn', {@applyAndAssign, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider, im});
    saveButton = uibutton(fig, 'position', [100 20 150 20], 'Text', 'Apply shift to mask and assign spot regions',...
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
        set(rotateSlider, 'Value', rotateSlider.Value);
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

function applyAndAssign(~, ~, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider, im)

    left = round(xShiftSlider.Value);
    bot = round(yShiftSlider.Value);
    x = round(scaleSlider.Value);
    rot = rotateSlider.Value; 
    atlas1 = shiftImage(atlas, left, bot, x, rot);
    s = size(im);
    s = s(1:2);
    atlas1 = imresize(atlas1, s);
    

end


function saveShifts(~, ~, rotateSlider, scaleSlider, xShiftSlider, yShiftSlider,...
    imPathFull, atlasPathFull)

    s.left = round(xShiftSlider.Value);
    s.bot = round(yShiftSlider.Value);
    s.x = round(scaleSlider.Value);
    s.rot = rotateSlider.Value; 
    save([name '_mask.mat'], 'mask', '-v6');

end

function getExt2 = getPaths(getExt)

    if getenv('HOMEPATH')
        homepath = getenv('HOMEPATH');
    elseif getenv('HOME')
        homepath = getenv('HOME');
    end
    if ~exist(fullfile(homepath, 'atlas_paths'), 'dir')
        mkdir(fullfile(homepath, 'atlas_paths'));
    end
    if exist(fullfile(homepath, 'atlas_paths2.txt'), 'file')
        try
            pathinfo = fileread(fullfile(homepath, 'atlas_paths', 'atlas_paths2.txt'));
            pathinfo = regexp(pathinfo, '\n', 'split');
            getExt2 = fullfile(pathinfo{1}, getExt);
        catch
        end
    end

end




