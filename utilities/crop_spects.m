% load rect
images = dir('*.png') ;  % Get all images of the folder 
N = length(images) ;     % number of images

I = imread(images(1).name) ;  % crop one to get rect 
[x, rect] = imcrop(I) ;

for i = 1:N
    
    curr_file = fullfile(images(i).folder,images(i).name);
    diagnosis = labels.diagnosis(i);

    I = imread(images(i).name);   % Read image
    I = rgb2gray(I);
    I = imcrop(I,rect) ;           % crop image 
    I = repmat(I,1,1,3);   
    I = imresize(I,[512,512]);
    
    [filepath,name,ext] = fileparts(images(i).name) ;
    imwrite(I,strcat(name,ext)) ;   % Save image 
    
end
