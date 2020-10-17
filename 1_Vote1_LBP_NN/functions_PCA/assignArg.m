function varargout = assignArg ( argName , args , varargin )

if nargin>2
    default = varargin{1};
end;

for i=1:length( argName )
    t=0;
    for j=1:2:length( args )
        if strcmpi( argName{i} , args{j} )
            varargout{i} = args{ j+1 };
            t=1;
        end;
    end;
    if t==0
        varargout{i} = default{i};
    end;
end;