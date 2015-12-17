function hist = lbp_blk(im)

global patterns;
global index;

hist = test(im);

%{ // matlab version
hist = zeros(59,1);
for y=2:size(im,1)-1
	for x=2:size(im,2)-1
		pixel = im(y-1:y+1,x-1:x+1);
		pixel = double(pixel >=  im(y,x) );
		vector = pixel(index);

		vector = char(vector+'0');
		code = (strfind(patterns, vector) - 1) / 8 ;
		cIdx = find( mod(code, 1) == 0); 
		if( isscalar(cIdx))
			code = code(cIdx)+1;
			hist(code) = hist(code) + 1;
		else
			hist(59) = hist(59) + 1;
		end
	end
end
%}
