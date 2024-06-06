function [metaData,noClasses] = parseMetadata(imgPath)
  
  files = dir([imgPath '*.tif']);
  noFiles = length(files);

  if ( noFiles == 0 )
    error(['Cannot get files from folder ' imgPath])
  endif

  metaData = []; 

  for i = 1:noFiles
    metaData(i).name = files(i).name;
    metaData(i).imgclass = files(i).name(1:4);
    metaData(i).individual = files(i).name(6:8);
    metaData(i).scale = files(i).name(10:10);
    metaData(i).replicate = files(i).name(12:12);
  endfor

  uniqClasses = unique({metaData.imgclass});
  noClasses = length(uniqClasses);

  for i = 1:noFiles
    for j = 1:noClasses
      if (strcmp(metaData(i).imgclass,uniqClasses{1,j}))
        metaData(i).group = j;
        break
      endif  
    endfor
  endfor
  
endfunction