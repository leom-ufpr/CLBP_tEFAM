function featureMatrix = LBPDescriptorsMSB(imgPath, srcPath, dataClasses, type, radius, neighbors, varargin)

% Parsing optional input:
options = parseOptions( length(varargin) );

% Get mapping
R=radius;
P=neighbors;
patternMappingriu2 = parseMapping(srcPath, P);

% Compute histograms
k = 1; 
dataClassesSize = size(dataClasses, 1);
h = waitbar (0, '0.00%');
VARH = [];LBPH = [];LBP=[];VAR=[];LBP_VLH=[];

for i = 1:dataClassesSize
    % Set wait bar
    imgFraction = i/dataClassesSize;
    waitbar(imgFraction, h, sprintf ( '%.2f%%', 100*imgFraction ));
    
    % Get normalized gray scale image
    Gray = getGrayImg( imgPath, dataClasses{i,1}, options );
    
    % Get histograms
    [CLBP_S, CLBP_M, CLBP_C] = clbp(Gray, R, P, patternMappingriu2, 'x');

    switch type
      case 'lbp' % Original LBP
        featureMatrix(i,:) = getCLBP_SH(CLBP_S(:), patternMappingriu2);
      
      case 'clbp_m' % CLBP_M
        featureMatrix(i,:) = hist(CLBP_M(:), 0:patternMappingriu2.num-1);
      
      case 'clbp_m/c' % CLBP_M/C
        featureMatrix(i,:) = getCLBP_MC(CLBP_M(:), CLBP_C(:), patternMappingriu2);
      
      case 'clbp_s_m/c' % CLBP_S_M/C
        CLBP_SH = getCLBP_SH(CLBP_S(:), patternMappingriu2.num);
        CLBP_MCH = getCLBP_MC(CLBP_M(:), CLBP_C(:), patternMappingriu2);
        featureMatrix(i,:) = [CLBP_SH, CLBP_MCH];
      
      case 'clbp_s/m' % CLBP_S/M
        CLBP_SM = [CLBP_S(:),CLBP_M(:)];
        Hist3D = hist3(CLBP_SM, [patternMappingriu2.num, patternMappingriu2.num]);
        featureMatrix(i,:) = reshape(Hist3D, 1, numel(Hist3D));
      
      case 'clbp_s/m/c' % CLBP_S/M/C
        CLBP_MCSum = CLBP_M;
        idx = find(CLBP_C);
        CLBP_MCSum(idx) = CLBP_MCSum(idx) + patternMappingriu2.num;
        CLBP_SMC = [CLBP_S(:), CLBP_MCSum(:)];
        Hist3D = hist3(CLBP_SMC,[patternMappingriu2.num, patternMappingriu2.num*2]);
        featureMatrix(i,:) = reshape(Hist3D, 1, numel(Hist3D));
      
      case 'lbp_var' % LBP+VAR
        V = cont(Gray,R,P);
        VAR{i} = V(:);
        LBP_VL{i} = [CLBP_S(:),V(:)];
    endswitch
    i;
endfor
close(h);

if strcmp( type, 'lbp_var' )
    featureMatrix = getLBPVar( VAR, LBP_VL, dataClassesSize );
endif

% Subrotinas auxiliares
function options = parseOptions( nArgs )
    options = struct('typeNoise', 'G', 'levelNoise', 0);
    optionNames = fieldnames(options);
    if round(nArgs/2) ~= nArgs/2
        error('Optional arguments are propertyName/propertyValue pairs');
    endif
    for pair = reshape(varargin,2,[]) %# pair is {propName;propValue}
        inpName = pair{1}; %# make case insensitive
        if any(strcmp(inpName, optionNames))
            options.(inpName) = pair{2};
        else
            error('%s is not a recognized parameter name', inpName);
        endif
    endfor
endfunction

function patternMappingriu2 = parseMapping( srcPath, P )
    mappingFile = sprintf('%s%s%d%s', srcPath, 'src/mapping', P, 'riu2.m');
    if exist(mappingFile) == 2
        display("Will load mapping from file, please wait");
        load (mappingFile);
    else
        display("Will compute mapping from scratch, please wait");
        patternMappingriu2 = getmapping(P, 'riu2');
        save("-zip", mappingFile, "patternMappingriu2");
    endif
endfunction

function Gray = getGrayImg( imgPath, imgFile, options )
    Gray = imread([imgPath imgFile]);
    if length(size(Gray)) > 2 % color images
        Gray = rgb2gray(Gray);
    endif    
    Gray = im2double(Gray);
    if options.levelNoise ~= 0
        if options.typeNoise == 'G'
            Gray2 = imnoise(Gray, 'gaussian', 0, options.levelNoise);
        endif
        if options.typeNoise == 'S'
            Gray2 = imnoise(Gray, 'salt & pepper', options.levelNoise);
        endif
        Gray = Gray2;
    endif
    Gray = (Gray - mean(Gray(:))) / std(Gray(:)) * 20 + 128; % image normalization, to remove global intensity
endfunction

function CLBP_SH = getCLBP_SH( CLBP_S, mapping )
    CLBP_SH = hist(CLBP_S, 0:mapping.num-1);
endfunction

function CLBP_MCH = getCLBP_MC( CLBP_M, CLBP_C, mapping )
    CLBP_MC = [CLBP_M, CLBP_C];
    Hist3D = hist3(CLBP_MC, [mapping.num,2]);
    CLBP_MCH = reshape(Hist3D, 1, numel(Hist3D));
endfunction

function featureMatrix = getLBPVar( VAR, LBP_VL, dataClassesSize )
    for i = 1:length(VAR)
        VAR_max(i) = max(VAR{i});
        VAR_min(i) = min(VAR{i});
    end
    for i = 1:dataClassesSize
        Hist3D = [];
        LBP_VL_i = LBP_VL{i};
        Hist3D = hist3(LBP_VL{i},{linspace(min(LBP_VL_i(:,1)),max(LBP_VL_i(:,1)),10) linspace(min(VAR_min),max(VAR_max),16)});
        featureMatrix(i,:) = reshape(Hist3D, 1, numel(Hist3D));
        i;
    endfor
endfunction

endfunction