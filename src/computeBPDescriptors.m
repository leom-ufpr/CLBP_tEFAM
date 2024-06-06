function [featureMatrix] = computeBPDescriptors(metaData, srcPath, imgPath, method, rmax, radius, neighbors)

pkg load statistics;
pkg load image;
  
addpath([srcPath 'src/CLBP']);
addpath([srcPath 'src/BC']);

  for i = 1:length(metaData)
    dataClasses{i,1} = metaData(i).name;
    dataClasses{i,2} = metaData(i).group;
  endfor

  noFiles = length(metaData)

  switch method
    case 'lbp'
      featureMatrix = LBPDescriptors(imgPath,srcPath,dataClasses,'lbp',radius,neighbors);
    case 'lbpSMC'
      featureMatrix = LBPDescriptors(imgPath,srcPath,dataClasses,'clbp_s/m/c',radius,neighbors);
    otherwise
      for i = 1:noFiles
        tic;
        fileName = metaData(i).name;
        img = double(imread([imgPath metaData.name]));
        switch method
          case 'mink'
            [~,logy] = Minkowski3D(img,rmax);
            featureMatrix(i,:) = logy;
          case 'boxCouting'
            featureMatrix(i,:) = computeBCFD(round(imresize(img,0.5)));
          otherwise
            error(['Unknown method passed to computeDescriptors: ' method])
         endswitch
         toc;
       endfor
  endswitch

endfunction