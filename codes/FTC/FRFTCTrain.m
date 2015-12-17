
function [best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel] = FRFTCTrain(trainimg, idlist, FTCParams, ClusterParams)

%
% FRFTCTrain:
%   Face Trait Code Training -- finding best patches by given face images
% 
% input:
%   trainimg	    N * H * W	    training data
%   idlist	    N * 1	    corresponding id
%   FTCParams	    struct	    FTC parameters
%   ClusterParams   struct	    cluster parameters
%
% output:
%   best_patch	    P * 4	    each patch position and size (x, y, w, h)
%   best_ranges	    P * 1	    pattern range of each symbol
%   best_idclass    U * P	    each row for unique id whose numbers for each patches
%   best_pcamodel   P * 1 cell	    related PCA model for each patch
%   best_ldamodel   P * 1 cell	    related LDA model for each patch
%
% FTCParams struct
%   scale	    1 * 1	    scaling ratio of origin W, H deciding kinds of w and he
%   move	    1 * 1	    move ratio of current window w, h deciding kinds of x and y
%   nftp	    1 * 1	    objective number of best patches
%
% ClusterParams struct
%   method	    string	    'FJ' (default), 'GEM', ...
%   PCA_D	    1 * 1	    PCA dimension
%   LDA_D	    1 * 1	    LDA dimension
%   threshold	    1 * 1	    clustering threshold
%   maxclass	    1 * 1	    max number of clusters
%   meanflag	    1 * 1	    1 for mean used (default), now no use
%   HIE		    struct	    hierarchical clustering parameters
%
% HIE struct
%   pdist	    string	    pdist parameters
%   linkage	    string	    linkage parameters
%

addpath('LDALIB');
addpath('gmmbayestb-v1.0');

% image number, width, height
[imgnum imgheight imgwidth] = size(trainimg);

% initial parameters
scale_D = FTCParams.scale;
move_D	= FTCParams.move;
N_FTP	= FTCParams.nftp;

% find all possible patches
fprintf('start finding possibel patch with scale %f, move %f...', scale_D, move_D);
tic;
all_patch = [];

w = imgwidth : -ceil(scale_D * imgwidth) : 1;
h = imgheight : -ceil(scale_D * imgheight) : 1;
[w h] = meshgrid(w, h);
all_wh = [reshape(w, [], 1) reshape(h, [], 1)];
for i = 1 : size(all_wh, 1);
    w = all_wh(i, 1);
    h = all_wh(i, 2);

    if w * h < 0.06 * imgheight * imgwidth 
	continue;
    end

    for y = 1 : ceil(h * move_D) : imgheight - h + 1
	for x = 1 : ceil(w * move_D) : imgwidth - w + 1
	    all_patch = [all_patch; x y w h];
	end
    end
end
% all_patch'
clear x y w h all_wh
stime = toc;
fprintf('done, total %d patches, %.3f secs spent\n', size(all_patch, 1), stime);


% clustering each patches
fprintf('start clustering...\n');
tic;
[all_ranges, all_idclass, all_pcamodel, all_ldamodel] = FRClusterTrain(trainimg, idlist, all_patch, ClusterParams);
stime = toc;
fprintf('done, total %.3f secs spent\n', stime);

% construct PPM 
fprintf('construct PPM...');
tic;
N_patch = size(all_patch, 1);
L	= size(all_idclass, 1);
PPM	= zeros(N_patch, L * (L - 1) / 2);
for i = 1 : all_patch
    PPM(i, :) = double(pdist(all_idclass(:, i)) ~= 0)';
end
stime = toc;
fprintf('done, total %.3f secs spent\n', stime);

% find the best patch in patches pool
% matrix for final best patches coordinates
best_patch	= zeros(N_FTP, 4);
best_ranges	= zeros(N_FTP, 1);
best_idclass	= zeros(L, N_FTP);
best_pcamodel	= cell(N_FTP, 1);
best_ldamodel	= cell(N_FTP, 1);

% set w for weight and C for C_weight
w = ones(1, size(PPM, 2));
C = zeros(1, size(PPM, 2));
candidate = 1 : size(PPM, 1);

% for each round, find the best patch in the pool
fprintf('start finding %d best patches...', N_FTP);
tic;
for i = 1 : N_FTP
    % get now PPM size
    n_left = length(candidate);

    % normalize weight
    w = w ./ sum(w);

    % add PPM up and find the maximum index/value of PPM
    [maxvalue, candidx] = max(PPM(candidate, :) * w');
    maxidx = candidate(candidx);

    % remove maxidx out of candidate
    candidate(candidx) = [];

    % store in the best patch matrix
    best_patch(i, :)	= all_patch(maxidx, :);
    best_ranges(i)	= all_ranges(maxidx);
    best_idclass(:, i)	= all_idclass(:, maxidx);
    best_pcamodel(i, 1) = all_pcamodel(maxidx, 1);
    best_ldamodel(i, 1) = all_ldamodel(maxidx, 1);
    
    % update C 
    C = C + PPM(maxidx, :);
    
    % find out Cmin, Cmax
    Cmin = min(C);
    Cmax = max(C);
    
    % update weight
    w(:) = 1;
    w(C == Cmin) = L;
    w(C == Cmax) = 0;

    fprintf('.');
end
stime = toc;
fprintf('done, total %.3f secs spent\n', stime);






