function main()

    fig = uifigure('Name', 'Select Images', 'position', [360 198 400 400]);
    uipanel(fig, 'position', [10 290 380 100], 'Title', 'Select image to be made square');
    uilabel(fig, 'position', [15 330 370 50], 'Text',...
        'In order to run this program, but the histology and atlas images must');
    uilabel(fig, 'position', [15 315 370 50], 'Text',...
        'be square. Please select each image separately to be made square');
    uilabel(fig, 'position', [15 300 370 50], 'Text',...
        '(You may select multiple images).');
    imButton = uibutton(fig, 'position', [270 300 110 20], 'Text', 'Select Images',...
        'ButtonPushedFcn', {@getImagesToSquare, fig});
    uipanel(fig, 'position', [10 165 380 120], 'Title', 'Segment atlas image');
    uilabel(fig, 'position', [15 225 370 50], 'Text',...
        'Select a square atlas image to segment into regions.');
    uilabel(fig, 'position', [15 210 370 50], 'Text',...
        'It is recommended that atlas images are segmented before rotation');
    uilabel(fig, 'position', [15 195 370 50], 'Text',...
        'and shifting.');
    uilabel(fig, 'position', [25 175 200 20], 'Text',...
        'Number of regions to segment');
    nRegionBox = uieditfield(fig, 'numeric', 'position', [200 175 50 20],...
        'Value', 10, 'Limits', [1 Inf]);
    segButton = uibutton(fig, 'position', [270 180 110 20], 'Text', 'Select Atlas Image',...
        'ButtonPushedFcn', {@getImagesToSegment, nRegionBox.Value});
    uipanel(fig, 'position', [10 90 380 70], 'Title', 'Align atlas to histology image');
    uilabel(fig, 'position', [15 100 370 50], 'Text',...
        'Select atlas image and histology image to align to.');
    overlayMask = uicheckbox(fig, 'position', [100 95 150 20], 'Text',...
        'Overlay labeled mask');
    alignButton = uibutton(fig, 'position', [270 95 110 20], 'Text', 'Select Images',...
        'ButtonPushedFcn', {@getImagesToAlign, overlayMask});
    uipanel(fig, 'position', [10 15 380 70], 'Title', 'Apply saved shift to mask and assign spots to regions');
    uilabel(fig, 'position', [15 25 370 50], 'Text',...
        'Select mask, shift object and tissue position list.');
    applyButton = uibutton(fig, 'position', [270 20 110 20], 'Text', 'Select Data',...
        'ButtonPushedFcn', {@getData});
    
end

function getImagesToSquare(~, ~, fig)

    com.mathworks.mwswing.MJFileChooserPerPlatform.setUseSwingDialog(1)
    getIm = '*.tiff;*.tif;*.png;*.jpg;*.jpeg';
    if getenv('HOMEPATH')
        homepath = getenv('HOMEPATH');
    elseif getenv('HOME')
        homepath = getenv('HOME');
    end
    if ~exist(fullfile(homepath, 'atlas_paths'), 'dir')
        mkdir(fullfile(homepath, 'atlas_paths'));
    end
    if exist(fullfile(homepath, 'atlas_paths.txt'), 'file')
        try
            pathinfo = fileread(fullfile(homepath, 'atlas_paths', 'atlas_paths.txt'));
            pathinfo = regexp(pathinfo, '\n', 'split');
            getIm = fullfile(pathinfo{1}, '*.tiff;*.tif;*.png;*.jpg;*.jpeg');
        catch
        end
    end
    [imFile, imPath] = uigetfile(getIm, 'Select Image File(s)', 'MultiSelect', 'on');
    if isa(imFile, 'cell')
        for i = 1:length(imFile)
            im1 = squareImage(fullfile(imPath, imFile{i}), fig);
            [~, imName, imExt] = fileparts(imFile{i});
            imwrite(im1, fullfile(imPath, [imName '_square' imExt]));
        end
    else
        im1 = squareImage(fullfile(imPath, imFile), fig);
        [~, imName, imExt] = fileparts(imFile);
        imwrite(im1, fullfile(imPath, [imName '_square' imExt]));
    end

end

function getImagesToSegment(~, ~, nRegions)

    com.mathworks.mwswing.MJFileChooserPerPlatform.setUseSwingDialog(1)
    getIm = '*.tiff;*.tif;*.png;*.jpg;*.jpeg';
    if getenv('HOMEPATH')
        homepath = getenv('HOMEPATH');
    elseif getenv('HOME')
        homepath = getenv('HOME');
    end
    if ~exist(fullfile(homepath, 'atlas_paths'), 'dir')
        mkdir(fullfile(homepath, 'atlas_paths'));
    end
    if exist(fullfile(homepath, 'atlas_paths.txt'), 'file')
        try
            pathinfo = fileread(fullfile(homepath, 'atlas_paths', 'atlas_paths.txt'));
            pathinfo = regexp(pathinfo, '\n', 'split');
            getIm = fullfile(pathinfo{1}, '*.tiff;*.tif;*.png;*.jpg;*.jpeg');
        catch
        end
    end
    [imFile, imPath] = uigetfile(getIm, 'Select Atlas Image File');
    makeSubRegions(fullfile(imPath, imFile), ceil(nRegions));

end

function getImagesToAlign(~, ~, overlayMask)

    com.mathworks.mwswing.MJFileChooserPerPlatform.setUseSwingDialog(1)
    getIm = '*.tiff;*.tif;*.png;*.jpg;*.jpeg';
    if getenv('HOMEPATH')
        homepath = getenv('HOMEPATH');
    elseif getenv('HOME')
        homepath = getenv('HOME');
    end
    if ~exist(fullfile(homepath, 'atlas_paths'), 'dir')
        mkdir(fullfile(homepath, 'atlas_paths'));
    end
    if exist(fullfile(homepath, 'atlas_paths.txt'), 'file')
        try
            pathinfo = fileread(fullfile(homepath, 'atlas_paths', 'atlas_paths.txt'));
            pathinfo = regexp(pathinfo, '\n', 'split');
            getIm = fullfile(pathinfo{1}, '*.tiff;*.tif;*.png;*.jpg;*.jpeg');
            getMat = fullfile(pathinfo{1}, '*.mat');
        catch
        end
    end
    [imFile, imPath] = uigetfile(getIm, 'Select Histology Image File');
    [atlasFile, atlasPath] = uigetfile(getIm, 'Select Atlas Image File');
    if overlayMask.Value
        [maskFile, maskPath] = uigetfile(getMat, 'Select Mask File');
        maskPathFull = fullfile(maskPath, maskFile);
    else
        maskPathFull = '';
    end
    scaleAtlas(fullfile(imPath, imFile), fullfile(atlasPath, atlasFile), maskPathFull);

end

function getData(~, ~)



end
