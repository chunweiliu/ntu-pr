function accuracy = pca_test(FRModel, disthd)
% function lbp_roc
% output: lbp_roc_X.png
%

testsets{1} = FRgetdata('database/probe_neutral.txt', 'database');
testsets{2} = FRgetdata('database/probe_illumination.txt', 'database');
testsets{3} = FRgetdata('database/probe_expression.txt', 'database');
testsets{4} = FRgetdata('database/probe_pose.txt', 'database');

accuracy = zeros(4);

for i = 1:length(testsets)
	accuracy(i) = pca_accur(FRModel, disthd, testsets{i});
	fprintf('%d: %f\n', i, accuracy(i));
end
