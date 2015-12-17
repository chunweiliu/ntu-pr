function [ FRModel, disthd ]= lda_train( X, y, gX, gy, d, sr, sc )
% lda_train: training linear discriminant analysis
% inputs:
%       X:  d * n   double      n's training data of d dimensions
%       y:  1 * n   double      label of n's data
%      gX:  d * m   double      d's gallery data of d dimensions
%      gy:  1 * m   double      label of m's data
%       d:  1 * 1   double      dim 
% outputs:
%   model:  1 x 1   struct      model parameters
% dist_hd:  function handler    function handler for distance computation

% Do PCA step on input data
m = mean(X, 2);
M = repmat(m, 1, size(X, 2));
S = (X - M) * (X - M)';
k = min( d, size(X, 1) );
[eVec, eVal] = eigs( S, k );
% Training model
%fprintf(' start training process ... ');
%tic;
data.X = (eVec' * X);
data.y = y;
%fprintf(' lda to %d ... ', k);
model  = lda( data, k );
%toc;

in_data.X   = (eVec' * gX);
in_data.y   = gy;
out_data    = linproj(in_data, model);

% Import gallery sequence
FRModel.model   = model;
FRModel.gallery = out_data;
FRModel.eVec    = eVec;
FRModel.sr      = sr;
FRModel.sc      = sc;
FRModel.getimg  = @(imgname, sr, sc) getimg (imgname, sr, sc);

% Set function handle for testing
disthd = @(FRModel, testface_name) FRLDATest (FRModel, testface_name);
                
