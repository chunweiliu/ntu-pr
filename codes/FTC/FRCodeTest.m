

function [Code] = ...
	FRCodeTest(Img, best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel, best_model, scale_model, patchnum)

%
% FRCodeTest
%   encode the image by given training model
%
% input:
%   Img		    N * H * W	Test Image  
%   best_patch	    P * 4	patch positions
%   best_ranges	    1 * P	range of each patch
%   best_idclass    G'* P	each gallery id to each patch
%   best_pcamodel   P * 1 cells	PCA model obtained from LDALIB pca algorithm
%   best_ldamodel   P * 1 cells	LDA model obtained from LDALIB lda algorithm
%   best_model	    P * 1 cell	svm model for each patch
%   scale_model	    P * 1 cell	scale model for each patch
%   patchnum	    1 * 1	(opt.) patch num for testing
%
% output:
%   Code	    N * P	all codes for each img
%

if nargin < 9
    patchnum = size(best_patch, 1);
end

if patchnum < 0 || patchnum > size(best_patch, 1)
    fprintf('warning: refine patchnum\n');
    patchnum = size(best_patch, 1);
end

best_patch	= best_patch(1:patchnum, :);
best_ranges	= best_ranges(1:patchnum);
best_idclass	= best_idclass(:, 1:patchnum);
best_pcamodel	= best_pcamodel(1:patchnum, 1);
best_ldamodel	= best_ldamodel(1:patchnum, 1);
best_model	= best_model(1:patchnum, 1);
scale_model	= scale_model(1:patchnum, 1);

N_patch = size(best_patch, 1);
Code = zeros(size(Img, 1), N_patch);

[label, data]	= FRgettest(Img, best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel);
for i = 1 : size(best_patch, 1)
    data{i, 1}	= FRSVMScale(data{i, 1}, scale_model{i, 1});
    Code(:, i)	= svmpredict(label{i, 1}, data{i, 1}, best_model{i, 1});
end

