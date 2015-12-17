
function [bestid, alldecs] = FRIdentify(AllImg, AllId, GalleryCode, GalleryId, ...
			best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel, best_model, scale_model, patchnum, dec_value) 


addpath('libsvm-mat-2.86-1');
addpath('LDALIB');

if nargin < 12
    patchnum = length(best_ranges);
end

if nargin < 13
    dec_value = 1e10;
end

% number of test face
N_face = length(AllId);

% find all decision values
ProbeCode	    = FRCodeTest(AllImg, best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel, best_model, scale_model, patchnum);
[bestid, alldecs] = FRCodeCompare(GalleryCode(:, 1:patchnum), ProbeCode(1, :));
bestid = GalleryId(bestid);


