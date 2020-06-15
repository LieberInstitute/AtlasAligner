function atlas3 = shiftImage(atlas, im, left, bot, x, rot)

    atlas1 = imrotate(atlas, rot);
    s = size(im);
    s = s(1:2);
    atlas2 = imresize(atlas1, s);
    s1 = size(atlas2);
    s1 = s1(1:2);
    s2 = s1+x;
    atlas3 = imresize(atlas2, s2);
    
    if -x-left==0
        %do nothing
    elseif left < 0
        atlas3 = atlas3(:, (-left+1):end, :);
        z_right = zeros(s2(1), -x-left, 3);
        atlas3 = [atlas3 z_right];
    elseif left <= -x
        z_left = zeros(s2(1), left, 3);
        z_right = zeros(s2(1), -x-left, 3);
        atlas3 = [z_left atlas3 z_right];
    else
        atlas3 = atlas3(:, 1:end-left-x, :);
        z_left = zeros(s2(1), left, 3);
        atlas3 = [z_left atlas3];
    end

    %pad col zeros
    
    if -x-bot==0
        %do nothing
    elseif bot <= 0 
        atlas3 = atlas3(1:end+bot, :, :);
        z_top = zeros(-x-bot, s(1), 3);
        atlas3 = [z_top; atlas3];
    elseif bot <= -x
        z_top = zeros(-x-bot, s(1), 3);
        z_bot = zeros(bot, s(1), 3);
        atlas3 = [z_top; atlas3; z_bot];
    else
        atlas3 = atlas3(bot+x+1:end, :, :);
        z_bot = zeros(bot, s(1), 3);
        atlas3 = [atlas3; z_bot];
    end

end

