
function normimg = FRimgnormxy(img, des_mean, des_std, normflag)
% function normimg = FRimgnormxy(imgname, des_mean, des_std, width, height, normflag)
% FRimgnormxy:
% 	scale image to w*h and normalize image to mean x and variance y
% input:
%	img		h*w		double image
%	des_mean	1*1 double	normalize mean
%	des_std 	1*1 double	normalize standard deviation
%	width		1*1 double	image width
%	height		1*1 double	image height
% output:
%	normimg		h*w 		double type image after normalize

if normflag == 1
    imgmean = mean2(img);
    imgstd = std(reshape(img, 1, []));

    normimg = ((img - imgmean) / imgstd) * des_std + des_mean;
elseif normflag == 2
    normimg = double(adapthisteq(uint8(img)));
else
    normimg = img;
end
