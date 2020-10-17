% in programs written before august 21, 2009, PCAproj outputs weighted and
% centralized features. but after this date, varargin determines ifthe
% fatures should be weighted&centralized or not.

function varargout  = PCAproj( egnFace , egnVal , meanFace , varargin ) % ftrW, meanFace, prbFace: each row for a sample. egnFace: each column for an eigenface

for i=1:nargin-3
    t = repSub( varargin{i} , meanFace );
    varargout{i} = t*egnFace;
end;

if nargout > nargin-3
    egnValSqrt = sqrt( egnVal);
    for i=1:nargin-3
        varargout{ i+ nargin-3 } = repDiv( varargout{i} , egnValSqrt  );
    end;
end;



% eigenfaces are optmized for reconstructing mean-subtracted faces and not
% mean face. therefore it doesn't make sense to calculate feature vectors
% without first subtracting the mean face.

% ftr = prbFace*egnFace;
% 
% if ~isempty( varargin )
%     
%     for i=1:length( varargin )
%         
%         egnValSqrt = sqrt( egnVal);
%         
%         ftrW = ftr./ repmat( egnValSqrt , size(ftr,1) ,1 );
%         
%         meanFtr = meanFace*egnFace;
%         ftrCnt = ftr - repmat( meanFtr ,size(ftr,1),1 );
%         ftrCntW = ftrCnt./ repmat( egnValSqrt , size(ftrCnt,1) ,1 );
%         
%         if strcmp( varargin{i} , 'weighted' )
%             varargout{i} = ftrW;
%         end;
%         if strcmp( varargin{i} , 'centralized' )
%             varargout{i} = ftrCnt;
%         end;
%         if strcmp( varargin{i} , 'centralizedWeighted' )
%             varargout{i} =  ftrCntW;
%         end;
%         if strcmp( varargin{i} , 'weightedCentralizedPortion' )
%             varargout{i} = repmat( meanFtr ,size(ftr,1),1 ) + ftrCntW;
%         end;
%     end;
% end;

            

