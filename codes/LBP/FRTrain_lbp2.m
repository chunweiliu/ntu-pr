function [FRModel, disthd] = FRTrain_lbp2(images, regs, ids, height, width, dims)%trainlist, gallerylist)

% FRTrain:
%	Training for Face Recognition
% input:
%	trainlist		1 * M struct		M data for training
%	gallerylist		1 * N struct		N data for registration
% output:
%	FRModel			1 * 1 struct 		Model of database
%	disthd			function handle		function handle for distance computation
%										[best_id, all_decvalue] = disthd(FRModel, testface_name)
tic;
disp('Training...');


%[images, regs, ids] = lbp_read_data(trainlist, gallerylist);
global patterns
patterns = lbp_list_pattern();
W = lbp(regs, dims);

FRModel.W = W;
FRModel.ids = ids;
FRModel.dims = dims;

disthd = @(FRModel, name) lbp_recognition(im2double(imresize(imread(name), [height width])), FRModel.ids, FRModel.W,  FRModel.dims,  0);

t = toc;
disp(sprintf('Used time: %f', t));
