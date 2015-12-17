
function [best_model, scale_model, bestparam] = FRCodeTrain(ExtImg, ExtId, VarImg, VarId, ... 
					best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel, SVMParams)
%
% FRCodeTrain
%   training ext and var images to find the best encode models
%
% input:
%   ExtImg	    N * D	Ext Image
%   ExtId	    N * 1	Ext Id
%   VarImg	    N * D	Var Image
%   VarId	    N * 1	Var Id
%   best_patch	    P * 4	patch positions
%   best_ranges	    1 * P	range of each patch
%   best_idclass    G'* P	each gallery id to each patch
%   best_pcamodel   P * 1 cells	PCA model obtained from LDALIB pca algorithm
%   best_ldamodel   P * 1 cells	LDA model obtained from LDALIB lda algorithm
%   SVMParams	    struct	SVM params
%
% output:
%   best_model	    P * 1 cell	SVM models
%   scale_model	    P * 1 cell	scale model for SVM
%   bestparam	    P * 1struct	each patch structure of best cost and gamma
%
% SVMParams struct
%   fold	    1 * 1	cross validation folds
%   gammas	    1 * g	possible candidate of gammas
%   costs	    1 * c	possible candidate of costs
%
% bestparam struct
%   g		    1 * 1	best gamma
%   c		    1 * 1	best cost
%   acc		    1 * 1	best acc of cross validation
%

addpath('libsvm-mat-2.86-1');
N_patch = size(best_patch, 1);

% SVM training (cross validation)
% training data
[Training_label, Training_data] ...
		= FRgettrain(ExtImg, ExtId, VarImg, VarId, best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel);

% scaling
fprintf('scaling...\n');
scale_model = cell(N_patch, 1);
for i = 1 : N_patch
    [Training_data{i, 1}, scale_model{i, 1}] = FRSVMScale(Training_data{i, 1});
end

fprintf('find best model...\n');
% cross validation
best_model  = cell(N_patch, 1);
for i = 1 : N_patch
    [best_params, bestparam(i).g, bestparam(i).c bestparam(i).acc] = FRSVMParams(Training_label{i, 1}, Training_data{i, 1}, SVMParams.fold, SVMParams.gammas, SVMParams.costs);
    best_model{i, 1} = svmtrain(Training_label{i, 1}, Training_data{i, 1}, best_params);
end
fprintf('done\n');

