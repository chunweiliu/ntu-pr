function accuracy = pca_accur(FRModel, disthd, testlist)

[best_id, all_decvalue] = FRTest(FRModel, disthd, testlist.name(:,1));

% check the precision
result = 0;
for i = 1 : length(best_id)
	if (best_id(i) == testlist.id(i,1))
		result = result + 1;
	end
end

accuracy =  result/length(best_id);
