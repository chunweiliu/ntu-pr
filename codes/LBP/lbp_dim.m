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

[images, regs, ids] = lbp_read_data(trainlist, gallerylist, 256, 256);


for tt = 1:length(testsets)
    testlist = testsets{tt};
    accuracy = zeros(length(sr), length(dims));
    realdims = zeros(length(sr), length(dims));

    for n = 1:length(sr)
        
        r = sr(n);
        c = sc(n);
        patchsize(n) = r*c;

		new_regs = zeros(r,c, length(gallerylist.name));
		for k = 1:length(gallerylist.name)
			new_regs(:,:, k) = imresize(regs(:,:,k), [r c]);
		end

        for m = 1:length(dims)
            d = dims(m);
            realdims(n, m) = d;
            if d > r*c
                realdims(n, m) = r*c;
            end
            
            fprintf('(r,c,dim): (%d, %d, %d)...\n', r, c, realdims(n,m));
            [FRModel, disthd] = FRTrain_lbp2( new_images, new_regs, ids, r, c, d );

            accuracy(n, m) = lbp_accur( FRModel, disthd, testlist );

			fprintf('accuracy: %.3f\n', accuracy(n, m));
           %tic;
            %[FRModel, disthd] = lda_train( X, y, gX, gy, realdims(n,m), r, c );
            %toc;

            %accuracy(n, m) = FRTest( FRModel, disthd, testlist );
           
%            fprintf(' saving model %d x %d with dim %d ...\n', c, r, d );
 %           modelname = ['FRModel_scale' int2str(c) 'x' int2str(r) '_dim_' int2str(d) '.mat'];
  %          s = ['save -mat ' modelname ' FRModel' ]
   %         eval(s);
    %        distname = ['disthd_' int2str(c) 'x' int2str(r) '_dim_' int2str(d) '.mat'];
     %       s = ['save -mat ' distname ' disthd'];
      %      eval(s);            
        end

        %color = colors{n};
        %plot( realdims(n,:), accuracy(n,:), '-o', 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'color', color );
        %hold on;
    end
    %legend('16x20', '32x40', '48x60', '64x80', '80*100');
    %title( 'The relationship between patch size, dimensionality and accuracy using Eigen Faces' );
    %xlabel('Dimensionality');
    %ylabel('Accuracy');
    %filename = sprintf('../public-html/show/pr/lbp_dim_%d.png', tt);
    %saveas(gcf, filename, 'png');
    %hold off;

    matname = sprintf('lbp/accuracy_dim_%d.mat', tt);
    save(matname, 'accuracy');

   	figX        = (dims' * ones(1, length(sr)))';
    figY        = accuracy;
    legendname  = {'16 x 16', '32 x 32', '64 x 64', '128 x 128', '256 x 256'};
    titlename   = 'The relationship between patch size, dimensionality and accuracy using LBP';
    xname       = 'Dimensionality';
    yname       = 'Accuracy';
    filename    = sprintf('../public-html/show/pr/lbp_dim_%d.png', tt);
    figplot(figX, figY, legendname, titlename, xname, yname, filename);


end

