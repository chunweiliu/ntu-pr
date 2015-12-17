function vector = lbp_op1(pixel, p)

% pixel : 3 X 3 

pc = pixel(2,2);

%pixel = pixel - pc;
pixel = double(pixel >= pc & 1);

index = [ 1 2 3 6 9 8 7 4];
vector = pixel(index);
%vector = [pixel(1,1) pixel(2,1)  pixel(3,1)  pixel(3,2)  pixel(3,3)  pixel(2,3)  pixel(1,3)  pixel(1,2) ];

vector = dec2bin(bin2dec(dec2bin(vector)'));

