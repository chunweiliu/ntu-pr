
function [outstat] = loadmat(names)


%

for i = 1 : length(names);
    clear ParamsEvaluate;
    eval(['load ' names{1, i} ' ParamsEvaluate']);
    fprintf('.');
    if isvarname('ParamsEvaluate') == 1
	for j = 1 : length(ParamsEvaluate)
	    outstat(i, j, 1) = double(uint8(ParamsEvaluate(j).ClusterParams.method(1)));
	    outstat(i, j, 2) = ParamsEvaluate(j).ClusterParams.PCA_D;
	    outstat(i, j, 3) = ParamsEvaluate(j).ClusterParams.LDA_D;
	    outstat(i, j, 4) = ParamsEvaluate(j).neuacc;
	    outstat(i, j, 5) = ParamsEvaluate(j).poseacc;
	    outstat(i, j, 6) = ParamsEvaluate(j).illacc;
	    outstat(i, j, 7) = ParamsEvaluate(j).expacc;
	end
    end
end
fprintf('\n');
