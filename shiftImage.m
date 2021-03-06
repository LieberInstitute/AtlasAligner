 function im2 = shiftImage(im, left, bot, x, rot)
 
    % This is a function to shift an image 
    % Inputs:
    % im: image (could be atlas image or labeled mask)
    % left: number (int) of pixels to shift image to the left 
        % (negative=to the right) 
    % bot: number (int) of pixels to shift image down (negative=up)
    % x: number (int) of pixels to add to each dimension in resizing image
        % (negative=pixels to remove)
    % rot: angle (degrees) to rotate image

    % get size of image
    s1 = size(im);
    % see if image is binary (binary image means it's a mask)
    bin = length(s1) == 2;
    s1 = s1(1:2);
    % rotate
    im1 = imrotate(im, rot);
    % get size to resize image to
    s2 = s1+x;
    % if image is binary, use 'nearest' method
    if bin
        im2 = imresize(im1, s2, 'Method', 'nearest');
    % if image is not binary, use default
    else
        im2 = imresize(im1, s2);
    end
    % shift, scale and pad with zeros to make image same size as original
    if -x-left==0
        %do nothing
    elseif left < 0
        im2 = im2(:, (-left+1):end, :);
        if bin
            z_right = zeros(s2(1), -x-left);
        else
            z_right = zeros(s2(1), -x-left, 3);
        end
        im2 = [im2 z_right];
    elseif left <= -x
        if bin
            z_left = zeros(s2(1), left);
            z_right = zeros(s2(1), -x-left);
        else
            z_left = zeros(s2(1), left, 3);
            z_right = zeros(s2(1), -x-left, 3);
        end
        im2 = [z_left im2 z_right];
    else
        im2 = im2(:, 1:end-left-x, :);
        if bin
            z_left = zeros(s2(1), left);
        else
            z_left = zeros(s2(1), left, 3);
        end
        im2 = [z_left im2];
    end    
    if -x-bot==0
        %do nothing
    elseif bot <= 0 
        im2 = im2(1:end+bot, :, :);
        if bin
            z_top = zeros(-x-bot, s1(1));
        else
            z_top = zeros(-x-bot, s1(1), 3);
        end
        im2 = [z_top; im2];
    elseif bot <= -x
        if bin
            z_top = zeros(-x-bot, s1(1));
            z_bot = zeros(bot, s1(1));
        else
            z_top = zeros(-x-bot, s1(1), 3);
            z_bot = zeros(bot, s1(1), 3);
        end
        im2 = [z_top; im2; z_bot];
    else
        im2 = im2(bot+x+1:end, :, :);
        if bin
            z_bot = zeros(bot, s1(1));
        else
            z_bot = zeros(bot, s1(1), 3);
        end
        im2 = [im2; z_bot];
    end

end

