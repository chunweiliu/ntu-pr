function [S, W, M, U, D, ids] = pca(images, regs, k)
% S : n * m scatter matrix
% W : k * m projected features;
% M : n * 1 mean
% U : k * k eigenvector
% D : k * k eigenvalue (only diag)

tic;
disp('PCA...');

[n, m] =size(images);

M = mean(images,2);

S = zeros(n, m);


disp(sprintf('# of Image: %d', m));
disp(sprintf('Dimension of Image: %d', n));
disp(sprintf('Size of S: (%d X %d)', n, m));

% scatter matrix;
for i=1:m
    S(:,i) = images(:,i) - M;
end

C = S' * S;

[V, D] = eigs(C,k);

U = S * V;

for i=1:k
    s = norm(U(:,i));
	U(:,i) = U(:,i) ./ s;
end

% registration
[n , m] = size( regs );
M = mean(regs, 2);

S = zeros(n, m);
for i=1:m
    S(:,i) = regs(:,i) - M;
end


W = zeros(k, m);

for i=1:m
    for j=1:k
        W(j,i) = U(:,j)' * S(:,i);
    end
end

t = toc;
disp(sprintf('Used: %f s', t));
