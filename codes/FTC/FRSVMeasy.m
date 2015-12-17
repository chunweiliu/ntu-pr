
function [predict_label, SVMmodel, predict_Acc] = FRSVMeasy(training_label, training_data, ...
								test_label, test_data, cvfold, gamma_ranges, cost_ranges)
%
% FRSVMeasy:
%   same as easy.py; find the best SVM model and predict labels for test data
%
% input:
%   training_label	N * 1	    training labels for N data
%   training_data	N * D	    training data for D features each
%   test_label		M * 1	    test labels for M data 
%   test_data		M * D	    test data for D features each
%   cvfold		1 * 1	    (opt.)folds of cross validation
%   gamma_ranges	1 * G	    (opt.)all log2(gamma)
%   cost_ranges		1 * G	    (opt.)all log2(cost)
%
% output:
%   predict_label	M * 1	    predicted label from svmpredict with best model
%   SVMmodel		struct	    Best SVM model
%   predict_Acc		1 * 1	    accuracy of prediction
%

addpath('libsvm-mat-2.86-1');

if nargin < 5
    cvfold = 5;
end
if nargin < 6
    gamma_ranges = [-15:2:3];
end
if nargin < 7
    cost_ranges = [-5:2:15];
end

fprintf('start finding params...');
[svmparams, best_g, best_c, best_a] = FRSVMParams(training_label, training_data, cvfold, gamma_ranges, cost_ranges);
fprintf('done. ');
fprintf('best (log2g,log2c) = (%f, %f), bestacc = %f\n', best_g, best_c, best_a);

SVMmodel = svmtrain(training_label, training_data, svmparams);
[predict_label, predict_Acc] = svmpredict(test_label, test_data, SVMmodel);

