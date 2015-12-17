
function [ranges, id_cluster, pca_model, lda_model] = FRClusterTrain(trainimg, idlist, best_patch, ClusterParams)
%
% FRClusterTrain:
%   Clustering each patch in trainimg to obtain FTC symbol ranges
%
% input:
%   trainimg	    N * H * W	    training data
%   idlist	    N * 1	    corresponding id
%   best_patch	    P * 4	    each patch position and size (x, y, w, h)
%   ClusterParams   struct	    cluster parameters
%
% output:
%   ranges	    P * 1	    pattern range of each symbol
%   id_cluster	    U * P	    each row for unique id whose numbers for each patches
%   pca_model	    P * 1 cell	    related PCA model for each patch
%   lda_model	    P * 1 cell	    related LDA model for each patch
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


% image num
imgnum = size(trainimg, 1);

% find id num
uidlist = unique(idlist);
L = length(uidlist);

if nargin < 4
    ClusterParams = [];
end

% some params
if isfield(ClusterParams, 'method') == 0
    ClusterParams.method    = 'FJ';
end
if isfield(ClusterParams, 'PCA_D') == 0
    ClusterParams.PCA_D	    = 8;
end
if isfield(ClusterParams, 'LDA_D') == 0
    ClusterParams.LDA_D	    = 6;
end
if isfield(ClusterParams, 'threshold') == 0
    ClusterParams.threshold = 1e-6;
end
if isfield(ClusterParams, 'maxclass') == 0
    ClusterParams.maxclass  = 20;
end
if isfield(ClusterParams, 'meanflag') == 0
    ClsuterParams.meanflag  = 1;
end

method	    = ClusterParams.method;
PCA_D	    = ClusterParams.PCA_D;
LDA_D	    = ClusterParams.LDA_D;
threshold   = ClusterParams.threshold;
maxclass    = ClusterParams.maxclass;
meanflag    = ClusterParams.meanflag;

% output ranges
n_patch	    = size(best_patch, 1);
ranges	    = zeros(n_patch, 1);
% c_means   = cell(n_patch, 1);
id_cluster  = zeros(L, n_patch);
pca_model   = cell(n_patch, 1);
lda_model   = cell(n_patch, 1);

% for each patch
fprintf('params: method %s, PCA %d, LDA %d, threshold %.3e, meanflag = %d\n', method, PCA_D, LDA_D, threshold, meanflag);
for np = 1 : size(best_patch, 1)
    % now position
    start_x  = best_patch(np, 1);
    start_y  = best_patch(np, 2);
    end_x    = best_patch(np, 3) + start_x - 1;
    end_y    = best_patch(np, 4) + start_y - 1;
    % now image patch
    now_data = reshape(trainimg(:, start_y:end_y, start_x:end_x), imgnum, []);

    % refine PCA_D
    PCA_D = min(best_patch(np, 3) * best_patch(np, 4), PCA_D);
    
    % PCA
    pcamodel		= pca(now_data', PCA_D);
    now_data		= linproj(now_data', pcamodel)';
    pca_model{np, 1}	= pcamodel;
    
    % LDA
    % 0. refine LDA_D
    LDA_D = min(PCA_D, LDA_D);
    % 1. reduce now_data to L * LDA_D
    ldadata.X = now_data';
    ldadata.y = idlist';
    ldamodel  = lda(ldadata, LDA_D);
    temp_data = (linproj(ldadata.X, ldamodel))';
    % 2. compute mean face for L subject
    now_data = zeros(L, LDA_D);    
    for i = 1 : L
	now_data(i, :) = mean(temp_data(find(idlist == uidlist(i)), :), 1);
    end

    lda_model{np, 1} = ldamodel;
    
    % find clusters: MJ-Algorithm
    % 1. FJ algo: find clusters for now_data
    % [bestk,bestpp,bestmu,bestcov,dl,countf] = mixtures4(now_data', 1, L, 0, 1e-2, 0);
    if strcmp(method, 'FJ') == 1
	FJ_params = {'Cmax', maxclass, 'thr', threshold};
	fprintf('.');
	while 1
	    bayesS = gmmb_create(now_data, ones(L, 1), 'FJ', FJ_params{:});
	    ranges(np) = size(bayesS.mu, 2);
	    % c_means{np, 1} = bayesS.mu';
	    if ranges(np) > 1
		fprintf('%d', ranges(np));
		for i = 1 : L
		    [tmpmin, id_cluster(i, np)]= min(sum((repmat(now_data(i, :), ranges(np), 1) - bayesS.mu') .^ 2, 2)); 
		end
		break;
	    else
		fprintf('*');
		continue;
	    end
	end
	fprintf('.');
    elseif strcmp(method, 'GEM') == 1
	GEM_params = {'Cmax', maxclass};
	fprintf('*');
	bayesS = gmmb_create(now_data, ones(L, 1), 'GEM', GEM_params{:});
	ranges(np) = size(bayesS.mu, 2);
	fprintf('%d', ranges(np));
	for i = 1 : L
	    [tmpmin, id_cluster(i, np)]= min(sum((repmat(now_data(i, :), ranges(np), 1) - bayesS.mu') .^ 2, 2)); 
	end
	fprintf('*');
    elseif strcmp(method, 'HIE') == 1
	fprintf('(');
	exestr = ['id_cluster(:, np) = clusterdata(now_data, ''maxclust'', maxclass'];
	if isfield(ClusterParams, 'HIE') == 1
	    if isfield(ClusterParams.HIE, 'pdist') == 1
		exestr = [exestr ', ''distance'', ''' ClusterParams.HIE.pdist ''''];
	    end
	    if isfield(ClusterParams.HIE, 'linkage') == 1
	    	exestr = [exestr ', ''linkage'', ''' ClusterParams.HIE.linkage ''''];
	    end
	end
	exestr = [exestr ');'];
	eval(exestr);

	ranges(np)	    = max(id_cluster(:, np));
	fprintf('%d', ranges(np));
	fprintf(')');
    else
	fprintf('not a supporting method: %s\n', method);
	return;
    end
end
fprintf('\n');

