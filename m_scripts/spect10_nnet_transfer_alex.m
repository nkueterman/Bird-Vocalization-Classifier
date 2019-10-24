% Load data
spectPath = 'C:\Users\Nathan Kueterman\Documents\MATLAB\ECE567\Term Project - Bird Call Classifier\Mono Spectrograms (10s)\2 Class\';
imds = imageDatastore(spectPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');

% Determine amount of labels
numClasses = size(countEachLabel(imds),2);

% Detect image size
img = readimage(imds,1);
size(img)

% Segment training/validation data
numTrainFiles = 300;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

% Load pretrained network
net = alexnet;

% Detect input size
inputSize = net.Layers(1).InputSize

% Define transfer layers
layersTransfer = net.Layers(1:end-3);

% Construct network
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

% pixelRange = [-30 30];
% imageAugmenter = imageDataAugmenter( ...
%     'RandXReflection',true, ...
%     'RandXTranslation',pixelRange, ...
%     'RandYTranslation',pixelRange);

% Augment the data for AlexNet
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain);
%     'DataAugmentation',imageAugmenter);
augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);

% Define training options
options = trainingOptions('sgdm', ...
    'MiniBatchSize',10, ...
    'MaxEpochs',6, ...
    'InitialLearnRate',1e-4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',3, ...
    'Verbose',false, ...
    'Plots','training-progress');

% Train network
netTransfer = trainNetwork(augimdsTrain,layers,options);

[YPred,scores] = classify(netTransfer,augimdsValidation);

YValidation = imdsValidation.Labels;
accuracy = mean(YPred == YValidation);