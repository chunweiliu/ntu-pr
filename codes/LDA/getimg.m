function normimg = getimg( imgname, sr, sc, des_mean, des_std )
% function normimg = getimg( imgname, sr, sc, des_mean, des_std )
% getimg:
%   scale image to sc * sr and normalize image
% inputs:
%   imgname     string          image position
%   sr          1 * 1 double    scale row in sr
%   sc          1 * 1 double    scale col in sc
%   des_mean    1 * 1 double    normalize mean
%   des_std     1 * 1 double    normalize standard deviation
% outputs:
%   normimg     sr * sc double  double type image after normalize

if nargin < 5
    des_std = 1;
end
if nargin < 4
    des_mean = 127;
end
if nargin < 3
    sc  = 80;
end
if nargin < 2
    sr  = 100;
end

img     = imresize( double( imread( imgname ) ), [sr, sc], 'bilinear' );
%imgmean = mean2( img );
%imgstd  = std( reshape(img, 1, []) );

%normimg = ((img - imgmean) / imgstd) * des_std + des_mean;
normimg = img;
