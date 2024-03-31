close all;

target = im2double(imread('redmoon.jpg'));
targetHeight = size(target, 1);
targetWidth = size(target, 2);

% Want to make a template the same size as the target image. This will hold
% my mosaic
holder = target;

squaresize = 15;

% Comment out the below line after running once (if image bank hasn't changed)
%srcPixelArr = srcPixelGetter();

temp = 1; % Just to keep track of what percent progress the code is at 
for i = 1:squaresize:size(target, 1)
    for j = 1:squaresize:size(target,2)
        progress = (100*temp)/((targetHeight/squaresize)*(targetWidth/squaresize))
        
        % A square piece of the target image (possibly 15x15 pixels)
        square = imcrop(target,[j i squaresize squaresize]); 
        
        % The average pixel value of the square (of the target image) at hand
        avgPix = mean(mean(square, 1), 2);
        % If you remove semicolon, you will get 3 values
        % avgPix(:,:,1) for red, avgPix(:,:,2) for green, avgPix(:,:,3) for blue
            
        % Initialized this to a random number
        indexOfSmallestDist = 123;
        
        % Initialized this to a random large number
        smallestDist = 12345;
        
        % Empty array the same size as the number of source images in the image bank
        dists = zeros(1, size(srcPixelArr, 2));

        % Loop through the source image bank average pixel values.
            % Go to my srcPixelGetter() function to see specifically what srcPixelArr is
        for n = 1:size(srcPixelArr, 2)
            % Find the distance (the difference) between the average pixel
            % value of the square of the target image that we're looking at
            % and the the source image that we're looking at using my
            % distanceFinder() function. More details there.
            dist = distanceFinder(avgPix, srcPixelArr(1, n), srcPixelArr(2, n), srcPixelArr(3, n));
            
            % Store it in the array of distances for this square of the target image
            dists(1, n) = dist;   
            
            % Used in earlier versions of my code; keeps track of which
            % single source tile has the smallest distance
            if (dist < smallestDist)
                smallestDist = dist;
                indexOfSmallestDist = n;
            end
        end
        
        % Created an array of the 8 smallest distances and an array of 
        % their indices within the source image array
        [smallest_dists, indicesOfSmallestDists] = mink(dists, 8);
        
        % A random number between 1 and 8
        randNum1to8 = randi(8);
        
        % Randomly choose one of the indices of the 8 smallest distances
        chosenIndex = indicesOfSmallestDists(randNum1to8);
        % This will be the index of the source image I will use as my tile
        % for this piece of the mosaic.
        
        % Loop through the source image bank
        for m = 1:size(unsplashcombo, 1)
            % Find the single source image that is at the index I chose above.
            if m == chosenIndex
                img = im2double(imread(strcat('./source_images_tester/unsplashcombo/', unsplashcombo(m).name)));
                
                % Resize that source image to be 15x15 pixels
                resizedImg = imresize(img, [squaresize squaresize]);
                
                % Find the average pixel value of the 15x15 source image
                avgPixInResizedImg = mean(mean(resizedImg, 1), 2);
                
                % Find the ratio between the average pixel value for this square
                % of the target image and the average pixel value for the
                % chosen (and resized) source tile.
                factor = avgPix./avgPixInResizedImg;
                
                % Multiply the resized source tile by that factor to get it
                % closer to the target square's original color.
                recoloredImg = resizedImg .* factor;
                
                % Insert this tile (recoloredImg) into the mosaic template.
                holder(i:i+squaresize-1, j:j+squaresize-1, :) = recoloredImg;
            end
        end
        temp = temp + 1; % To keep track of progress
    end
end

figure; imshow(holder);
imwrite(holder, 'output.jpg');


% Function takes in avgPix, which is the average pixel value of a square
% cut out of the target image, as squareRGB.
    % avgPix/squareRGB has 3 components, one for red, green, and blue.
% Function also takes in the red, green, and blue components of the average
% pixel value of a certain source image.
function dist = distanceFinder(squareRGB, srcAvgPixR, srcAvgPixG, srcAvgPixB)
    % Find the difference between red components of the target square's average pixel
    % value and the source image's average pixel value.
    redDiff = abs(squareRGB(:, :, 1) - srcAvgPixR);
    % Same for green and blue.
    greenDiff = abs(squareRGB(:, :, 2) - srcAvgPixG);
    blueDiff = abs(squareRGB(:, :, 3) - srcAvgPixB);
    
    % Sum the differences to get the overall distance (in average pixel
    % value) between a target square and source tile.
    dist = redDiff + greenDiff + blueDiff;
end

function srcPixelArr = srcPixelGetter()
    % My image bank, unsplashcombo, currently has all 1175 source images in
    % it. These are to be used as tiles and have already been cropped into 
    % squares using code that I wrote in a different .m file
    unsplashcombo = dir('./source_images_tester/unsplashcombo/*.jpg');
    
    % Number of images in the bank
    n = size(unsplashcombo, 1);
    
    % Created an empty array to hold 3 values for each of the n images.
    % red, green, and blue. Average pixel values.
    srcPixelArr = zeros(3, n);
    
    % Loop through my image bank
    for i = 1:n 
        img = im2double(imread(strcat('./source_images_tester/unsplashcombo/', unsplashcombo(i).name)));
        
        % uncomment to see image size (it's a square already)
        d = size(img, 1);
        
        % Find the average pixel value of the source image at hand
        avgPix_ = mean(mean(img, 1), 2);
        % This returns 3 values if the semicolon is removed. One for red, green, and blue
        
        % Store these in the array source image average pixel value array
        srcPixelArr(1, i) = avgPix_(:, :, 1);
        srcPixelArr(2, i) = avgPix_(:, :, 2);
        srcPixelArr(3, i) = avgPix_(:, :, 3);
        
        % Remove semicolon to see progress (what number image the code is on) in the command window
        picOutOf1175 = i
    end
    % At this point, srcPixelArr should have all 3 color components of the 
    % average pixel value of each of the n source images.
end
