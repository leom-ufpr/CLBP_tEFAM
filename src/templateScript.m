% Install dependencies
pkg install -forge image
pkg install -forge io
pkg install -forge statistics

% Replace by path to your script files (src folder); make sure it ends with
% forward slash ("/" for either *nix OS or Mac OS X) or backslash
% ("\" for Windows )
srcPath = '/media/marcos/data/Artigos/IA_tax/';
addpath([srcPath 'src/']);

% Replace by path to your image files; make sure it ends with a forward slash
% ("/" for either *nix OS or Mac OS X) or backslash ("\" for Windows )
imgPath = '/home/marcos/Dropbox/microscopia_eletronica/siderastrea/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IMPORTANT! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image files must be named as e.g. CLA1_001_1_1 where:
% CLA1 -> image class, must ALWAYS have 4 alphanumeric characters
% 001 -> voucher identifier; must ALWAYS have 3 digits, pad with zeroes as needed if identifier is numeric 
% 1 -> image scale; one digit at most
% 1 -> replicate; one digit at most
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Replace by path to output (*.m) files to; make sure it ends with forward slash 
% ("/" for either *nix or Mac OS X) or backslash ("\" for Windows )
outPath = '/media/marcos/data/Artigos/IA_tax/mat/'

% Load data if already saved; Jump to the 'tFAM' section if you have loaded data at this point
load ([outPath 'metaDataSid.m'])
load ([outPath 'featureMatrixSid.m'])

% Otherwise, get meta data to be used to compute the feature matrix; The function returns
% two variables:
% metaData = struct matrix with meta data collected from file names
% noClasses = number of data classes from file list
[metaData, noClasses] = parseMetadata(imgPath)

% Backup data just in case; change the file name (quoted string within brackets).
% If needed you may use 'load path_to_file' to restore the variable contents
save ([outPath 'metaDataSid.m'], "metaData")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 'CLBP' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change and use the parameters below only if you know what you are doing!
% Default maximum radius for Minkowisk3D
rmax = 9

% Default parameters for the 'lpb' package
radius = 3
neighbors = 24

% Call script with default parameters and method 'lbp' (Complete Local Binary Pattern)
% Other options are 'lbpSMC' (Sample Multiscale Local Binary Pattern), 'mink' (Minkowski3D) or 'boxCounting';
% The function returns the image descriptors in the variable featureMatrix
[featureMatrix] = computeBPDescriptorsMSB(metaData, srcPath, imgPath, 'lbp', 
  rmax, radius, neighbors)

% Backup data just in case; change the file name (quoted string within brackets).
% If needed you may use 'load path_to_file' to restore the variable contents
% from the file and re-start your analysis in the next step
save ([outPath 'featureMatrixSid.m'], "featureMatrix")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 'tFAM' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default number of principal components, crossvalidation experiments and kfold
% sets; change only if you know what you're doing!
noPrinComp = 35
noExp = 100
kfold = 5

% Get tEFAM results with default parameters; 
[totalPert, totalError] = runtEFAM(srcPath, metaData, noClasses, featureMatrix, 
  noPrinComp, noExp, kfold)

% Save your data in MatLab 7 binary format
save ('-7', [outPath 'totalPertSid.m'], "totalPert")
save ('-7', [outPath 'totalErrorSid.m'], "totalError")

% Output mean and standard error of total error
mean(totalError)
std(totalError)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
