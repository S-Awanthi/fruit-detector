function[ color ] = findFeatures(image)

color = NaN;
img = rgb2hsv(image);
edge = [1, 13, 42, 70, 167,252, 306];
img = img*360;
[y,x,~] = size(img);

hue_img = img(:,:,1);
[N,Bins] = histc(hue_img(:),edge);
color = find(N==max(N));

assignin('base','hue_img',hue_img);
end