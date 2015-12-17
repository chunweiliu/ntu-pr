function accuracy = lda_dim
% function accuracy = lda_dim
% inputs:
%
% outputs:
%       accuracy    1 * 1   double      accruacy of different probe sets
%       write pda.png in public-html/show/pr

dims= [ 50, 100, 150, 200, 250, 283, 300 ];
sr = [ 10, 20, 30, 45, 60, 75, 100 ]; %5
sc = [ 8, 16, 24, 36, 48, 60, 80 ]; %4
%dims = [50, 100];
%sr = [10, 20];
%sc = [8, 16];
colors = {[1, 0, 0], [1, 0.6471, 0], [0.85, 0.64, 0.125], [0, 1, 0], [0, 1, 1], [0, 0, 1], [0.5137, 0.4353, 1]};

% get the data from training set and gallery (registration) set
trainlist   = FRgetdata('database/training.txt', 'database');
gallerylist = FRgetdata('database/gallery.txt', 'database');
% get the testing sample 
testsets{1} = FRgetdata('database/probe_neutral.txt', 'database');
testsets{2} = FRgetdata('database/probe_illumination.txt', 'database');
testsets{3} = FRgetdata('database/probe_expression.txt', 'database');
testsets{4} = FRgetdata('database/probe_pose.txt', 'database');

for tt = 1:length(testsets)
    testlist = testsets{tt};
    accuracy = zeros(length(sr), length(dims));
    realdims = zeros(length(sr), length(dims));
    for n = 1:length(sr)
        
        r = sr(n);
        c = sc(n);
        patchsize(n) = r*c;
        fprintf('For patch size (%d * %d)\n', c, r);
        % Load intensity images from training list
        fprintf('1. loading training images ... ');
        tic;
        TMP = getimg( trainlist.name{1, 1}, r, c );
        dim = size( TMP, 1 )*size( TMP, 2 );

        X  = zeros( dim, size(trainlist.id, 1) );
        y  = zeros( 1, size(trainlist.id, 1) );
        for nn = 1 : length(trainlist.name)
            GRAY    = getimg( trainlist.name{nn, 1}, r, c );
            imgvec  = reshape( GRAY, dim, 1 );
            X(:,nn) = imgvec;
            y(nn)   = trainlist.id(nn, 1);
        end
        toc;

        % Using model transfrom all images in gallery list
        fprintf('2. loading gallery images ... ');
        tic;
        TMP = getimg( gallerylist.name{1, 1}, r, c );
        dim = size( TMP, 1 )*size( TMP, 2 );

        gX  = zeros( dim, size(gallerylist.id, 1) );
        gy  = zeros( 1, size(gallerylist.id, 1) );
        for nn = 1 : length(gallerylist.name)
            GRAY    = getimg( gallerylist.name{nn, 1}, r, c );
            imgvec  = reshape( GRAY, dim, 1 );
            gX(:,nn) = imgvec;
            gy(nn)   = gallerylist.id(nn, 1);
        end
        toc;


        for m = 1:length(dims)
            d = dims(m);
            realdims(n, m) = d;
            if d > r*c
                realdims(n, m) = r*c;
            end
            
            fprintf(' process with %d dim ...\n', realdims(n,m));
            tic;
            [FRModel, disthd] = lda_train( X, y, gX, gy, realdims(n,m), r, c );
            toc;

            accuracy(n, m) = FRTest( FRModel, disthd, testlist );

        end

        color = colors{n};
        plot( realdims(n,:), accuracy(n,:), '-o', 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'color', color );
        hold on;
    end
    legend('8*10', '16*20', '24*30', '36*45', '48*60', '60*75', '80*100');
    title( 'The relationship between patch size, dimensionality and accuracy using Fisher Faces' );
    xlabel('Dimensionality');
    ylabel('Accuracy');
    filename = sprintf('../../../public-html/show/pr/lda_dim_%d.png', tt);
    saveas(gcf, filename, 'png');
    hold off;

    matname = sprintf('accuracy_dim_%d.mat', tt);
    save(matname, 'accuracy');
end

