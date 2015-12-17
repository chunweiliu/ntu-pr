function hist = lbp_hist(pixels, p)

% pixels : p * n;
% p : scalar

hist = zeros(p+2,1);

n = size(pixels, 2);
for i = 1 : n
	%disp(sprintf('count = %d', is_uniform(pixels(:,i))));
	if (is_uniform(pixels(:,i)) <= 2 )
		count_one = sum(pixels(:,i)) + 1;
		%disp(sprintf('count_one = %d', count_one));
		hist(count_one) = hist(count_one) + 1;
	else
		hist(p+2) = hist(p+2) + 1;
	end
end


