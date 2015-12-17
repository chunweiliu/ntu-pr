
function [IdentAcc, predictid] = FRIdentify(AllImg, AllId, GalleryCode, GalleryId, ...
			best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel, best_model, scale_model, patchnum, dec_value) 

%
% FRCodeVerify
%   Verification of face recognition
%
% input:
%   AllImg	    N * H * W	Test Image
%   AllId	    N * 1	Corresponding Test Id, -1 for not in gallery set
%   GalleryCode	    G * P	all G codes for P patch each
%   GalleryId	    G * 1	Gallery Id corresponding to codes
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
%   IdentAcc	    1 * 1	identification accuracy
%   predictid	    N * 1	predicted test id
%


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
[best_ids, alldecs] = FRCodeCompare(GalleryCode(:, 1:patchnum), ProbeCode);

% find accuracy
predictid	    = GalleryId(best_ids);
predictid(min(alldecs, [], 2) > dec_value) = -1;
IdentAcc	    = sum(predictid == AllId) / N_face;


