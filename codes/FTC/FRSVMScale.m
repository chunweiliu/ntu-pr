
function [scaledata, scalemodel] = FRSVMScale(data, model)
%
% FRSVMScale
%   scaling svm data to [-1, 1] for each dimension
%
% input:
%   data	N * D	    N data with D dimension
%   model	struct	    (opt.) given scaling model 
%
% output:
%   scaledata	N * D	    data after scaling
%   scalemodel	struct	    corresponding scaling model
%
% struct scalemodel
%   featmax	1 * D	    maximum of each dim
%   featmin	1 * D	    minimum of each dim
%

if nargin < 2
    scalemodel.featmin = zeros(1, size(data, 2));
    scalemodel.featmax = zeros(1, size(data, 2));
    for i = 1 : size(data, 2)
        scalemodel.featmin(i) = min(data(:, i));
	scalemodel.featmax(i) = max(data(:, i));
    end
else
    scalemodel = model;
end

featdiff = scalemodel.featmax - scalemodel.featmin;

for i = 1 : size(data, 2)
    if featdiff(i) ~= 0
	scaledata(:, i) = (data(:, i) - scalemodel.featmin(i)) / featdiff(i) * 2 - 1;
    else
	fprintf('warning: min and max are equal in %d dim\n', i);
	scaledata(:, i) = data(:, i);
    end
end
