%% Did not end up using this
% Load data
datafolder = 'C:\Users\Nathan Kueterman\Documents\MATLAB\ECE567\Term Project - Bird Call Classifier\Raw Calls\';
ads = audioDatastore(datafolder, ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.mp3', ...
    'LabelSource','foldernames')
ads0 = copy(ads);

segmentDuration = 15;
frameDuration = 0.25;
hopDuration = 0.10;
numBands = 40;

epsil = 1e-6;

XTrain = speechSpectrograms(adsTrain,segmentDuration,frameDuration,hopDuration,numBands);
XTrain = log10(XTrain + epsil);

XValidation = speechSpectrograms(adsValidation,segmentDuration,frameDuration,hopDuration,numBands);
XValidation = log10(XValidation + epsil);

XTest = speechSpectrograms(adsTest,segmentDuration,frameDuration,hopDuration,numBands);
XTest = log10(XTest + epsil);

YTrain = adsTrain.Labels;
YValidation = adsValidation.Labels;
YTest = adsTest.Labels;