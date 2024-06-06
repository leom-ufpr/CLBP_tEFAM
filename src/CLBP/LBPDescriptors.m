function featureMatrix = LBPDescriptors(imgPath, srcPath, dataClasses, type, radius, neighbors, varargin)

% Parsing optional input:
options = struct('typeNoise','G','levelNoise',0);
optionNames = fieldnames(options);
nArgs = length(varargin);

if round(nArgs/2)~=nArgs/2
   error('Optional arguments are propertyName/propertyValue pairs')
end

for pair = reshape(varargin,2,[]) %# pair is {propName;propValue}
   inpName = pair{1}; %# make case insensitive
   if any(strcmp(inpName,optionNames))
      options.(inpName) = pair{2};
   else
      error('%s is not a recognized parameter name',inpName);
   end
end

R=radius;
P=neighbors;

% Load pre-computed struct from file if exists
mappingFile = sprintf( '%s%s%d%s', srcPath, 'src/mapping', P, 'riu2.m' );
if exist( mappingFile ) == 2
  display("Will load mapping from file, please wait...")
  load ( mappingFile )
else
  display("Will compute mapping from scratch, please wait...")
  patternMappingriu2 = getmapping(P,'riu2');
  save( "-zip", mappingFile, "patternMappingriu2" );
endif

k=1;
dataClassesSize=size(dataClasses,1);
VARH = [];LBPH = [];LBP=[];VAR=[];LBP_VLH=[];

h = waitbar (0, '0.00%');
for i=1:dataClassesSize
    imgFraction = i/dataClassesSize;
    waitbar(imgFraction, h, sprintf ('%.2f%%', 100*imgFraction) ); 
        
    Gray = imread([imgPath dataClasses{i,1}]);
    if length(size(Gray)) > 2 % color images
        Gray = rgb2gray(Gray);
    endif    

    Gray = im2double(Gray);
    if options.levelNoise ~= 0
		  if options.typeNoise == 'G'
	      Gray2 = imnoise(Gray,'gaussian',0,options.levelNoise);
		  endif
		  if options.typeNoise == 'S'
	      Gray2 = imnoise(Gray,'salt & pepper',options.levelNoise);
		  endif
      Gray = Gray2;
    endif
    
    Gray = (Gray-mean(Gray(:)))/std(Gray(:))*20+128; % image normalization, to remove global intensity
    
    [CLBP_S,CLBP_M,CLBP_C] = clbp(Gray,R,P,patternMappingriu2,'x');
    
    % Generate histogram of CLBP_S
    CLBP_SH(i,:) = hist(CLBP_S(:),0:patternMappingriu2.num-1);
    
    % Generate histogram of CLBP_M
    CLBP_MH(i,:) = hist(CLBP_M(:),0:patternMappingriu2.num-1);    
    
    % Generate histogram of CLBP_M/C
    CLBP_MC = [CLBP_M(:),CLBP_C(:)];
    Hist3D = hist3(CLBP_MC,[patternMappingriu2.num,2]);
    CLBP_MCH(i,:) = reshape(Hist3D,1,numel(Hist3D));
    
    % Generate histogram of CLBP_S_M/C
    CLBP_S_MCH(i,:) = [CLBP_SH(i,:),CLBP_MCH(i,:)];
    
    % Generate histogram of CLBP_S/M
    CLBP_SM = [CLBP_S(:),CLBP_M(:)];
    Hist3D = hist3(CLBP_SM,[patternMappingriu2.num,patternMappingriu2.num]);
    CLBP_SMH(i,:) = reshape(Hist3D,1,numel(Hist3D));
    
    % Generate histogram of CLBP_S/M/C
    CLBP_MCSum = CLBP_M;
    idx = find(CLBP_C);
    CLBP_MCSum(idx) = CLBP_MCSum(idx)+patternMappingriu2.num;
    CLBP_SMC = [CLBP_S(:),CLBP_MCSum(:)];
    Hist3D = hist3(CLBP_SMC,[patternMappingriu2.num,patternMappingriu2.num*2]);
    CLBP_SMCH(i,:) = reshape(Hist3D,1,numel(Hist3D));    
    
    % rotation invariant var
    V = cont(Gray,R,P);
    %VAR(i,:) = V(:);
    %LBP_VL(:,:,i) = [CLBP_S(:),V(:)];
    VAR{i} = V(:);
    LBP_VL{i} = [CLBP_S(:),V(:)];    
    i;
end
close(h);

for i = 1:length(VAR)
    VAR_max(i) = max(VAR{i});
    VAR_min(i) = min(VAR{i});
end
for i=1:size(dataClasses,1)
    Hist3D = [];
    %Hist3D = hist3(LBP_VL(:,:,i),{linspace(min(LBP_VL(:,1,i)),max(LBP_VL(:,1,i)),10) linspace(min(VAR(:)),max(VAR(:)),16)});
    LBP_VL_i = LBP_VL{i};
    Hist3D = hist3(LBP_VL{i},{linspace(min(LBP_VL_i(:,1)),max(LBP_VL_i(:,1)),10) linspace(min(VAR_min),max(VAR_max),16)});
    LBP_VLH(i,:) = reshape(Hist3D,1,numel(Hist3D));
    i;
end

switch type
    case 'lbp_var' % LBP+VAR
        featureMatrix = LBP_VLH;
    case 'lbp' % original LBP
        featureMatrix = CLBP_SH;
    case 'clbp_m' % CLBP_M
        featureMatrix = CLBP_MH;
    case 'clbp_m/c' % CLBP_M/C
        featureMatrix = CLBP_MCH;
    case 'clbp_s_m/c' % CLBP_S_M/C
        featureMatrix = CLBP_S_MCH;                
    case 'clbp_s/m' % CLBP_S/M
        featureMatrix = CLBP_SMH;                
    case 'clbp_s/m/c' % CLBP_S/M/C
        featureMatrix = CLBP_SMCH;                        
end