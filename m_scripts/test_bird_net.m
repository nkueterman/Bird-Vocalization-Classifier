close all; clear all; clc;
%% Load network
load('robin_dove_nnet_30epoch.mat')
figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
plot(layerGraph(net))

%% Test group 1
imds1 = imageDatastore('C:\Users\Nathan Kueterman\Documents\MATLAB\ECE567\Term Project - Bird Call Classifier\Mono Spectrograms (10s)\Test\American Robin\Group1');
tic
label = classify(net,imds1);
toc
truth1 = cell(1,114);
truth1(:) = {'American Robin'};
truth1= categorical(truth1)';
preds = nnz(label == truth1);
c1 = confusionmat(truth1,label);


%% Test group 2
imds2 = imageDatastore('C:\Users\Nathan Kueterman\Documents\MATLAB\ECE567\Term Project - Bird Call Classifier\Mono Spectrograms (10s)\Test\American Robin\Group2');

label2 = classify(net,imds2);

truth2 = cell(1,114);
truth2(:) = {'American Robin'};
truth2= categorical(truth2)';
preds2 = nnz(label2 == truth2);
c2 = confusionmat(truth2,label2);

%% Test group 3
imds3 = imageDatastore('C:\Users\Nathan Kueterman\Documents\MATLAB\ECE567\Term Project - Bird Call Classifier\Mono Spectrograms (10s)\Test\Mourning Dove\');

label3 = classify(net,imds3);

truth3 = cell(1,92);
truth3(:) = {'Mourning Dove'};
truth3= categorical(truth3)';
preds3 = nnz(label3 == truth3);
c3 = confusionmat(truth3,label3);
ctotal = c1 + c2 + flipud(fliplr(c3));
classes = {'American Robin','Mourning Dove'};
confusionchart(ctotal,classes,'Title','Shallow Neural Network');