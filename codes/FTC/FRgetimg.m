
function img = FRgetimg(imgname, width, height)
% function img = FRgetimg(imgname, des_mean, des_std)
% FRimgnormxy:
% 	scale image to given w*h
% input:
%   imgname	string	    image position
%   width	1 * 1	    image width
%   height	1 * 1	    image height
%   
% output:
%   img		h * w	    double type image after normalize

if nargin < 3
	width = 80;
	height = 100;
end

img = imresize(double(imread(imgname)), [height width], 'bilinear');

