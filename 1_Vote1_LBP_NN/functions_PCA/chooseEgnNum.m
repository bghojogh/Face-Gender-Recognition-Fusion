function n=chooseEgnNum( egnVal , varargin ) % varargin is {'egnBin',egnBin}

% if nargin>2
%     egnBin = varargin{2};
% else
%     egnBin = 1;
% end;


[egnPow , egnFrac ] = assignArg( {'egnPow' , 'egnFrac'} , varargin , {0.95 , 0.95} );

if strcmp( varargin{1} , 'egnPow' )
    
    p = varargin{2};

    x(1) = egnVal(1);
    for i=2:length( egnVal)
        x(i) = x(i-1) + egnVal(i);
    end;

    x = x/x( length(x) );
    
    for j=1:length(p)

        if p(j)<x(1)
            n(j) = 1;
            'egnPow is smaller than first egn'
        else

            for i=  1 :length(x)-1
                if x(i)<=p(j) && x(i+1)>=p(j)
                    if ( p(j) - x(i) ) < ( x(i+1) - p(j) )
                        n(j)=i;
                    else
                        n(j) = i+1;
                    end;
                    break
                end;
            end;
        end;
    end;
    
elseif strcmp( varargin{1} , 'egnFrac' )
    
    f = varargin{2};
    x = [1:length( egnVal )]/ length( egnVal );
    
    for j=1:length(f)
        for i=1: length( egnVal )
               if x(i)<=f(j) && x(i+1)>=f(j)
                    if ( f(j) - x(i) ) < ( x(i+1) - f(j) )
                        n(j)=i;
                    else
                        n(j) = i+1;
                    end;
                    break
                end;  
        end;
    end;
end;