function W = lbp(images, dims)
% images : w * h * nImgs
% W : p * (nRegion * )nImgs


[height,width, nImgs] = size(images);

widthRegion = width / dims; % region width
heightRegion = height / dims; %region height

nSize = height * width;

global index;
index = [ 1 2 3 6 9 8 7 4];
func = @lbp_func;

for iImg = 1:nImgs

	%disp(iImg);
	im = images(:,:,iImg);

	% to-do
	hist = blkproc(im, [widthRegion heightRegion], func);
	hist = reshape(hist, [], 1);
	W(:,iImg) = hist;
end



