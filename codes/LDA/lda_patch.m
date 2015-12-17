function accuracy = lda_patch
% function accuracy = lda_patch
% inputs:
%
% outputs:
%       accuracy    1 * 1   double      accruacy of different probe sets
%       write pda.png in public-html/show/pr

dims= [ 50, 100, 150, 175, 200, 250, 283, 300 ];
sr = [ 10, 20, 30, 45, 60, 75, 100 ]; %5
sc = [ 8, 16, 24, 36, 48, 60, 80 ]; %4
%dims = [50, 100];
%sr = [10, 20];
%sc = [8, 16];
colors = {[1, 0, 0], [1, 0.6471, 0], [0.85, 0.64, 0.125], [0, 1, 0], [0, 1, 1], [0, 0, 1], [0.5137, 0.4353, 1], [0.9, 0.2, 1]};

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
    %accuracy = zeros(length(sr), length(dims));
    %patchsize= zeros(length(sr), length(dims));
    accuracy = zeros(length(dims), length(sr));
    patchsize= zeros(length(dims), length(sr));
    for m = 1:length(dims)
        d = dims(m);
        for n = 1:length(sr)
            r = sr(n);
            c = sc(n);
            patchsize(m, n) = r*c;

            [FRModel, disthd] = FRLDATrain( trainlist, gallerylist, r, c, d );

            accuracy(m, n) = FRTest( FRModel, disthd, testlist );

        end
        color = colors{m};
        plot( log(patchsize(m,:)), accuracy(m,:), '-o', 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'color', color );
        hold on;
    end
    legend('50', '100', '150', '175', '200', '250', '283', '300', 2);
    %legend('50', '100');
    title( 'The relationship between patch size, dimensionality and accuracy using Fisher Faces' );
    xlabel('Log patch size');
    ylabel('Accuracy');

    filename = sprintf('../../../public-html/show/pr/lda_patch_%d.png', tt);
    saveas(gcf, filename, 'png');
    hold off;

    matname = sprintf('accuracy_patch_%d.mat', tt);
    save(matname, 'accuracy');
end

