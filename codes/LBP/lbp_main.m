%images = trainingset;

trainlist = FRgetdata('database/training.txt', 'database');
gallerylist = FRgetdata('database/gallery.txt', 'database');

testlist = FRgetdata('database/probe_neutral.txt', 'database');

imposterlist = FRgetdata('database/imposter.txt', 'database');

%training
%[FRModel, disthd] = FRTrain_lbp(trainlist, gallerylist);
% test data
n_data = size(testlist.name, 1);

test_ids = [];
for i = 1 : n_data
	sid = testlist.id(i, 1);

	test_ids = [test_ids;sid];

end

facename_cell = [];
for i = 1 : n_data
	facename_cell{i,1} = testlist.name{i};
end

[best_id, all_decvalue] = FRTest(FRModel, disthd, facename_cell);

% check the precision
result = 0;
for i = 1 : length(best_id)
	if (best_id(i) == test_ids(i))
		result = result + 1;
	end
end

disp(sprintf('count = %d', result));
disp(sprintf('precision = %f', result/length(best_id)));

