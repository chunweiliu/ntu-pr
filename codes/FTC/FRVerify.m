
function [ROCstat, DecBound, ROCnum] = FRVerify(FRmodel, disthd, facelist, imposterlist, gallerylist, figurename) 

%
% FRCodeVerify
%   Verification of face recognition
%
% input:
%   FRModel
%   disthd
%   facelist
%   gallerylist
%
% output:
%   ROCstat	    D * 2	true positive rate and false possitve rate in each row
%   DecBound	    D * 1	each decision boundary corresponding to ROCstat
%   ROCnum	    D * 4	[TruePos FalseNeg FalsePos TrueNeg] in each row
%


facename(1:length(facelist.name), 1)    = facelist.name(:, 1);
facename(length(facename) + 1:length(facename) + length(imposterlist.name), 1) = imposterlist.name(:, 1);
faceid	= [facelist.id(:, 1); imposterlist.id(:, 1)];


% number of test face
N_face	    = length(facename);

% number of unique gallery id
GalleryId   = gallerylist.id(:, 1);
u_gid	    = unique(GalleryId);
N_regis	    = length(u_gid);

% Id-idx cell
GalleryIdx  = cell(N_regis, 1);
for i = 1 : N_regis
    GalleryIdx{i, 1} = find(GalleryId == u_gid(i));
end

% get distance
[bi, Alld]  = FRTest(FRmodel, disthd, facename);

u_dist	    = unique(sort(reshape(Alld, 1, [])));
N_dist	    = length(u_dist);
ROCnum	    = zeros(N_dist, 4);
fprintf('start finding ROC ');
for i = 1 : N_dist
    nowdec  = u_dist(i);
    N_TP = 0;
    N_FN = 0;
    N_FP = 0;
    N_TN = 0;
    for j = 1 : N_face
	nowtestid   = faceid(j);
	nowalldec   = Alld(j, :);
	nowposidx   = [];

	for k = 1 : N_regis
	    temp = min(nowalldec(GalleryIdx{k, 1}));
	    if temp <= nowdec
		nowposidx = [nowposidx k];
	    end
	end
	nownegidx   = setdiff([1:k], nowposidx);

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

plot(FPRs, TPRs);
saveas(gcf, figurename);

