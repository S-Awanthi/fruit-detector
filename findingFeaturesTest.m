clear all; close all;

%load the image
rgbImage = imread('1.jpg');
 
%display image with title
figure, imshow(rgbImage);
title('Original RGB Image');
 
%get colormap of current image
mapRGB = colormap(figure);
close all;
 
%convert rgb image to hsv
hsvImage = rgb2hsv(rgbImage);

mapHSV = rgb2hsv(mapRGB);

[ Color ] = findingFeatures(hsvImage)