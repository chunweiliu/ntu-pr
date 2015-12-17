function [images, regs, ids] = pca_read_data2(trainlist, gallerylist, height, width);

img_size = height * width;

n_data = size(trainlist.name, 1);

images = zeros(height, width, n_data);
k = 1;
for i = 1 : n_data
	% training images;
	im = uint8(FRimgnormxy(double(imread(trainlist.name{i})), 127, 10, 1));

	% im = adapthisteq(imread(trainlist.name{i}));
	
	%sid = trainlist.id(i, 1);

	im = imresize(im, [height width]);
	im = im2double(im);
    %im= reshape(im,img_size,1);
    images(:,:,k) = im;

	%ids(k) = sid;
	k = k + 1;
end

% registration data
n_data = size(gallerylist.name, 1);

regs = zeros(height, width, n_data);
k = 1;
for i = 1 : n_data
	im = uint8(FRimgnormxy(double(imread(gallerylist.name{i})), 127, 10, 1));
	% stdd = std(reshape(im, 1, []));
	% mdd	= mean2(im);
	% im = (im - mdd) / stdd * 10 + 127;

	% reg images;
	%im = adapthhisteq(imread(gallerylist.name{i}));
	sid = gallerylist.id(i, 1);

	im = imresize(im, [height width]);
	im = im2double(im);
    %im= reshape(im,img_size,1);
    regs(:,:,k) = im;

	ids(k) = sid;

	k = k + 1;
end


