# Bird Vocalization Classifier
 Transfer learning approach to classifying species via bird vocalization audio spectrograms.
 


## Abstract
Deep learning is an emerging field that has shown promising results for image classification.  The focus of this study was to analyze the performance of modern machine learning algorithms in the application of classifying bird species from recorded calls.  Bird songs are specific to each species and have a distinct signature, which was the aspect of the data being leveraged.  The data set was collected by various bird enthusiasts and uploaded to xeno-canto.org where the files are open to the public. Statistical analysis was performed on these calls and predictions were made on which species produced the audio which were limited to American Robins and Mourning Doves.  An audio spectrogram served as the input image to the neural networks while the raw audio signal was used for template matching.  The technique that had the highest accuracy was the transfer learning approach, which utilized the pre-existing neural network known as AlexNet.  The shallow neural net had a slightly lower accuracy, while the rudimentary Spectral Angle Mapper (SAM) classifier performed at the lowest accuracy.  All the classification techniques utilized have associated trade-offs which are explored in the conclusion of this study.


Keywords—machine learning, deep learning, spectrogram, neural network, birds, classification, bioacoustics, epoch, batch normalization, Rectified Linear Units (ReLU)
