

function [training_label, training_data] = FRgettrain(TraitExtImg, TraitExtId, TraitVarImg, TraitVarId, ...
							    best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel)
%
% FRgettrain:
%   get training data for SVM training
%
% input:
%   TraitExtImg	    N * D	Training Neutral Image
%   TraitExtId	    N * 1	Training Neutral Id
%   TraitVarImg	    N * D	Training Variant Image
%   TraitVarId	    N * 1	Training Variant Id
%   best_patch	    P * 4	all patch postition
%   best_ranges	    P * 1	cluster ranges of each patches
%   best_idclass    G * P	G gallery id to P patch
%   best_pcamodel   struct	PCA model obtained from LDALIB pca algorithm
%   best_ldamodel   struct	LDA model obtained from LDALIB lda algorithm
%
% output:
%   training_label  P * 1 cell	N * 1 training label for corresponding cluster in each cell
%   training_data   P * 1 cell	N * LDA_D projected training data in each cell
%

addpath('LDALIB');
training_data = cell(length(best_ranges), 1);
training_label = cell(length(best_ranges), 1);

Npatch  = length(best_ranges);
Nimg    = length(TraitExtId) + length(TraitVarId);
TotalId	= [TraitExtId; TraitVarId];
UId	= unique(TotalId);
UExtId	= unique(TraitExtId);

if length(UExtId) ~= size(best_idclass, 1)
    fprintf('\n\t warning: idlist not match (%d,%d)\n', length(UExtId), size(best_idclass, 1));
end

for i = 1 : Npatch
    start_x	= best_patch(i, 1);
    start_y	= best_patch(i, 2);
    end_x	= best_patch(i, 3) + start_x - 1;
    end_y	= best_patch(i, 4) + start_y - 1;
    data	= reshape(cat(1, TraitExtImg(:, start_y : end_y, start_x : end_x), ...
                                TraitVarImg(:, start_y : end_y, start_x : end_x)), Nimg, []);
    data	= linproj(linproj(data', best_pcamodel{i, 1}), best_ldamodel{i, 1})';
    % set labels
    label	    = zeros(Nimg, 1);
    for u = 1 : length(UId)
	index_all   = find(TotalId == UId(u));
	index_ext   = find(UExtId == UId(u));
	if length(index_ext) < 1
	    label(index_all, 1) = -1;
	else
	    label(index_all, 1) = best_idclass(index_ext(1), i);
	end
    end

    % throw the data whose id not exists in Extend Image Set
    data(find(label == -1), :) = [];
    label(find(label == -1), :) = [];

    training_label{i, 1} = label;
    training_data{i, 1} = data;
end

