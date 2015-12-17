function code = lbp_func1(pixel)
global patterns;

index = [ 1 2 3 6 9 8 7 4];
pixel = double(pixel >=  pixel(2,2) );
vector = pixel(index);

vector = char(vector+'0');
code = (strfind(patterns, vector) - 1) / 8 ;
cIdx = find( mod(code, 1) == 0); 
code = code(cIdx) + 1;

if( ~isscalar(code))
	code = 59;
end
