% Smallbank1 was a small bank of 78 images that I was using to test on a
% small image of size 150x150 pixels

% Take in a bank of images
smallbank1 = dir('./source_images_tester/smallbank1/*.jpg');

% Number of images
n = size(smallbank1, 1)

% Loop through the image bank
for i = 1:n
    progress = (i*100)/n % See progress in command window
    img = imread(strcat('./source_images_tester/smallbank1/', smallbank1(i).name));
    
    % Height of given image
    h = size(img, 1);
    
    % Width of given image
    w = size(img, 2);
    
    % Take the smaller of the height and width, and crop the image to be a 
    % square with that dimension. The square's center should be at the center
    % of the original image.
    if h > w
        crop_img = imcrop(img, [1 ((h/2)-(w/2)) w w]);
    end
    if w > h
        crop_img = imcrop(img, [((w/2)-(h/2)) 1 h h]);
    end
    
    % If it's already a square just leave it.
    if w == h
        crop_img = img;
    end
    
    imwrite(crop_img, strcat('./source_images_tester/smallbank1/', smallbank1(i).name));
end
