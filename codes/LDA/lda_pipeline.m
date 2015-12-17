function accuracy = lda_pipeline
% function accuracy = lda_pipeline
% inputs:
%
% outputs:
%       accuracy    1 * 1   double      accruacy of different probe sets

dim= [ 50, 100, 150, 175, 200, 243, 300 ];
sr = [ 10, 20, 30, 45, 60, 75, 100 ]; %5
sc = [ 8, 16, 24, 36, 48, 60, 80 ]; %4
%dim = [100, 243, 400];
%sr = 10;
%sc = 8;
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
    tElapsed = zeros(length(dim), length(sr));
    accuracy = zeros(length(dim), length(sr));
    for m = 1:length(dim)
        for n = 1:length(sr)
            d = dim(m);

            r = sr(n);
            c = sc(n);
            patchsize(n) = r*c;

            fprintf('Start process images in size (%d * %d) with %d dim ...\n', r, c, d);
    
            % training the model and distance function handle
            tStart = tic;
            [model, hd] = FRLDATrain( trainlist, gallerylist, r, c, d );
            tElapsed(m, n) = toc(tStart);

            accuracy(m, n) = FRTest( model, hd, testlist );

        end
        color = colors{n};
        plot( patchsize, accuracy(m,:), '-o', 'MarkerFaceColor', color, 'MarkerEdgeColor', color );
        hold on;
    end
    %legend(' 8*10', '16*20', '24*30', '36*45', '48*60', '60*75', '80*100');
    %legend(' 8*10');
    legend('50', '100', '150', '175', '200', '243', '300');
    title( 'The relationship between patch size, dimentionality and accuracy' );
    xlabel('Patch size');
    ylabel('Accuracy');
    set(gca,'XTick',[0, 1, 2, 3, 4, 5, 6],'xticklabel',patchsize(1,:));

    filename = sprintf('../../../public-html/show/pr/lda_pipeline_%d.png', tt);
    saveas(gcf, filename, 'png');

    hold off;

    matname = sprintf('accuracy_patch_%d.mat', tt);
    save(matname, 'accuracy');

end
