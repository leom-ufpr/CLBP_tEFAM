% Replace by path to your script files (src folder); make sure it ends with
% forward slash ("/" for either *nix OS or Mac OS X) or backslash
% ("\" for Windows )
srcPath = '/media/taioba/Data/Artigos/IA_tax/';
dataPath = '/media/taioba/Data/UFPR/2017_flavio/csv/';

% Replace by path to output (*.m) files; make sure it ends with forward slash 
% ("/" for either *nix or Mac OS X) or backslash ("\" for Windows )
outPath = '/media/taioba/Data/Artigos/IA_tax/mat/';

% Get meta data to be used to compute the feature matrix; The function returns
% two variables:
% metaData = struct matrix with meta data collected from file names
% noClasses = number of data classes from file list
%
% Image files must be named as e.g. CLA1_001_1_1 where:
% CLA1 -> image class, must ALWAYS have 4 characters
% 001 -> individual number; must ALWAYS have 3 digits, pad with zeroes as needed
% 1 -> image scale; one digit at most
% 1 -> replicate; one digit at most
files = csv2cell( [dataPath 'mock_files.csv'] )
[metaData, noClasses] = parseMockMetadata(files);

% Change and use the parameters below only if you know what you are doing!
% Default maximum radius for Minkowisk3D
rmax = 9;

% Default parameters for the LPB package
radius = 3;
neighbors = 24;

% Load data if already saved; SKIP TO COMMENT STARTING WITH 'NEURAL NETWORK' 
% if you loaded data at this point
load ([outPath 'metaDataPor.m'])
load ([outPath 'featureMatrixPor.m'])

% Call script with default parameters and method 'lbp' (Local Binary Pattern)
% Other options are 'lbpSMC' (???????), mink (Minkowski3D) or boxCounting;
% The function returns the image descriptors in the variable featureMatrix
[featureMatrix] = computeBPDescriptorsMSB(metaData, srcPath, imgPath, 'lbpSMC', 
  rmax, radius, neighbors);

% Backup data just in case; change the file name (quoted string within brackets).
% If neededm you may use 'load path_to_file' to restore the variable contents
% and re-start your analysis in the next step
save ([outPath 'metaDataPor.m'], "metaData");
save ([outPath 'featureMatrixPor.m'], "featureMatrix");

% 'NEURAL NETWORK'
% Default number of principal components, crossvalidation experiments and kfold
% sets; change only if you know what you're doing!
noPrinComp = 35;
noExp = 100;
kfold = 5;

% Get tEFAM results with default parameters; 
[totalPert, totalError] = runtEFAM(srcPath, metaData, noClasses, featureMatrix, 
  noPrinComp, noExp, kfold);

% Save you data in MatLab 7 binary format
save ('-7', [outPath 'totalPertPor.m'], "totalPert");
save ('-7', [outPath 'totalErrorPor.m'], "totalError");

% Output mean and standard error of total error
mean(totalError);
std(totalError);