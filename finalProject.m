clear all;
close all;
clc;

%Read image
fruitImage = imread('database/s (5).jpg');
figure(1),imshow(fruitImage);
title('Original image')

%Initializing fruit training model
load('featureVectors.mat');
mdl = ClassificationKNN.fit(vector,Y,'NumNeighbors',3);

%initialize feature vector
KaruthakolombanCount= 0;
AtambaCount = 0;
StarFruitCount=0;
vector = zeros(1,4);
%R = zeros(1,4);

%adjust image
image = imadjust(fruitImage,[.2 .2 .2; .65 .65 .65],[]);

%Convert image to HSV to be able to take Saturation channel
img = rgb2hsv(image);


%grab the seperate hue, saturation, and value channels
hue = img(:,:,1);
saturation = img(:,:,2);
value = img(:,:,3);
[row, column] = size(saturation);

% threshold the saturation channel of the image
thresh_saturation = saturation > 0.4;

%convert from logical to double
threshold = +thresh_saturation;

%perform close to close holes and then fill in any extra holes
for u = 1:5
    threshold = imclose(threshold,ones(9));
end
threshold = imfill(threshold,'holes');


figure(2), imshow(threshold)
title('Thresholded image')
figure(3), imshow(img)
title('HSV image')

%find the connected components and take out anything less than 
%1000 pixels because it is noise and not fruit
connectCompThresh = 1000;
CC = bwconncomp(threshold);
 
for i = 1:CC.NumObjects
    L = length(CC.PixelIdxList{i});
    if L < connectCompThresh
        threshold(CC.PixelIdxList{i}) = 0;
    end
end

figure(4), imshow(threshold)
title('Connected Component thresholded Image')

%find the fruit in the image
CC = bwconncomp(threshold);

%create a label matrix, may be unneccesarry
label = 1;
label_matrix = zeros(row,column);
for n = 1:CC.NumObjects
     label_matrix(CC.PixelIdxList{n}) = label;
     label = label + 1;
end

% Extract the fruit from the image, loops around for each individual fruit
for i = 1:CC.NumObjects
    %get an image with the individual fruit in the image ignoring all
    %others
    temp = zeros(row,column);
    temp(CC.PixelIdxList{i}) = 1;
    figure, imshow(temp)
    title('Indiviual Fruit that was extracted out')
  
 %Use regionprops to get the bounding box to take out the image and
    %other feature of the fruit
    stats = regionprops(temp,'Area','Perimeter','BoundingBox','Eccentricity','Centroid','FilledImage');
   
%Put the bounding box that was detected onto the image
    hold on
    rectange = rectangle('Position', stats.BoundingBox, 'EdgeColor','r');
    hold off

%x is the leftmost pixel for the CC
    x = stats.BoundingBox(1);
    x = round(x);
    
   %y is the topmost pixel for the CC
    y = stats.BoundingBox(2);
    y = round(y);
    
    %width is the number of pixels from x to the right
    width = stats.BoundingBox(3);
    width = round(width);
    
    %width is the number of pixels from y to the bottom of the image
    height = stats.BoundingBox(4); 
    height = round(height);
    
    sizeOfFruit = [width,height]; 
    
    %orientation problem
    [T,maxValue] = max(sizeOfFruit);
    [T,minValue] = min(sizeOfFruit);
    
    longValue = sizeOfFruit(maxValue);
    shortValue = sizeOfFruit(minValue);
    
    %get the top left, top right, bottom left, bottom right coordinates
    topLeftCorner = [x, y];
    topRightCorner = [x + width, y];
    bottomLeftCorner = [x, y + height];
    bottomRightCorner = [x + width, y + height];
    
    %crop out the sub image to send to knn and feature selection
    subImgObject = fruitImage(y:(y + height -1),x:(x + width -1),:);
    
    %Threshold the unneccesarry parts in the RGB to white
    filledImage = stats.FilledImage; 
    bIndinces = find(filledImage == 0);
    
    %seperate out each channel in the rgb and set it equal to white
    red = subImgObject(:,:,1);
    green = subImgObject(:,:,2);
    blue = subImgObject(:,:,3);
    
    red(bIndinces) = 255;
    green(bIndinces) = 255;
    blue(bIndinces) = 255;
    
    rgbComp = cat(3, red, green, blue);
    figure,imshow(rgbComp)
    title('Segmented out RGB fruit with white surrounding')
    
    figure,imshow(fruitImage(y:(y + height),x:(x + width),:));
    title('Segmented out RGB fruit')
    
    [ color ] = findingFeatures(rgbComp);
    Xnew = [stats.Eccentricity, longValue/1000, shortValue/1000, color/3];
    vector(i,:) = Xnew;
    
    % returns a matrix of scores, indicating the likelihood that a label comes 
    % from a particular class.
    [label,POSTERIOR, score] = predict(mdl,Xnew);
    
    %get fruit count
    switch label
       case 'a'
           AtambaCount= AtambaCount+1;
           figure(1),text(x,y,'Atamba');
   
       case 'k'
          KaruthakolombanCount = KaruthakolombanCount +1;
          figure(1),text(x,y,'Karauththakolamban');
          
        case 's'
          StarFruitCount = StarFruitCount +1;
          figure(1),text(x,y,'StarFruit');
       
    end
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    



