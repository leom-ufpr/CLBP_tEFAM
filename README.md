# CLBP_tEFAM
Matlab/Octave implementation of IA discrimination of Scleractinian coral species from SEM images

Packages run in Matlab/GNU Octave. Matlab is paid software, Octave is freely distributed. Octave installation packages and intructions are in https://octave.org/download and https://wiki.octave.org/Category:Installation.

Open Matlab/Octave console and install dependencies (needs to be done only once after installation)
```
pkg install -forge image
pkg install -forge io
pkg install -forge statistics
```

Define the source path as your cloned src folder; make sure it ends with forward slash ("/" for either *nix OS or Mac OS X) or backslash ("\" for Windows )
```
srcPath = '/media/marcos/data/Artigos/IA_tax/'
addpath([srcPath 'src/'])
```

Define the image path as your cloned image folder make sure it ends with a forward slash ("/" for either *nix OS or Mac OS X) or backslash ("\" for Windows )
```
imgPath = '/home/marcos/Dropbox/microscopia_eletronica/siderastrea/';
```

**IMPORTANT!**
Image files must be named as e.g. CLA1_001_1_1 where:

CLA1 -> image class, must ALWAYS have 4 alphanumeric characters
001 -> voucher identifier; must ALWAYS have 3 digits, pad with zeroes as needed if identifier is numeric 
1 -> image scale; one digit at most
1 -> replicate; one digit at most

Define output path; make sure it ends with forward slash ("/" for either *nix or Mac OS X) or backslash ("\" for Windows )
```
outPath = '/media/marcos/data/Artigos/IA_tax/mat/'
```

Load data if already saved; Jump to the **NEURAL NETWORK** section if you have loaded data at this point
```
load ([outPath 'metaDataSid.m'])
load ([outPath 'featureMatrixSid.m'])
```

Otherwise, get meta data to be used to compute the feature matrix; The function returns two variables: 
>metaData = struct matrix with meta data collected from file names
>noClasses = number of data classes from file list
```
[metaData, noClasses] = parseMetadata(imgPath)
```

Backup the metadata just in case. If needed you may use 'load path_to_file' to restore the variable contents
save ([outPath 'metaDataSid.m'], "metaData")

## TEXTURE DESCRIPTORS
**Change and use the parameters below only if you know what you are doing!**  
Set default maximum radius for Minkowisk3D; ignore this line if using a different method (default = 'lbp')
```
max = 9
```

Set default parameters for the 'lpb*' algorithms
```
radius = 3
neighbors = 24
```

Call script that computes texture descriptors with default parameters and method 'lbp' (Complete Local Binary Pattern). Other options are 'lbpSMC' (Sample Multiscale Local Binary Pattern), 'mink' (Minkowski3D) or 'boxCounting'. The function stores the image descriptors in the variable `featureMatrix`
```
[featureMatrix] = computeBPDescriptorsMSB(metaData, srcPath, imgPath, 'lbp', rmax, radius, neighbors)
```

Backup descriptor data just in case; change the file name (quoted string within brackets). If needed you may use `load path_to_file` to restore the variable contents from the file and re-start your analysis in the next step 
```
save ([outPath 'featureMatrixSid.m'], "featureMatrix")
```

You may also save the decriptors as a CSV file
```
csvwrite('/media/taioba/Data/Artigos/IA_tax/csv/descLBPSMC_Porites.csv',[data' groups']);
```

## NEURAL NETWORK - thetaFAM
**Change and use the parameters below only if you know what you are doing!**  
Default number of principal components, crossvalidation experiments and kfold sets
```
noPrinComp = 35
noExp = 100
kfold = 5
```

Get thetaFAM results with default parameters; 
```
[totalPert, totalError] = runtEFAM(srcPath, metaData, noClasses, featureMatrix, noPrinComp, noExp, kfold)
```

Backup your results in MatLab 7 binary format
```
save ('-7', [outPath 'totalPertSid.m'], "totalPert")
save ('-7', [outPath 'totalErrorSid.m'], "totalError")
```

Output mean and standard error of total error
```
mean(totalError)
std(totalError)
```
