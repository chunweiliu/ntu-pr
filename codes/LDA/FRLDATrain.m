function [FRModel, disthd] = FRLDATrain(trainlist, gallerylist, sr, sc, d)
% FRTrain:
%	Training for Face Recognition
% input:
%	trainlist		1 * M struct		M data for training
%	gallerylist		1 * N struct		N data for registration
%   sr              1 * 1 double        row size of traing image
%   sc              1 * 1 double        col size of traing image
%   d               1 * 1 double        mapping data to d dimension
% output:
%	FRModel			1 * 1 struct 		Model of database
%	disthd			function handle		function handle for distance computation
%										[best_id, all_decvalue] = disthd(FRModel, testface_name)

% Load intensity images from training list
fprintf(' loading training images ... ');
tic;
%TMP = FRimgnormxy_v2( trainlist.name{1, 1} );
TMP = getimg( trainlist.name{1, 1}, sr, sc );
dim = size( TMP, 1 )*size( TMP, 2 );

X   = zeros( dim, size(trainlist.id, 1) );
y   = zeros( 1, size(trainlist.id, 1) );
for n = 1 : length(trainlist.name)
    %GRAY    = FRimgnormxy_v2( trainlist.name{n, 1} );
    GRAY    = getimg( trainlist.name{n, 1}, sr, sc );
    imgvec  = reshape( GRAY, dim, 1 );
    X(:,n)  = imgvec;
    y(n)    = trainlist.id(n, 1);
end
toc;

% Do PCA step on input data
m = mean(X, 2);
M = repmat(m, 1, length(trainlist.name));
S = (X - M) * (X - M)';
k = min( d, size(X, 1) );
[eVec, eVal] = eigs( S, k );


% Training model
fprintf(' start training process ... ');
tic;
data.X = eVec' * X;
data.y = y;
fprintf(' lda to %d ... ', k);
model  = lda( data, k );
toc;

% Using model transfrom all images in gallery list
fprintf(' loading gallery images ... ');
tic;
%TMP = FRimgnormxy_v2( gallerylist.name{1, 1} );
TMP = getimg( gallerylist.name{1, 1}, sr, sc );
dim = size( TMP, 1 )*size( TMP, 2 );

X   = zeros( dim, size(gallerylist.id, 1) );
y   = zeros( 1, size(gallerylist.id, 1) );
for n = 1 : length(gallerylist.name)
    GRAY    = getimg( gallerylist.name{n, 1}, sr, sc );
    imgvec  = reshape( GRAY, dim, 1 );
    X(:,n)  = imgvec;
    y(n)    = gallerylist.id(n, 1);
end
in_data.X   = eVec' * X;
in_data.y   = y;
out_data    = linproj(in_data, model);
toc;

% Import gallery sequence
FRModel.model   = model;
FRModel.gallery = out_data;
FRModel.eVec    = eVec;
FRModel.sr      = sr;
FRModel.sc      = sc;
%FRModel.getimg  = @(imgname) FRimgnormxy_v2 (imgname);
FRModel.getimg  = @(imgname, sr, sc) getimg (imgname, sr, sc);

% Set function handle for testing
disthd = @(FRModel, testface_name) FRLDATest (FRModel, testface_name);
