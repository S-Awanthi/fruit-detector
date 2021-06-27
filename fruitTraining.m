clear all
close all
clc

%initializing the filter
vector = zeros(1,2);

%train Atamba
for i = 1:48
    fruitImage = imread(strcat(['database/ ',num2str(i),'.jpg']));
    [ featureVector ] = FeatureExtraction( fruitImage );
    vector(i - 48,:) = featureVector;
    Y(i - 48,:) = 'a';
end

%train Karuthakolomban
for i = 49:131
    fruitImage = imread(strcat(['database/ ',num2str(i),'.jpg']));
    [ featureVector ] = FeatureExtraction( fruitImage );
    vector(i - 131,:) = featureVector;
    Y(i - 131,:) = 'k';
end

%train StarFruit
for i = 132:231
    fruitImage = imread(strcat(['database/ ',num2str(i),'.jpg']));
    [ featureVector ] = FeatureExtraction( fruitImage );
    vector(i - 231,:) = featureVector;
    Y(i - 231,:) = 's';
end

save('featureVectors.mat', 'vector', 'Y');

%%
clear all
close all
clc

load('featureVectors.mat');

mdl = ClassificationKNN.fit(vector,Y,'NumNeighbors',3);

[label,POSTERIOR, score] = ClassificationKNN.predict(mdl,Xnew);





