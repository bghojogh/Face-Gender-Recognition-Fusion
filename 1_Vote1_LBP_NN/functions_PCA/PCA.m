 function [ egnFace , egnValSort , meanFace , varargout] = PCA( trnFace  ,egnPow, varargin) % TrnFace, AvFace: each row is an observation (to be consistant with MATLAB). EgnFace: each column is an eigenface. EgnValSort: row vecotr

%egnPow = 0.4;
w = 1; test={};
[ egnPow  , w , test  ] = assignArg( { 'egnPow' , 'w' , 'test' } , varargin , { egnPow  , w , test } );

trnNum = size( trnFace , 1 ); %number of training faces

meanFace = mean( trnFace ); % average face, dim=2 => along the rows 

trnFaceCnt = trnFace - repmat( meanFace , trnNum , 1 );

% using L is a trick
L = trnFaceCnt*trnFaceCnt'; 

[ egnVecL , egnVal ] = eig(L);
[ egnValSort , IX ] = sort( diag( egnVal ) , 'descend' ); % find indices of the FtrDim largest eignvalues
egnVecLSort = egnVecL( : ,IX);



egnValSort = egnValSort'/(trnNum-1); % L should have been divided by (TrnNum-1). but division here reduces the computational cost.

egnValSort( end ) = []; % the last one should be omitted because it's zero
egnVecLSort( :, end ) = []; 

%--------------------------------number of eigens

n = chooseEgnNum( egnValSort , 'egnPow' , egnPow );
%n=10;
egnValSort = egnValSort( 1 : n( end ) );
egnVecLSort = egnVecLSort(:,1:n( end ) );

%-------------------------------------%


egnFace = trnFaceCnt' * egnVecLSort; % the l-th final eigenvector is obtained by weighting all training faces, each with the corresponding element of the l-th eigenvecotr of L, and summing the results.
egnFace = normc( egnFace ); % normalize each EgnFace

if w
    egnFace = repDiv( egnFace , sqrt( egnValSort ) );
end;
%------------------------------------------------
varargout={};

if ~isempty(test)
    for i=1: length( test )
        t = repSub( test{i} , meanFace );
        varargout{i} = t*egnFace;
    end;
end;

varargout{end+1}=egnVecLSort;