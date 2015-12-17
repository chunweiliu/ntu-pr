function [result,d] = lbp_recognition(image, ids, W, dims, threshold)

% image : w * h
% W : nHist * nImgs

%disp('Recognition...');

n = size(W, 2);
w = lbp(image,dims);
%size(w)
%size(W(:,1))

% min diff
for i=1:n
	upper = (w - W(:,i)).^2;
	bottom = w + W(:,i) + 1;

    diff = upper./bottom;
    d(i) = sum(diff);
end

[C, I] = min(d);

result = ids(I);

%disp(C);


