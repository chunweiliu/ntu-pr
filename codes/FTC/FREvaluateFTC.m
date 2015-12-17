
function [RetStruct] = FREvaluateFTC(ClusterParams, SVMParams, FTCParams);

% FREvaluateFTC
%   evaluate parameters including Clustering, SVM training, and patch finding
% 
% input:
%   ClusterParams   struct	    clustering related parameters
%   SVMParams	    struct	    SVM related parameters
%   FTCParams	    struct	    FTC related parameters
%
% output:
%   RetSturct	    struct	    return evaluation result
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
% SVMParams struct
%   fold	    1 * 1	    cross validation folds
%   gammas	    1 * g	    possible candidate of gammas
%   costs	    1 * c	    possible candidate of costs
%
% FTCParams struct
%   scale	    1 * 1	    scaling ratio of origin W, H deciding kinds of w and he
%   move	    1 * 1	    move ratio of current window w, h deciding kinds of x and y
%   nftp	    1 * 1	    objective number of best patches
%
% RetStruct struct
%   bestpatch	    P * 4	    patch position
%   ranges	    P * 1	    range of each patch
%   idclass	    G * P	    gallery-id to patch enum
%   pcamodel	    P * 1 cell	    pca models for each patch
%   ldamodel	    P * 1 cell	    lda models for each patch
%   ClusterParams   struct	    clustering params
%   svmmodel	    P * 1 cell	    best svm model for each patch
%   scalemodel	    P * 1 cell	    corresponding scaling model for each patch
%   SVMParams	    struct	    SVM params
%   bestparam	    P * 1struct	    best cost and gamma
%   neuacc	    1 * 1	    accuracy of neutral probe set
%   poseacc	    1 * 1	    accuracy of pose  probe set
%   illacc	    1 * 1	    accuracy of illuminance probe set
%   expacc	    1 * 1	    accuracy of expression probe set
%
% bestparam struct
%   g		    1 * 1	    best gamma
%   c		    1 * 1	    best cost 
%   acc		    1 * 1	    best acc of cross validation
%


fprintf('get datalist...\n');
trainlist   = FRgetdata('database/training.txt', 'database');
gallerylist = FRgetdata('database/gallery.txt', 'database');
neulist	    = FRgetdata('database/probe_neutral.txt', 'database');
poselist    = FRgetdata('database/probe_pose.txt', 'database');
illlist	    = FRgetdata('database/probe_illumination.txt', 'database');
explist	    = FRgetdata('database/probe_expression.txt', 'database');

imgsize = [80 100];
normparam.normflag  = 0;
normparam.normxy    = [127 10];
if isfield(ClusterParams, 'normflag') == 1
    normparam.normflag = ClusterParams.normflag;
    if isfield(ClusterParams, 'normxy') == 1
	normparam.normxy = ClusterParams.normxy;
	fprintf('normalize: flag %d, x %f, y %f\n', ClusterParams.normflag, ClusterParams.normxy(1), ClusterParams.normxy(2));
    else
	fprintf('normalize: flag %d\n', ClusterParams.normflag);
    end
end
if isfield(ClusterParams, 'scaleratio') == 1
    fprintf('scaling %f\n', ClusterParams.scaleratio);
    % scale patches
    if ClusterParams.scaleratio < 1
	imgsize	    = ceil(imgsize * ClusterParams.scaleratio);
    else
	imgsize	    = floor(imgsize * ClusterParams.scaleratio);
    end
end

fprintf('get images...\n');
TrainImg    = loadimg(trainlist.name, imgsize(1), imgsize(2), normparam);
GalleryImg  = loadimg(gallerylist.name, imgsize(1), imgsize(2), normparam);
NeuImg	    = loadimg(neulist.name, imgsize(1), imgsize(2), normparam);
PoseImg	    = loadimg(poselist.name, imgsize(1), imgsize(2), normparam);
IllImg	    = loadimg(illlist.name, imgsize(1), imgsize(2), normparam);
ExpImg	    = loadimg(explist.name, imgsize(1), imgsize(2), normparam);

tempidx	    = find(prod(trainlist.feat(:, [1 4 6:10]), 2) == 1);
tempidx2    = find(trainlist.feat(tempidx, 5) == 1);
tempidx3    = find(trainlist.feat(tempidx, 5) == 2);
extidx	    = tempidx([tempidx2; tempidx3]);
varidx	    = setdiff(1:length(trainlist.name), extidx)';

ExtImg	    = TrainImg(extidx, :, :);
VarImg	    = TrainImg(varidx, :, :);

ExtId	    = trainlist.id(extidx, 1);
VarId	    = trainlist.id(varidx, 1);
GalleryId   = gallerylist.id(:, 1);
NeuId	    = neulist.id(:, 1);
PoseId	    = poselist.id(:, 1);
IllId	    = illlist.id(:, 1);
ExpId	    = explist.id(:, 1);

clear TrainImg tempidx tempidx2 tempidx3 extidx varidx

fprintf('FTC Training...\n');
[best_patch, ranges, idclass, pcamodel, ldamodel] = FRFTCTrain(ExtImg, ExtId, FTCParams, ClusterParams);

RetStruct.bestpatch	= best_patch;
RetStruct.ranges	= ranges;
RetStruct.idclass	= idclass;
RetStruct.pcamodel	= pcamodel;
RetStruct.ldamodel	= ldamodel;
RetStruct.ClusterParams = ClusterParams;

fprintf('Code Training...\n');
[svmmodel, scalemodel, bestparam] = FRCodeTrain(ExtImg, ExtId, VarImg, VarId, best_patch, ranges, idclass, pcamodel, ldamodel, SVMParams);

RetStruct.svmmodel	= svmmodel;
RetStruct.scalemodel	= scalemodel;
RetStruct.SVMParams	= SVMParams;
RetStruct.bestparam	= bestparam;

fprintf('encoding...\n');
GCode	= FRCodeTest(GalleryImg, best_patch, ranges, idclass, pcamodel, ldamodel, svmmodel, scalemodel);
NCode	= FRCodeTest(NeuImg, best_patch, ranges, idclass, pcamodel, ldamodel, svmmodel, scalemodel);
PCode	= FRCodeTest(PoseImg, best_patch, ranges, idclass, pcamodel, ldamodel, svmmodel, scalemodel);
ICode	= FRCodeTest(IllImg, best_patch, ranges, idclass, pcamodel, ldamodel, svmmodel, scalemodel);
ECode	= FRCodeTest(ExpImg, best_patch, ranges, idclass, pcamodel, ldamodel, svmmodel, scalemodel);

fprintf('identification...\n');
bestidx		    = FRCodeCompare(GCode, NCode);
RetStruct.neuacc    = sum(GalleryId(bestidx) == NeuId) / length(NeuId);
bestidx		    = FRCodeCompare(GCode, PCode);
RetStruct.poseacc   = sum(GalleryId(bestidx) == PoseId)/ length(PoseId);
bestidx		    = FRCodeCompare(GCode, ICode);
RetStruct.illacc    = sum(GalleryId(bestidx) == IllId) / length(IllId);
bestidx		    = FRCodeCompare(GCode, ECode);
RetStruct.expacc    = sum(GalleryId(bestidx) == ExpId) / length(ExpId);

function Img = loadimg(name, w, h, normparam)
%
Img = zeros(length(name), h, w);
for i = 1 : length(name)
    temp = FRgetimg(name{i, 1}, w, h);
    Img(i, :, :) = FRimgnormxy(temp, normparam.normxy(1), normparam.normxy(2), normparam.normflag);
end
