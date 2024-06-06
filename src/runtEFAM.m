function [totalPert,totalError] = runtEFAM(srcPath, metaData, noClasses,
   featureMatrix, noPrinComp, noExp, kfold)
   
pkg load statistics;

tic;

addpath( [srcPath 'src/'] );
addpath( [srcPath 'src/tEFAM/'] );

data = featureMatrix;
[~,score] = princomp(data);
noPrinComp = min(columns(score),noPrinComp);
clear data;
data = score(:,1:noPrinComp)';

setupF = {1,''};
setupT = {1};

epsilon = 10^(-8);
min_error = 10^8;

groups = [ metaData.group ];
expVector = [];
Y_min_total = [];
totalError = [];

npattern = size(data,2);

tic;
for exp = 1:noExp
	indices = crossvalind('Kfold',groups',kfold);

  for i = 1:kfold
    tra(i).X = data(:,indices~=i); 
    tra(i).Y = full(ind2vec(groups(indices~=i)));
     
    Len = max(tra(i).X,[],2) - min(tra(i).X,[],2);
    pLen = Len > 0;
    Lambda = std(tra(i).X')';
    Lambda(pLen) = Lambda(pLen)./Len(pLen);
    tra(i).paramE = {1,[Lambda Len]};
     
    tst(i).indices = (indices==i);
    tst(i).X = data(:,indices==i); 
    tst(i).Y = full(ind2vec(groups(indices==i)));     
  endfor

  errorTst = []; Out_iv = [];
  Paux = zeros(noClasses,npattern);
	for k = 1:length(tra)
		Xtr = tra(k).X; dtr = tra(k).Y;
		Xtst = tst(k).X; dtst = tst(k).Y; 
		
    [nattr nxtst] = size(Xtst);
		paramE = tra(k).paramE;
		W_old = ones(nattr,1)./nattr;
		
    [Y,V] = tEFAM([], W_old, Xtr, dtr, Xtst, paramE, setupF, setupT);
		errorTst(1,k) = sum(max(abs(dtst-Y),[],1)>epsilon)/nxtst;
    
    iu = vec2ind(dtr);
    un = unique(iu);
		for iv = 1:noClasses
				Paux(iv,tst(k).indices) = max(V(iu==un(iv),:),[],1);
		endfor	
		
  endfor
  if (min_error > mean(errorTst))
    min_error = mean(errorTst);
    P = Paux;
  endif

 
  expVector = [expVector repmat(exp, 1, length(Paux))];
  Y_min_total = cat(1, Y_min_total, Paux');
  totalError = [totalError errorTst];

endfor
toc;

% Compile return struct
metaDataFields = fieldnames(metaData);
i = 1;

while i <= length(Y_min_total)
  for j = 1:length(metaData)
    for k = 2:length(metaDataFields)
      dataField = char(metaDataFields(k, 1))
      totalPert(i).(dataField) = metaData(j).(dataField)
    endfor
    totalPert(i).exp = expVector(i)
    for l = 1:columns(Y_min_total)
      totalPert(i).(['group_' num2str(l)]) = Y_min_total(i, l)
    endfor
    i += 1
  endfor
endwhile

%Variáveis nao utilizadas
%type_normalization = 0;
%type_scaling = 0;
%rho = [[0:0.1:0.9] 0.99];
%exibe = 0;
%errors_ts = []