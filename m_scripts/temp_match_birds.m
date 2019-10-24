clear all; close all; clc;

%% Load in bird clips
load('dove_signature.mat');
dove_sig = clip(1:441000,:);
load('robin_signature.mat');
robin_sig = clip(1:441000,:);
load('all_calls_dove_robin.mat');
test_calls = call_mat(1:441000,:);
sigs = horzcat(dove_sig,robin_sig);

%% Index the truth information
dove_ix = 1:466;
robin_ix = 467:922;
truth = zeros(1,922);
truth(:,dove_ix) = 1;

%% SAM template match and evaluation
tic
sam_vec = (sigs' * test_calls) ./ (sqrt(sum(sigs.^2)) * repmat(sqrt(sum(test_calls.^2)),2,1));
toc
figure
plot(sam_vec(1,:))
hold on;
plot(sam_vec(2,:))
axis([0 922 -.03 .03])
title('SAM Score of Doves vs Robins')
xlabel('Bird Call Samples')
legend('Mourning Dove','American Robin')
hold off;

% Predict classes
same = nnz(sam_vec(1,:) == sam_vec(2,:));
preds = double(abs(sam_vec(1,:)) > abs(sam_vec(2,:)));

% Determine accuracy
c = confusionmat(truth,preds);
classes = {'American Robin','Mourning Dove'};
confusionchart(c,classes,'Title','SAM Classification');