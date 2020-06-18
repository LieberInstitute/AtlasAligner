function main()

    % This is the main function for the Atlas Analyzer application
    % This function launches a GUI to get histology and atlas images to
    % square, shift, scale, and align. Additionally, this function lets you 
    % choose a square atlas image to segment into regions. Finally, you can
    % use results of alignment to assign ST spots to regions defined in the
    % application.

    %% Main figure
    % this launches the main figure 
    fig = uifigure('Name', 'Atlas Aligner', 'position', [360 198 400 400]); 
    
    %% Square images
    % panel for squaring image
    uipanel(fig, 'position', [10 290 380 100], 'Title',...                              
        'Select image to be made square');  
    uilabel(fig, 'position', [15 330 370 50], 'Text',...                                
        'In order to run this program, but the histology and atlas images must');
    uilabel(fig, 'position', [15 315 370 50], 'Text',...
        'be square. Please select each image separately to be made square');
    uilabel(fig, 'position', [15 300 370 50], 'Text',...
        '(You may select multiple images).');
    % button that calls function for squaring images
    imButton = uibutton(fig, 'position', [270 300 110 20], 'Text',...
        'Select Images', 'ButtonPushedFcn', {@getImagesToSquare, fig});
    
    %% Segment Atlas
    % panel for segmenting atlas
    uipanel(fig, 'position', [10 165 380 120], 'Title',...
        'Segment atlas image');
    uilabel(fig, 'position', [15 225 370 50], 'Text',...
        'Select a square atlas image to segment into regions.');
    uilabel(fig, 'position', [15 210 370 50], 'Text',...
        'It is recommended that atlas images are segmented before rotation');
    uilabel(fig, 'position', [15 195 370 50], 'Text',...
        'and shifting.');
    uilabel(fig, 'position', [25 175 200 20], 'Text',...
        'Number of regions to segment');
    % box to input number of regions 
    % currently this only requires a number >1, but it should be an integer
    % current fix is to round the input - could add code to require integer
    nRegionBox = uieditfield(fig, 'numeric', 'position', [200 175 50 20],...
        'Value', 10, 'Limits', [1 Inf]);
    % button that calls function for segmenting atlas
    segButton = uibutton(fig, 'position', [270 180 110 20], 'Text',...
        'Select Atlas Image','ButtonPushedFcn',...
        {@getImagesToSegment, nRegionBox.Value});
    
    %% Align atlas to histology image
    % panel for alignment
    uipanel(fig, 'position', [10 90 380 70], 'Title',...
        'Align atlas to histology image');
    uilabel(fig, 'position', [15 100 370 50], 'Text',...
        'Select atlas image and histology image to align to.');
    % checkbox is an option to overlay a labeled mask
    % checking this will require user to select a .MAT mask object
    overlayMask = uicheckbox(fig, 'position', [100 95 150 20], 'Text',...
        'Overlay labeled mask');
    % button that calls function for aligning mask to histology image
    alignButton = uibutton(fig, 'position', [270 95 110 20], 'Text',...
        'Select Images', 'ButtonPushedFcn', {@getImagesToAlign, overlayMask});
    
    %% Assign spots from previously saved data
    % panel to load data and assign spots
    uipanel(fig, 'position', [10 15 380 70], 'Title',...
        'Apply saved shift to mask and assign spots to regions');
    uilabel(fig, 'position', [15 25 370 50], 'Text',...
        'Select mask, shift object and tissue position list.');
    % button that calls function for loading data and assigning spots
    applyButton = uibutton(fig, 'position', [270 20 110 20], 'Text',...
        'Select Data', 'ButtonPushedFcn', {@getData});
    
end

function getImagesToSquare(~, ~, fig)

    % This is a function to select images to be made square
    % after selecting images, this function calls squareImage() to launch
    % GUI for squaring images

    % This line just makes the UI experience faster in my experience
    com.mathworks.mwswing.MJFileChooserPerPlatform.setUseSwingDialog(1)
    % All the acceptable image extensions
    getIm = '*.tiff;*.tif;*.png;*.jpg;*.jpeg;*.mat';
    % find previous file path
    getIm = getPath(getIm);
    % launches interface to select images, can select multiple
    [imFile, imPath] = uigetfile(getIm, 'Select Image File(s)',...
        'MultiSelect', 'on');
    % write this path to atlas_paths.txt
    setPath(imPath, 'Please select an image file.');
    % if multiple images were selected, loop through each
    if isa(imFile, 'cell')
        for i = 1:length(imFile)
            % call function to launch GUI
            im1 = squareImage(fullfile(imPath, imFile{i}), fig);
            % get image name w/o ext 
            [~, imName, imExt] = fileparts(imFile{i});
            % write square image to new file with same name plus '_square'
            imwrite(im1, fullfile(imPath, [imName '_square' imExt]));
        end
    else
        % call function to launch GUI
        im1 = squareImage(fullfile(imPath, imFile), fig);
        % get image name w/o ext 
        [~, imName, imExt] = fileparts(imFile);
        % write square image to new file 
        name = [imName '_square' imExt];
        [name, path] = uiputfile(fullfile(imPath, name));
        imwrite(im1, fullfile(path, name));
    end

end

function getImagesToSegment(~, ~, nRegions)

    % This is a function to select atlas image to be made segmented
    % after selecting image, this function calls makeSubRegions() to launch
    % GUI for segmenting atlas

    % This line just makes the UI experience faster in my experience
    com.mathworks.mwswing.MJFileChooserPerPlatform.setUseSwingDialog(1)
    % All the acceptable image extensions
    getIm = '*.tiff;*.tif;*.png;*.jpg;*.jpeg';
    % find previous file path
    getIm = getPath(getIm);
    % launches interface to select atlas image
    [imFile, imPath] = uigetfile(getIm, 'Select Atlas Image File');
    % write this path to atlas_paths.txt
    setPath(imPath, 'Please select an image file.');
    % call function to segment atlas
    makeSubRegions(fullfile(imPath, imFile), ceil(nRegions));

end

function getImagesToAlign(~, ~, overlayMask)

    % This is a function to select a square histology image and a square
    % atlas image to be alined.
    % after selecting images, this function calls scaleAtlas() to launch
    % GUI for alignment

    % This line just makes the UI experience faster in my experience
    com.mathworks.mwswing.MJFileChooserPerPlatform.setUseSwingDialog(1)
    % All the acceptable image extensions
    getIm = '*.tiff;*.tif;*.png;*.jpg;*.jpeg';
    % find previous file path
    getIm = getPath(getIm);
    % launches interface to select histology image
    [imFile, imPath] = uigetfile(getIm, 'Select Histology Image File');
    % launches interface to select atlas image
    [atlasFile, atlasPath] = uigetfile(getIm, 'Select Atlas Image File');
    % write this path to atlas_paths.txt
    setPath(imPath, 'Please select a histology and atlas image file.');
    % if you want to overlay mask file
    if overlayMask.Value
        % find previous file path
        getMat = getPath('*mask*.mat');
        % launches interface to select mask .MAT file
        [maskFile, maskPath] = uigetfile(getMat, 'Select Mask File');
        % write this path to atlas_paths.txt
        setPath(maskPath, 'Please select a mask file.');
        % full path to mask file
        maskPathFull = fullfile(maskPath, maskFile);
    else
        % no mask file
        maskPathFull = '';
    end
    % call function to align atlas to histology image
    scaleAtlas(fullfile(imPath, imFile), fullfile(atlasPath, atlasFile), maskPathFull);

end

function getData(~, ~)



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

function setPath(path, errMsg)

    % This is a function to write the path just accessed from a uigetfile()
    % call to the atlas_paths.txt file

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
    % If the user chose a file, there should be a path, write this path to
    % atlas_paths.txt
    if ischar(path)
        ip = strrep(path, '\', '/');
        fid = fopen(fullfile(homepath, 'atlas_paths', 'atlas_paths.txt'), 'w');
        fprintf(fid, ip);
        fclose(fid);
        clear ip
    % If a path wasn't created throw an error message specified as an input
    % for the funciton
    else
        error(errMsg);
    end

end
