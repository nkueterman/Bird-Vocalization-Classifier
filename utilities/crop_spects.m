% load rect
images = dir('*.png') ;  % Get all images of the folder 
N = length(images) ;     % number of images
labels = readtable('X:\aptos19-udayton\data\train.csv');

labels(labels.diagnosis == 0,:) = [];

% I = imread(images(1).name) ;  % crop one to get rect 
% [x, rect] = imcrop(I) ;

for i = 1:N
    
    curr_file = fullfile(images(i).folder,images(i).name);
    diagnosis = labels.diagnosis(i);
    
    if diagnosis == 1
        movefile(curr_file, 'X:\aptos19-udayton\data\raw\train_images\yes\1');
    elseif diagnosis == 2
        movefile(curr_file, 'X:\aptos19-udayton\data\raw\train_images\yes\2');
    elseif diagnosis == 3
        movefile(curr_file, 'X:\aptos19-udayton\data\raw\train_images\yes\3');
    elseif diagnosis == 4
        movefile(curr_file, 'X:\aptos19-udayton\data\raw\train_images\yes\4');
    end

%     I = imread(images(i).name);   % Read image
%     I = rgb2gray(I);
%     I = imcrop(I,rect) ;           % crop image 
%     I = repmat(I,1,1,3);   
%     I = imresize(I,[512,512]);
    
%     [filepath,name,ext] = fileparts(images(i).name) ;
%     imwrite(I,strcat(name,ext)) ;   % Save image 
    
end
