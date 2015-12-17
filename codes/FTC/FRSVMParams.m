
function [best_params, best_gamma, best_cost, best_acc, total_acc] = ...
					FRSVMParams(training_label, training_data, n_fold, gamma_ranges, cost_ranges)

%
% FRSVMParams
%   find best params of SVM for given cost and gamma ranges
%
% input:
%   training_label	N * 1	    training labels for N data
%   training_data	N * D	    training data for D features each
%   n_fold		1 * 1	    cross-validation fold
%   gamma_ranges	1 * G	    all log2(gamma)
%   cost_ranges		1 * C	    all log2(cost)
%
% output:
%   best_params		string	    SVM params for best model
%   best_gamma		1 * 1       the find out best log2(gamma)
%   best_cost		1 * 1	    the find out best log2(cost)
%   best_acc		1 * 1	    corresponding best accuracy
%   total_acc		C * G	    total accuracy of each trial
%

[X, Y] = meshgrid(gamma_ranges, cost_ranges);
total_gc = [reshape(X, [], 1) reshape(Y, [], 1)];

best_acc = -1;
bestidx = 0;
best_params = '';
total_acc = zeros(size(total_gc, 1), 1);
% fprintf('\n');
for i = 1 : size(total_gc, 1);
    now_gamma	    = sprintf('%.12f', 2 ^ total_gc(i, 1));
    now_cost	    = sprintf('%.12f', 2 ^ total_gc(i, 2));
    svmparams	    = ['-g ' now_gamma ' -c ' now_cost];
    % total_acc(i)    = FRCrossValidation(training_label, training_data, n_fold, svmparams);
    total_acc(i)    = svmtrain(training_label, training_data, [svmparams ' -v ' num2str(n_fold)]);
    % fprintf('%s %f\n', svmparams, total_acc(i));
    if total_acc(i) > best_acc
	bestidx = i;
	best_acc = total_acc(i);
	best_params = svmparams;
    end
    fprintf('.');
end
fprintf('*');

best_gamma = total_gc(bestidx, 1);
best_cost = total_gc(bestidx, 2);
total_acc = reshape(total_acc, length(cost_ranges), length(gamma_ranges));


