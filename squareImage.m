function im1 = squareImage(imPathFull, fig)

    [~,~,ext] = fileparts(imPathFull);

    im = imread(imPathFull);

    imSize = size(im);
    if imSize(1)==imSize(2)
        im1 = im;
        sqSideStr = '';
        return;
    elseif imSize(1) > imSize(2)
        subfig = uifigure('position', [50 50 1500 1000]);
        ax = uiaxes(subfig, 'position', [50 50 900 900]);
        s = imSize(2);
        options = {'Top', 'Bottom'};
        val = 'Top';
    elseif imSize(1) < imSize(2)
        subfig = uifigure('position', [50 50 1500 1000]);
        ax = uiaxes(subfig, 'position', [50 50 900 900]);
        s = imSize(1);
        options = {'Left', 'Right'};
        val = 'Left';
    end
    
    im1 = im(1:s,1:s,:);
    set(fig, 'UserData', im1);
    h = imshow(im1, 'parent', ax);
    uilabel(subfig, 'position', [1020 820 150 20], 'Text', 'Select square from...');
    sqSide = uidropdown(subfig, 'position', [1020 800 200 20], 'Items',...
        options, 'Value', val, 'ValueChangedFcn', {@cutImage, im, s, h, fig});
    uilabel(subfig, 'position', [1020 750 400 20],...
        'Text', '*When squaring a histology image, it is recommended to select the');
    uilabel(subfig, 'position', [1020 730 400 20],...
        'Text', 'Top or Left Square.');
    finishButton = uibutton(subfig, 'position', [20 20 100 20], 'Text', 'Finish',...
        'ButtonPushedFcn', {@finish, subfig});
    uiwait(subfig);
    im1 = get(fig, 'UserData');
   
    
end

function cutImage(sqSide, ~, im, s, h, fig)


   if strcmp(sqSide.Value, 'Top')
       im1 = im(1:s, :, :);
   elseif strcmp(sqSide.Value, 'Bottom')
       imSize = size(im, 1);
       start = imSize-s+1;
       im1 = im(start:end, :, :);
   elseif strcmp(sqSide.Value, 'Left')
       im1 = im(:, 1:s, :);
   elseif strcmp(sqSide.Value, 'Right')
       imSize = size(im, 2);
       start = imSize-s+1;
       im1 = im(:, start:end, :);
   end
   set(h, 'CData', im1);
   set(fig, 'UserData', im1);

end

function finish(~, ~, subfig)

    close(subfig);

end

