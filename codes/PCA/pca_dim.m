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

[images, regs, ids] = pca_read_data2(trainlist, gallerylist, 100, 80);

for tt = 1:length(testsets)
    testlist = testsets{tt};
    accuracy = zeros(length(sr), length(dims));
    realdims = zeros(length(sr), length(dims));

    for n = 1:length(sr)
        
        r = sr(n);
        c = sc(n);
        patchsize(n) = r*c;

		new_images = zeros(r*c, length(trainlist.name));
		new_regs = zeros(r*c, length(gallerylist.name));
		for k = 1:length(trainlist.name)
			new_images(:,k) = reshape(imresize(images(:,:,k), [r c]), [], 1);
		end

		for k = 1:length(gallerylist.name)
			new_regs(:, k) = reshape(imresize(regs(:,:,k), [r c]), [], 1);
		end

        for m = 1:length(dims)
            d = dims(m);
            realdims(n, m) = d;
            if d > r*c
                realdims(n, m) = r*c;
            end
            
            fprintf('(r,c,dim): (%d, %d, %d)...\n', r, c, realdims(n,m));
            [FRModel, disthd] = FRTrain_pca2( new_images, new_regs, ids, r, c, d );

            accuracy(n, m) = pca_accur( FRModel, disthd, testlist );

			fprintf('accuracy: %.3f\n', accuracy(n, m));
           %tic;
            %[FRModel, disthd] = lda_train( X, y, gX, gy, realdims(n,m), r, c );
            %toc;

            %accuracy(n, m) = FRTest( FRModel, disthd, testlist );
           
%            fprintf(' saving model %d x %d with dim %d ...\n', c, r, d );
 %           modelname = ['FRModel_scale' int2str(c) 'x' int2str(r) '_dim_' int2str(d) '.mat'];
  %          s = ['save -mat ' modelname ' FRModel' ];
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
    %filename = sprintf('../public-html/show/pr/pca_dim_%d.png', tt);
    %saveas(gcf, filename, 'png');
    %hold off;

    matname = sprintf('pca/accuracy_dim_%d.mat', tt);
    save(matname, 'accuracy');

	figX        = (dims' * ones(1, length(sr)))';
    figY        = mat.accuracy;
    legendname  = {'16 x 20', '32 x 40', '48 x 60', '64 x 80', '80 x 100'};
    titlename   = 'The relationship between patch size, dimensionality and accuracy using Eigen Faces';
    xname       = 'Dimensionality';
    yname       = 'Accuracy';
    filename    = sprintf('../public-html/show/pr/pca_dim_%d.png', tt);
    figplot(figX, figY, legendname, titlename, xname, yname, filename);


    %figX        = accuracy;
    %figY        = (dims' * ones(1, length(sr)))';
    %legendname  = {'16 x 20', '32 x 40', '48 x 60', '64 x 80', '80 x 100'};
    %titlename   = 'The relationship between patch size, dimensionality and accuracy using Eigen Faces';
    %xname       = 'Dimensionality';
    %yname       = 'Accuracy';
    %filename    = sprintf('../public-html/show/pr/pca_dim_%d.png', tt);
    %figplot(X, Y, legendname, titlename, xname, yname);

end

