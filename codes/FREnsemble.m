
function [acc, predictids, allids] = FREnsemble(IdentModels, Disthds, testname, testid, GalleryId, FTCthres) 

% FREnsemble
%   Ensemble all LBP, LDA, FTC methods to recognition
%
% input:
%   IdentModels	    1 * 3 cells	    each cell with FRModel of one method
%   Disthds	    1 * 3 cells	    each cell wtih disthd of one method
%   testname	    N * 1 cells	    all image path of test faces
%   testid	    N * 1	    corresponding test id
%   GalleryId	    G * 1	    Recognition Gallery id 
%   FTCthres	    1 * 1	    FTC threshold for judging
%
% output:
%   acc		    1 * 1	    Identification rate 
%   predictids	    N * 1	    predicted id from ensemble method for each testface
%   allids	    N * 3	    predicted id from each method for each testface
%
% Exemple:
%   glist = FRgetdata('database/gallery.txt', 'database');
%   plist = FRgetdata('database/probe_neutral.txt', 'database');
%   ilist = FRgetdata('database/imposter.txt', 'database');
%   load markng/FRModel.mat; FRModelLBP = FRModel; eval(['disthdLBP=' disthdstr]);
%   load dreamway/FRModel.mat; FRModelLDA = FRModel; eval(['disthdLDA=' disthdstr]);
%   load sitrke/FRModel.mat; FRModelFTC = FRModel; eval(['disthdFTC=' disthdstr]);
%   [enacc, enpid, enallid] = FREnsemble({FRModelLDA, FRModelLBP, FRModelFTC}, {disthdLDA, disthdLBP, disthdFTC}, [plist.name;ilist.name], [plist.id(:, 1);plist.id(:, 1)], glist.id(:, 1), 250);
%   

if nargin < 6
    FTCthres = 250;
end

% FRModels
FRModelLDA  = IdentModels{1, 1};
FRModelLBP  = IdentModels{1, 2};
FRModelFTC  = IdentModels{1, 3};

% disthds
disthdLDA   = Disthds{1, 1};
disthdLBP   = Disthds{1, 2};
disthdFTC   = Disthds{1, 3};


% preallocated
predictids  = zeros(length(testname), 1);
allids	    = zeros(length(testname), 3);
acc	    = [];
nowids	    = zeros(1, 3);
% nowdecs	    = zeros(2, length(GalleryId));


% unique gallery id
ugid	    = unique(GalleryId);
n_ugid	    = length(ugid);
% ugidx	    = cell(1, n_ugid);


% for each test face
for i = 1 : length(testname)
    % find all id and dec
    [nowids(1), nowdecs(:, 1)] = disthdLDA(FRModelLDA, testname{i, 1});
    [nowids(2), nowdecs(:, 2)] = disthdLBP(FRModelLBP, testname{i, 1});
    [nowids(3), nowdecs(:, 3)] = disthdFTC(FRModelFTC, testname{i, 1});
    allids(i, 1) = nowids(1);
    allids(i, 2) = nowids(2);
    allids(i, 3) = nowids(3);
    % [nowids(3), nowdecs(:, 3)] = disthdFTC(FRModelFTC, testname{i, 1});

    % voting
    if length(unique(nowids)) ~= 3  % if there are at least two the same
	if length(find(nowids == nowids(3))) > 1    % if FTC is not alone, output it
	    predictids(i) = nowids(3);
	else
	    if min(nowdecs((find(GalleryId == nowids(3))), 3)) < FTCthres	% if FTC distance is near enough, drop it
		predictids(i) = -1;
	    else
		predictids(i) = nowids(1);
	    end
	end
    else % all different, drop it
	predictids(i) = -1;
    end

    % working message
    if rem(i, 100) == 0
        fprintf('.')
    end
end

% find accuracy
acc = sum(predictids == testid) / length(testid);

