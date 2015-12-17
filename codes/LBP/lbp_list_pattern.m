function patterns = lbp_list_pattern

patterns = [];
%k = 0;
for i = 0:255
	vector = dec2bin(i,8);
	if is_uniform(vector) <= 2
		%disp(vector);
		%vector = ['a' vector 'a'];
		patterns = [patterns vector' ];
		%k = k + 1;
	end
end

patterns = reshape( patterns, 1, []);
%disp(k);
