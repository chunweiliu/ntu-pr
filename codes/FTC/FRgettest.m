function [test_label, test_data] = FRgettest(GalleryImg, best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel)

%
% FRgettest:
%   get test data for SVM predict
%
% input:
%   GalleryImg	    N * D	Gallery Image
%   best_patch	    P * 4	all patch postition
%   best_ranges	    P * 1	cluster ranges of each patches
%   best_idclass    G * P	G gallery id to P patch
%   best_pcamodel   struct	PCA model obtained from LDALIB pca algorithm
%   best_ldamodel   struct	LDA model obtained from LDALIB lda algorithm
%
% output:
%   test_label	    P * 1 cell	N * 1 zeros in each cell
%   test_data	    P * 1 cell	N * LDA_D projected Gallery data in each cells
%

addpath('LDALIB');
test_data = cell(length(best_ranges), 1);
test_label = cell(length(best_ranges), 1);

Npatch  = length(best_ranges);
Nimg    = size(GalleryImg, 1);

for i = 1 : Npatch
    start_x	= best_patch(i, 1);
    start_y	= best_patch(i, 2);
    end_x	= best_patch(i, 3) + start_x - 1;
    end_y	= best_patch(i, 4) + start_y - 1;
    data	= reshape(GalleryImg(:, start_y : end_y, start_x : end_x), Nimg, []);
    data	= linproj(linproj(data', best_pcamodel{i, 1}), best_ldamodel{i, 1})';

    test_data{i, 1}	= data;
    test_label{i, 1}	= zeros(size(data, 1), 1);
end

