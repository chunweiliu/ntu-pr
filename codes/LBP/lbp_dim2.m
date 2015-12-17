% function accuracy = lbp_dim
% inputs:
%
% outputs:
%       accuracy    1 * 1   double      accruacy of different probe sets
%       write pda.png in public-html/show/pr

dims= [ 4, 8, 16 ];
sr = [ 16, 32, 64, 128, 256 ]; %5
sc = [ 16, 32, 64, 128, 256 ]; %4

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

%[images, regs, ids] = lbp_read_data(trainlist, gallerylist, 256, 256);


for tt = 1:length(testsets)

    matname = sprintf('lbp/accuracy_dim_%d.mat', tt);
    %save(matname, 'accuracy');

	mat = load(matname);

   	figX        = (dims' * ones(1, length(sr)))';
    figY        = mat.accuracy;
    legendname  = {'16 x 16', '32 x 32', '64 x 64', '128 x 128', '256 x 256'};
    titlename   = 'The relationship between patch size, dimensionality and accuracy using LBP';
    xname       = 'Dimensionality';
    yname       = 'Accuracy';
    filename    = sprintf('../public-html/show/pr/lbp_dim_%d.png', tt);
    figplot(figX, figY, legendname, titlename, xname, yname, filename);


end

