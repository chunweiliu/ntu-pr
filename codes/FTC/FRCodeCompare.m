
function [bestid, alldist] = FRCodeCompare(GalleryCode, ProbeCode)

% FRCodeCompare
%   Compare Gallery Codes and Probe Codes and get the bestid and decision value
%
% input:
%   GalleryCode	    G * P	all G codes for P patch each
%   ProbeCode	    N * P	all N codes for P patch each
%
% output:
%   bestid	    N * 1	corresponding gallery index of each probe code
%   alldist	    N * G	all deicsion values of probe codes

N_gallery   = size(GalleryCode, 1);
N_probe	    = size(ProbeCode, 1);

bestid	= zeros(N_probe, 1);
alldist	= zeros(N_probe, N_gallery);

% for each probecode
for i = 1 : N_probe
    % find all decision value
    alldist(i, :) = sum(abs(GalleryCode - repmat(ProbeCode(i, :), N_gallery, 1)) > 0, 2)';

    % find the best id with minimum decision value
    [min_decvalue, min_id] = min(alldist(i, :));
    bestid(i) = min_id;
end


