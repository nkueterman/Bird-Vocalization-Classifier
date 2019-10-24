% Load data
spectPath = 'C:\Users\Nathan Kueterman\Documents\MATLAB\ECE567\Term Project - Bird Call Classifier\Mono Spectrograms (10s)\2 Class\';
imds = imageDatastore(spectPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');

% Determine amount of labels
labelCount = countEachLabel(imds)

% Detect image size
img = readimage(imds,1);
size(img)

% Segment training/validation data
numTrainFiles = 300;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

% Construct network
layers = [
    imageInputLayer([656 875 3])
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

% Determine training options
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',30, ...
    'MiniBatchSize',32, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');

% Train network
net = trainNetwork(imdsTrain,layers,options);
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

% accuracy = sum(YPred == YValidation)/numel(YValidation)

