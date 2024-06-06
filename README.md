# CLBP_tEFAM
Matlab/Octave implementation of IA discrimination of Scleractinian coral species from SEM images

Packages run in Matlab/GNU Octave. Matlab is paid software, Octave is freely distributed. Octave installation packages and intructions are in https://octave.org/download and https://wiki.octave.org/Category:Installation.

Once installed, open Matlab/Octave console and install dependencies (needs to be done only once after installation):
```
pkg install -forge image
pkg install -forge io
pkg install -forge statistics
```

Clone repository to a suitable folder:
```
git clone https://github.com/leom-ufpr/CLBP_tEFAM
```

Define the source path as **your** cloned `src` folder; make sure it ends with forward slash `/` for either *nix OS or Mac OS X or backslash `\` for Windows:
```
srcPath = '~/CLBP_tEFAM'
addpath([srcPath 'src/'])
```

Define the image path as **your** cloned image folder; make sure it ends with forward slash `/` for either *nix OS or Mac OS X or backslash `\` for Windows:
```
imgPath = '~/CLBP_tEFAM/images'
```

**IMPORTANT!**
Image files must be named as `CLA1_001_1_1` where:

- CLA1 -> image class, must ALWAYS have 4 alphanumeric characters
- 001 -> voucher identifier; must ALWAYS have 3 digits, pad with zeroes as needed if identifier is numeric 
- 1 -> image scale; one digit at most
- 1 -> replicate; one digit at most

Define output path; make sure it ends with forward slash ("/" for either *nix or Mac OS X) or backslash ("\" for Windows ):
```
outPath = '/media/marcos/data/Artigos/IA_tax/mat/'
```

Load data if already saved; jump to the **NEURAL NETWORK** section if you have loaded data at this point:
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

Backup the metadata just in case. If needed you may use 'load path_to_file' to restore the variable contents:
```
save ([outPath 'metaDataSid.m'], "metaData")
```

## TEXTURE DESCRIPTORS
**Change and use the parameters below only if you know what you are doing!**  
Set default maximum radius for Minkowisk3D; ignore this line if using a decriptor other than 'mink' method (default = 'lbp'):
```
max = 9
```

Set default parameters for the 'lpb*' algorithms
```
radius = 3
neighbors = 24
```

Call script that computes texture descriptors with default parameters and method `lbp` (Complete Local Binary Pattern). Other options are `lbpSMC` (Sample Multiscale Local Binary Pattern), `mink` (Minkowski3D) or `boxCounting`. The function stores the image descriptors in the variable `featureMatrix`:
```
[featureMatrix] = computeBPDescriptorsMSB(metaData, srcPath, imgPath, 'lbp', rmax, radius, neighbors)
```

Backup descriptor data just in case; change the file name (quoted string within brackets). If needed you may use `load` to restore `featureMatrix` from the file and re-start your analysis in the next step:
```
save([outPath 'featureMatrixSid.m'], "featureMatrix")
```

You may also save descriptors as a CSV file:
```
csvwrite([outPath 'clbpSid.csv'], [data' groups'])
```

## NEURAL NETWORK - tEFAM
**Change and use the parameters below only if you know what you are doing!**  
Set default number of principal components as `noPrinComp', cross-validation experiments as `noExp` and k-fold sets as `kfold` :
```
noPrinComp = 35
noExp = 100
kfold = 5
```

Get tEFAM results with default parameters: 
```
[totalPert, totalError] = runtEFAM(srcPath, metaData, noClasses, featureMatrix, noPrinComp, noExp, kfold)
```

Backup your results in MatLab 7 binary format:
```
save('-7', [outPath 'totalPertSid.m'], "totalPert")
save('-7', [outPath 'totalErrorSid.m'], "totalError")
```

Output mean and standard deviation of classification errors:
```
mean(totalError)
std(totalError)
```
