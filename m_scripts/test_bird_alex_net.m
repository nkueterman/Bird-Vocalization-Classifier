%% Load network
load('robin_dove_alexnet_6epoch.mat')

%% Test group 1
imds1 = imageDatastore('C:\Users\Nathan Kueterman\Documents\MATLAB\ECE567\Term Project - Bird Call Classifier\Mono Spectrograms (10s)\Test\American Robin\Group1');
aimds1 = augmentedImageDatastore([227 227],imds1);
tic
label = classify(netTransfer,aimds1);
toc
truth1 = cell(1,114);
truth1(:) = {'American Robin'};
truth1= categorical(truth1)';
preds = nnz(label == truth1);
c1 = confusionmat(truth1,label);


%% Test group 2
imds2 = imageDatastore('C:\Users\Nathan Kueterman\Documents\MATLAB\ECE567\Term Project - Bird Call Classifier\Mono Spectrograms (10s)\Test\American Robin\Group2');
aimds2 = augmentedImageDatastore([227 227],imds2);
label2 = classify(netTransfer,aimds2);

truth2 = cell(1,114);
truth2(:) = {'American Robin'};
truth2= categorical(truth2)';
preds2 = nnz(label2 == truth2);
c2 = confusionmat(truth2,label2);

%% Test group 3
imds3 = imageDatastore('C:\Users\Nathan Kueterman\Documents\MATLAB\ECE567\Term Project - Bird Call Classifier\Mono Spectrograms (10s)\Test\Mourning Dove\');
aimds3 = augmentedImageDatastore([227 227],imds3);
label3 = classify(netTransfer,aimds3);

truth3 = cell(1,92);
truth3(:) = {'Mourning Dove'};
truth3= categorical(truth3)';
preds3 = nnz(label3 == truth3);
c3 = confusionmat(truth3,label3);
ctotal = c1 + c2 + flipud(fliplr(c3));
classes = {'American Robin','Mourning Dove'};
confusionchart(ctotal,classes,'Title','AlexNet Transfer Learning')