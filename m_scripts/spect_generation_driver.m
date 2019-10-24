% Define data to process
path = 'C:\Users\Nathan Kueterman\Documents\MATLAB\ECE567\Term Project - Bird Call Classifier\Raw Calls\Test\Mourning Dove\';
savepath = 'C:\Users\Nathan Kueterman\Documents\MATLAB\ECE567\Term Project - Bird Call Classifier\Mono Spectrograms (10s)\Test\Mourning Dove\';
folder = dir(path);
interval = 10;

% Call spectrogram generating function
for idx = 3:length(folder)
    save_spects(folder(idx).name,savepath,interval)
end