fprintf('get datalist...\n');
trainlist   = FRgetdata('database/training.txt', 'database');
gallerylist = FRgetdata('database/gallery.txt', 'database');
neulist	    = FRgetdata('database/probe_neutral.txt', 'database');
poselist    = FRgetdata('database/probe_pose.txt', 'database');
illlist	    = FRgetdata('database/probe_illumination.txt', 'database');
explist	    = FRgetdata('database/probe_expression.txt', 'database');

imgsize = [80 100];

fprintf('get images...\n');
TrainImg    = zeros(length(trainlist.name), imgsize(2), imgsize(1));
for i = 1 : size(TrainImg, 1)
    TrainImg(i, :, :) = FRgetimg(trainlist.name{i, 1}, imgsize(1), imgsize(2));
end

GalleryImg    = zeros(length(gallerylist.name), imgsize(2), imgsize(1));
for i = 1 : size(GalleryImg, 1)
    GalleryImg(i, :, :) = FRgetimg(gallerylist.name{i, 1}, imgsize(1), imgsize(2));
end

NeuImg    = zeros(length(neulist.name), imgsize(2), imgsize(1));
for i = 1 : size(NeuImg, 1)
    NeuImg(i, :, :) = FRgetimg(neulist.name{i, 1}, imgsize(1), imgsize(2));
end

PoseImg    = zeros(length(poselist.name), imgsize(2), imgsize(1));
for i = 1 : size(PoseImg, 1)
    PoseImg(i, :, :) = FRgetimg(poselist.name{i, 1}, imgsize(1), imgsize(2));
end

IllImg    = zeros(length(illlist.name), imgsize(2), imgsize(1));
for i = 1 : size(IllImg, 1)
    IllImg(i, :, :) = FRgetimg(illlist.name{i, 1}, imgsize(1), imgsize(2));
end

ExpImg    = zeros(length(explist.name), imgsize(2), imgsize(1));
for i = 1 : size(ExpImg, 1)
    ExpImg(i, :, :) = FRgetimg(explist.name{i, 1}, imgsize(1), imgsize(2));
end

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

