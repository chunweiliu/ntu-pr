
function [ROCstat, DecBound, ROCnum] = FRCodeVerify(AllImg, AllId, GalleryCode, GalleryId, best_patch, best_ranges, ...
						best_idclass, best_pcamodel, best_ldamodel, best_model, scale_model, patchnum) 

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
%   ROCstat	    D * 2	true positive rate and false possitve rate in each row
%   DecBound	    D * 1	each decision boundary corresponding to ROCstat
%   ROCnum	    D * 4	[TruePos FalseNeg FalsePos TrueNeg] in each row


if nargin < 12
    patchnum = length(best_ranges);
end

% number of test face
N_face	= length(AllId);
% number of unique gallery id
u_gid	= unique(GalleryId);
N_regis = length(u_gid);

% Id-idx cell
GalleryIdx  = cell(N_regis, 1);
for i = 1 : N_regis
    GalleryIdx{i, 1} = find(GalleryId == u_gid(i));
end

% get distance
AllCode	    = FRCodeTest(AllImg, best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel, best_model, scale_model, patchnum);
[bi, Alld]  = FRCodeCompare(GalleryCode(:, 1:patchnum), AllCode);

u_dist	    = unique(sort(reshape(Alld, 1, [])));
N_dist	    = length(u_dist);
ROCnum	    = zeros(N_dist, 4);
fprintf('start finding ROC (%d) ', N_dist);
for i = 1 : N_dist
    nowdec  = u_dist(i);
    N_TP = 0;
    N_FN = 0;
    N_FP = 0;
    N_TN = 0;
    for j = 1 : N_face
	nowtestid   = AllId(j);
	nowalldec   = Alld(j, :);
	nowposidx   = [];
	for k = 1 : N_regis
	    temp = min(nowalldec(GalleryIdx{k, 1}));
	    if temp <= nowdec
		nowposidx = [nowposidx k];
	    end
	end
	nownegidx   = setdiff([1:N_regis], nowposidx);

	posflag = 0;
	negflag = 0;
	if sum(u_gid == nowtestid) > 0
	    if length(nowposidx) > 0 && sum(nowposidx == find(u_gid == nowtestid)) > 0
		posflag = 1;
	    end
	    if length(nownegidx) > 0 && sum(nownegidx == find(u_gid == nowtestid)) > 0
		negflag = 1;
	    end
	end

	N_TP	    = N_TP + posflag;
	N_FN	    = N_FN + negflag;
	N_FP	    = N_FP + length(nowposidx) - posflag;
	N_TN	    = N_TN + length(nownegidx) - negflag;
    end

    ROCnum(i, :)    = [N_TP N_FN N_FP N_TN];
    fprintf('.')
end
fprintf('done\n');

TPRs	= ROCnum(:, 1) ./ (ROCnum(:, 1) + ROCnum(:, 2));
FPRs	= ROCnum(:, 3) ./ (ROCnum(:, 3) + ROCnum(:, 4));

ROCstat	    = [TPRs FPRs];
DecBound    = u_dist;

