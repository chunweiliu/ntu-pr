
function [ParamsEvaluate] = FRtuneFTC(MultiClusterParams, SVMParams, FTCParams, filename)

%

if nargin < 4
    filename = 'tuneparams_temp.mat';
end

if exist(filename, 'file') > 0
    fprintf('%s alerady exists.\n', filename);
    return;
end

for i = 1 : length(MultiClusterParams)
    tic
    ParamsEvaluate(i) = FREvaluateFTC(MultiClusterParams(i), SVMParams, FTCParams);
    eval(['save -mat ' filename ' ParamsEvaluate']);
    toc
end

