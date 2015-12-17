function [best_id, all_decvalue] = FRLDATest(FRModel, testname)
% function [best_id, all_decvalue] = FRCodeTest(FRModel, testname)
% FRLDATest:
%   test the given image with Face Recognition Model
% input:
%   FRModel     1*1 struct      Face Recognition Model
%   testname    string          test image possition
% output:
%   best_id     1*1 double      the closest id in gallery set
%   all_decv    1*n double      decision value for each gallery id

% get test image and project it to pca and then lda space
sr          = FRModel.sr;
sc          = FRModel.sc;
eVec        = FRModel.eVec;
testimg     = FRModel.getimg( testname, sr, sc );

model       = FRModel.model;

% project to pca space and project to lda space
testvec     = reshape( testimg, size(testimg, 1)*size(testimg, 2), 1);
testvec     = eVec' * testvec;
lda_test    = linproj( testvec, model );

% find the distance between test image and all gallery
gallery     = FRModel.gallery;
X           = gallery.X;%( 1:size(gallery, 1)-1, :);
y           = gallery.y;%( size(gallery, 1), :);

dis_matric  = repmat( lda_test, 1, length(gallery.y) );
dis_matric  = dis_matric - X;
dis_matric  = dis_matric .^2;
dis_matric  = sum( dis_matric );

all_decvalue = dis_matric;
[ min_decvalue, min_id ] = min( all_decvalue );
best_id = y( min_id );
