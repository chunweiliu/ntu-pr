
function [IdentAcc, hit, best_cluster, best_model, GalleryCode, ProbeCode] ... 
		= FRFTCAll(ExtImg, ExtId, VarImg, VarId, GalleryImg, GalleryId, ProbeImg, ProbeId, best_patch, ClusterParams, SVMParams)

%
% FRFTCAll
%   All Identification Procedure from best patches and source images to get Identification accuracy
%
% input:
%   ExtImg	    N * D	Ext Image
%   ExtId	    N * 1	Ext Id
%   VarImg	    N * D	Var Image
%   VarId	    N * 1	Var Id
%   GalleryImg      N * D	Gallery Image  
%   GalleryId	    N * 1	Gallery Id
%   ProbeImg        N * D	Probe Image 
%   ProbeId         N * 1	Probe Id
%   best_patch	    P * 4	patch positions
%   ClusterParams   struct	clustering params
%   SVMParams	    struct	SVM params
%
% output:
%   IdentAcc	    1 * 1	Identification Accuracy
%   hit		    1 * 1	number of hit
%   best_cluster    struct	Clustering result
%   best_model	    P * 1 cell	SVM models
%   GalleryCode	    G * P	all encoded gallery codes
%   ProbeCode	    H * P	all encoded probe codes
%
% ClusterParams struct
%   PCA_D	    1 * 1	dimension of PCA
%   LDA_D	    1 * 1	dimension of LDA
%
% SVMParams struct
%   fold	    1 * 1	cross validation folds
%   gammas	    1 * g	possible candidate of gammas
%   costs	    1 * c	possible candidate of costs
%
% best_cluster struct
%   ranges	    1 * P	range of each patch
%   idclass	    G'* P	each gallery id to each patch
%   best_pcamodel   cells	PCA model obtained from LDALIB pca algorithm
%   best_ldamodel   cells	LDA model obtained from LDALIB lda algorithm
%

N_patch = size(best_patch, 1);

% Clustering
[best_ranges, best_idclass, best_pcamodel, best_ldamodel] ...
			= FRClusterTrain(ExtImg, ExtId, best_patch, ClusterParams.PCA_D, ClusterParams.LDA_D);
best_cluster.ranges	= best_ranges;
best_cluster.idclass	= best_idclass;
best_cluster.pcamodel	= best_pcamodel;
best_cluster.ldamodel	= best_ldamodel;

% SVM training (cross validation)
% training data
[Training_label, Training_data] ...
		= FRgettrain(ExtImg, ExtId, VarImg, VarId, best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel);


% cross validation
best_model = cell(N_patch, 1);
for i = 1 : N_patch
    best_params		= FRSVMParams(Training_label{i, 1}, Training_data{i, 1}, SVMParams.fold, SVMParams.gammas, SVMParams.costs);
    best_model{i, 1}	= svmtrain(Training_label{i, 1}, Training_data{i, 1}, best_params);
end

% Gallery Code
GalleryCode = zeros(length(GalleryId), N_patch);
GalleryData = FRgettest(GalleryImg, best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel);
for i = 1 : size(best_patch, 1)
    GalleryCode(:, i) = svmpredict(zeros(length(GalleryId), 1), GalleryData{i, 1}, best_model{i, 1});
end

% Probe Code
ProbeCode = zeros(length(ProbeId), N_patch);
ProbeData = FRgettest(ProbeImg, best_patch, best_ranges, best_idclass, best_pcamodel, best_ldamodel);
for i = 1 : size(best_patch, 1)
    ProbeCode(:, i) = svmpredict(zeros(length(ProbeId), 1), ProbeData{i, 1}, best_model{i, 1});
end


% Identification
galleryidx  = FRCodeCompare(GalleryCode, ProbeCode);
TestId	    = GalleryId(galleryidx);

hit	    = sum(TestId == ProbeId);
total	    = length(TestId);
IdentAcc    = hit / total;

