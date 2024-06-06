# CLBP_tEFAM
Matlab/Octave implementation of IA discrimination of Scleractinian coral species from Scanning Electronic Microscopy (SEM) images.

Download repository into a suitable folder (this README assumes that you have cloned it into your Linux home folder):
```
git clone https://github.com/leom-ufpr/CLBP_tEFAM
```

Scripts run in Matlab/GNU Octave. Matlab is paid software, Octave is freely distributed. Octave installation packages and intructions are in https://octave.org/download and https://wiki.octave.org/Category:Installation.

Once installed, open Matlab/Octave console and install dependencies (needs to be done only **once** after installation):
```
pkg install -forge image
pkg install -forge io
pkg install -forge statistics
```

Define the source path as **your** cloned `src` folder; make sure it ends with forward slash `/` for either *nix OS or Mac OS X or backslash `\` for Windows:
```
srcPath = '~/CLBP_tEFAM/src/'
```

Define the image path as **your** `image` folder; make sure it ends with forward slash `/` for either *nix OS or Mac OS X or backslash `\` for Windows. The images supplied in the repository correspond to SEMs of *Siderastrea* spp. coralla and should be used as a test example. The full dataset may be downloaded from http://morphobank.org/permalink/?P5258:
```
imgPath = '~/CLBP_tEFAM/images/'
```

**IMPORTANT!**
Image files must in *TIFF* format and  be named as `CLA1_001_1_1` where:

- CLA1 -> image class, must *always* have 4 alphanumeric characters;
- 001 -> voucher identifier; must *always* have 3 digits, pad with zeroes as needed if identifier is numeric;
- 1 -> image scale; one digit at most;
- 1 -> replicate; one digit at most;

Define output path; make sure it ends with forward slash (`/` for either *nix or Mac OS X) or backslash (`\` for Windows ):
```
outPath = '~/CLBP_tEFAM/mat/'
```
Get metadata needed to to compute the feature matrix; The function returns two variables:

`metaData` = struct matrix with meta data collected from file names

`noClasses` = number of data classes (=species) from file list
```
[metaData, noClasses] = parseMetadata(imgPath)
```

Backup the metadata just in case; change the file name if needed (quoted string within brackets):
```
save ([outPath 'metaDataSid.m'], "metaData")
```

If needed you may use `load` to restore `metaData`:
```
load ([outPath 'metaDataSid.m'])
```

## TEXTURE DESCRIPTORS
**Change the parameters below only if you know what you are doing!**  
Set default maximum radius for *Minkowisk 3D*; ignore this line if using descriptors computedan algorithm other than `mink` (default is `lbp`):
```
max = 9
```

Set default parameters for the `lpb` or `lbpSMC` algorithms
```
radius = 3
neighbors = 24
```

Call script that computes texture descriptors with default parameters and method `lbp` (*Complete Local Binary Pattern*). Other options are `lbpSMC` (*Sample Multiscale Local Binary Pattern*), `mink` (*Minkowski 3D*) or `boxCounting` (*Fractal Dimensions*) . The function stores the image descriptors in the variable `featureMatrix`:
```
[featureMatrix] = computeBPDescriptorsMSB(metaData, srcPath, imgPath, 'lbp', rmax, radius, neighbors)
```

Backup descriptor data just in case; change the file name if needed (quoted string within brackets).
```
save([outPath 'featureMatrixSid.m'], "featureMatrix")
```

If needed you may use `load` to restore `featureMatrix` from the file:
```
load ([outPath 'featureMatrixSid.m'])
```

You may also save descriptors as a CSV file:
```
csvwrite([outPath 'clbpSid.csv'], [featureMatrix' metaDataSid'])
```

## NEURAL NETWORK - tEFAM
**Change the parameters below only if you know what you are doing!**  
Set default number of principal components as `noPrinComp', cross-validation experiments as `noExp` and k-fold sets as `kfold` :
```
noPrinComp = 35
noExp = 100
kfold = 5
```

Get tEFAM results with default parameters: 
```
[tEFAMResults, tEFAMError] = runtEFAM(srcPath, metaData, noClasses, featureMatrix, noPrinComp, noExp, kfold)
```

Backup your results in Matlab 7 binary format:
```
save('-7', [outPath 'tEFAMResultsSid.m'], "tEFAMResults")
save('-7', [outPath 'tEFAMErrorSid.m'], "tEFAMError")
```

Output mean and standard deviation of classification error:
```
mean(tEFAMError)
std(tEFAMError)
```
