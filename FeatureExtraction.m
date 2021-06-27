function [ featureVector ] = FeatureExtraction( fruitImage )

%adjust image
%accentuate colors
image = imadjust(fruitImage,[.2 .2 .2; .65 .65 .65],[]);

%Convert image to HSV
image = rgb2hsv(image);

%seperate hue, saturation, and value channels
hue = image(:,:,1);
saturation = image(:,:,2);
value = image(:,:,3);
[row, column] = size(saturation);

% threshold the saturation channel
thresh_saturation = saturation > 0.4;


threshold = +thresh_saturation;

%find noise and then fill extra holes
for u = 1:5
    threshold = imclose(threshold,ones(9));
end

threshold = imfill(threshold,'holes');

%find the connected components and take out anything less than 1000 pixels because it is noise and not fruit

connectCompThresh = 1000;
CC = bwconncomp(threshold);

for i = 1:CC.NumObjects
    L = length(CC.PixelIdxList{i});
    if L < connectCompThresh
        threshold(CC.PixelIdxList{i}) = 0;
    end
end

%find the fruit object in the image
CC = bwconncomp(threshold);

% Extract the fruit from the image and ignoring all noises
temp = zeros(row,column);
temp(CC.PixelIdxList{1}) = 1;

%take out the image and other feature of the fruit
stats = regionprops(temp,'Area','Perimeter','BoundingBox','Eccentricity','Centroid','FilledImage');

%get X, Y, Width, Height by getting individual parts of BoundingBox 
%x is the leftmost pixel
x = stats.BoundingBox(1);
x = round(x);

%y is the topmost pixel
y = stats.BoundingBox(2);
y = round(y);

%number of pixels from x to the right
width = stats.BoundingBox(3);
width = round(width);

%number of pixels from y to the bottom
height = stats.BoundingBox(4); 
height = round(height);

sizeOfFruit = [width,height];

%get minimum and maximum width & height vector
[T,maxValue] = max(sizeOfFruit);
[T,minValue] = min(sizeOfFruit);

longValue = sizeOfFruit(maxValue);
shortValue = sizeOfFruit(minValue);


subImgObject = fruitImage(y:(y + height -1),x:(x + width -1),:);

%remove unneccesarry parts
filledImage = stats.FilledImage; 
bIndinces = find(filledImage == 0);

%seperate rgb channels
red = subImgObject(:,:,1);
green = subImgObject(:,:,2);
blue = subImgObject(:,:,3);

%set rgb to white
red(bIndinces) = 255;
green(bIndinces) = 255;
blue(bIndinces) = 255;

rgbComp = cat(3, red, green, blue);

[ color ] = findingFeatures(rgbComp);

featureVector = [stats.Eccentricity, longValue, shortValue, color];

end



