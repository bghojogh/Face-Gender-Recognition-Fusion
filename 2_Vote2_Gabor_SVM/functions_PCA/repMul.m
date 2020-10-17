function z = repMul(  y , x ) % y is the scale

% if dim == 1
%     z = x - repmat( y , size( x,1 ) , 1 );
% elseif dim==2
%     z = x - repmat( y , 1, size( x,2) );
% end;

if size(y,1)==1
    z = repmat( y , size( x,1 ) , 1 ) .* x;
elseif size(y,2)==1
    z = repmat( y , 1, size( x,2) ) .* x;
end;