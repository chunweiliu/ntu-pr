function [FRModel, disthd] = FRTrain_pca(trainlist, gallerylist, height, width, dims)
%function [FRModel, disthd] = FRTrain(images, regs, ids)%trainlist, gallerylist)
% FRTrain:
%	Training for Face Recognition
% input:
%	trainlist		1 * M struct		M data for training
%	gallerylist		1 * N struct		N data for registration
% output:
%	FRModel			1 * 1 struct 		Model of database
%	disthd			function handle		function handle for distance computation
%										[best_id, all_decvalue] = disthd(FRModel, testface_name)

[images, regs, ids] = pca_read_data(trainlist, gallerylist, height, width);

[S, W, M, U, D] = pca(images,regs, dims);

FRModel.S = S;
FRModel.W = W;
FRModel.M = M;
FRModel.U = U;
FRModel.D = D;
FRModel.ids = ids;

disthd = @(FRModel, name) pca_recognition(im2double(imresize(uint8(FRimgnormxy(double(imread(name)), 127, 10, 1)), [height width])), FRModel.ids, FRModel.W, FRModel.M, FRModel.U, FRModel.D, 0);

% [result, id] = disthd(FRModel, name) 
