 function im2 = shiftImage(im, left, bot, x, rot)

    s1 = size(im);
    bin = length(s1) == 2;
    s1 = s1(1:2);
    im1 = imrotate(im, rot);
    s2 = s1+x;
    if bin
        im2 = imresize(im1, s2, 'Method', 'nearest');
    else
        im2 = imresize(im1, s2);
    end
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

    %pad col zeros
    
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

