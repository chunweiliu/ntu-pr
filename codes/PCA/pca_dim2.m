% function accuracy = pca_dim
% inputs:
%
% outputs:
%       accuracy    1 * 1   double      accruacy of different probe sets
%       write pda.png in public-html/show/pr

dims= [ 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 283, 300 ];
sr = [ 20, 40, 60, 80, 100 ]; %5
sc = [ 16, 32, 48, 64, 80 ]; %4
%dims = [50, 100];
%sr = [10, 20];
%sc = [8, 16];
%colors = {[1, 0, 0], [1, 0.6471, 0], [0.85, 0.64, 0.125], [0, 1, 0], [0, 1, 1], [0, 0, 1], [0.5137, 0.4353, 1]};
colors = {[1, 0, 0], [1, 0.6471, 0], [0.85, 0.64, 0.125], [0, 1, 0], [0, 1, 1]};

% get the data from training set and gallery (registration) set
trainlist   = FRgetdata('database/training.txt', 'database');
gallerylist = FRgetdata('database/gallery.txt', 'database');
% get the testing sample 
testsets{1} = FRgetdata('database/probe_neutral.txt', 'database');
testsets{2} = FRgetdata('database/probe_illumination.txt', 'database');
testsets{3} = FRgetdata('database/probe_expression.txt', 'database');
testsets{4} = FRgetdata('database/probe_pose.txt', 'database');

%[images, regs, ids] = pca_read_data2(trainlist, gallerylist, 100, 80);

for tt = 1:length(testsets)
    matname = sprintf('pca/accuracy_dim_%d.mat', tt);
    %save(matname, 'accuracy');

	mat = load(matname);

	figX        = (dims' * ones(1, length(sr)))';
    figY        = mat.accuracy;
    legendname  = {'16 x 20', '32 x 40', '48 x 60', '64 x 80', '80 x 100'};
    titlename   = 'The relationship between patch size, dimensionality and accuracy using Eigen Faces';
    xname       = 'Dimensionality';
    yname       = 'Accuracy';
    filename    = sprintf('../public-html/show/pr/pca_dim_%d.png', tt);
    figplot(figX, figY, legendname, titlename, xname, yname, filename);

end

