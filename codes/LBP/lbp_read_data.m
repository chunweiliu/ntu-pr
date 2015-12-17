function [images, regs, ids] = lbp_read_data(trainlist, gallerylist, height, width);
disp('Read data...');

tic
images = [];
% registration data
n_data = size(gallerylist.name, 1);

k = 1;
regs = zeros(height, width, n_data);
for i = 1 : n_data
	% reg images;
	regs(:, :, k) = im2double(imresize(imread(gallerylist.name{i}), [height width]));
	sid = gallerylist.id(i, 1);

	% im = imresize(im, [256 256]);
	% im = im2double(im);
    % regs(:,:, k) = im(:,:);

	ids(k) = sid;

	k = k + 1;
end
t = toc;
disp(sprintf('Used time: %.2fs', t));


