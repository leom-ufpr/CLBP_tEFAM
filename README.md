# CLBP_tEFAM
Matlab/Octave implementation of IA discrimination of Scleractinian coral species from Scanning Electronic Microscopy (SEM) images.

Download repository into a suitable folder. This example assumes that you have cloned it into your *nix/MacOS home folder, whose alias is `~`:
```
git clone https://github.com/leom-ufpr/CLBP_tEFAM
```

Scripts run in Matlab/GNU Octave. Matlab is paid software, Octave is freely distributed. Octave installation packages and instructions are in https://octave.org/download and https://wiki.octave.org/Category:Installation.

Once installed, open Matlab/Octave console and install dependencies (needs to be done only **once** after installation):
```
pkg install -forge image
pkg install -forge io
pkg install -forge statistics
```

Load io package
```
pkg load io
```

Define the source path as **your** cloned `src` folder. Make sure it ends with forward slash `/` if using *nix/MacOS or backslash `\` if using Windows:
```
srcPath = '~/CLBP_tEFAM/';
addpath([srcPath, 'src/']);
```

Define the image path as **your** `images` folder. The test images supplied in this repository are intended to ensure that the scripts will run in your system. If you would like to reproduce the results in the original publication, download them from http://morphobank.org/permalink/?P5258:
```
imgPath = '~/CLBP_tEFAM/images/';
```

**IMPORTANT!**
Image files must be in *TIFF* format and must be named as e.g. `CLA1_001_1_1` where:

- CLA1 -> image class, must *always* have 4 alphanumeric characters;
- 001 -> voucher identifier; must *always* have 3 digits: pad with zeroes as needed if identifier is numeric;
- 1 -> image scale; one digit at most;
- 1 -> replicate; one digit at most;

Define output path as **your** output folder:
```
outPath = '~/CLBP_tEFAM/mat/';
```
Get metadata needed to to compute the feature matrix. The function will return two variables:

`metaData` = struct matrix with meta data collected from file names

`noClasses` = number of data classes (=taxa) from file list
```
[metaData, noClasses] = parseMetadata(imgPath);
```

Backup the metadata just in case. Change the file name (quoted string within brackets) if needed:
```
save ([outPath 'metaDataTest.m'], "metaData");
```

You may then use `load` to restore `metaData`:
```
load ([outPath 'metaDataTest.m']);
```

## TEXTURE DESCRIPTORS
**Change the parameters below only if you know what you are doing!**  
Set default maximum radius for *Minkowisk 3D*:
```
rmax = 9;
```

Set default parameters for the `lpb` or `lbpSMC` algorithms:
```
radius = 3;
neighbors = 24;
```

Call script that computes texture descriptors (TD) using  either `lbp` (*Local Binary Pattern*), `lbpSMC` (*Complete Local Binary Pattern*), `mink` (*Minkowski 3D*) or `boxCounting` (*Fractal Dimensions*) . The function stores the image descriptors in `featureMatrix`:
```
[featureMatrix] = computeBPDescriptorsMSB(metaData, srcPath, imgPath, 'lbpSMC', rmax, radius, neighbors);
```

Backup TD data:
```
save([outPath 'featureMatrixTest.m'], "featureMatrix");
```

You may now use `load` to restore `featureMatrix` from the file, if you need to:
```
load([outPath 'featureMatrixTest.m']);
```

You may also export descriptors as a CSV file. The `group` column in the resulting CSV file numerically codes the taxa:
```
exportTDCSV(metaData, featureMatrix, outPath, 'featureMatrixTest.csv');
```

## NEURAL NETWORK - tEFAM
**Change the parameters below only if you know what you are doing!**  
Set number of principal components as `noPrinComp`, cross-validation experiments as `noExp` and k-fold sets as `kfold`:
```
noPrinComp = 35;
noExp = 100;
kfold = 5;
```

Get tEFAM results with default parameters: 
```
[tEFAMResults, tEFAMError] = runtEFAM(srcPath, metaData, noClasses, featureMatrix, noPrinComp, noExp, kfold);
```

Backup your results in Matlab 7 binary format:
```
save('-7', [outPath 'tEFAMResultsTest.m'], "tEFAMResults");
save('-7', [outPath 'tEFAMErrorTest.m'], "tEFAMError");
```

You may also export tEFAMResults as CSV. The `group_*` columns correspond to the individual pertinence to each possible class (=taxon):
```
exporttEFAMCSV( tEFAMResults, outPath, 'tEFAMResults.csv' )
```

Output mean and standard deviation of classification error:
```
mean(tEFAMError)
std(tEFAMError)
```