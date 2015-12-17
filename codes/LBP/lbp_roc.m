% function lbp_roc
% output: lbp_roc_X.png
%
gallerylist = FRgetdata('database/gallery.txt', 'database');
imposterlist = FRgetdata('database/imposter.txt', 'database');


testsets{1} = FRgetdata('database/probe_neutral.txt', 'database');
testsets{2} = FRgetdata('database/probe_illumination.txt', 'database');
testsets{3} = FRgetdata('database/probe_expression.txt', 'database');
testsets{4} = FRgetdata('database/probe_pose.txt', 'database');


for i = 1:length(testsets)
	output = sprintf('lbp_roc_%d.png', i);
	fprintf('Output: %s\n', output);
	[ROC1, ROC2, ROC3] = FRVerify(FRModel, disthd, testsets{i}, imposterlist, gallerylist, output, 100);
end
