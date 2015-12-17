function [result,d] = recognition(image, ids, W, M, U, D, threshold)

image = reshape(image, [], 1);

k = size(U,2);
n = size(W, 2);

s = image - M;

w = zeros(k, 1);

for i=1:k
    w(i,1) = U(:,i)' * s;
end

for i=1:n
    diff = (w - W(:,i)).^2;
    d(i) = sum(diff);
end

[C, I] = min(d);

result = ids(I);

