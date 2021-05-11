%%
% entropic_tci.m
%
% Given bias and gain vectors g and h, uses entropic OT to find an
% approximately improved transition coupling.

function P = entropic_tci(h, P0, Px, Py, xi, sink_iter)
dx = size(Px, 1);
dy = size(Py, 1);
P = P0;

% Try to improve with respect to h.
h_mat = reshape(h, dy, dx)';
K = -xi*h_mat;
for i=1:dx
    for j=1:dy
        % Run Sinkhorn on each pair of rows, taking care to ignore zeros.
       dist_x = Px(i,:);
       dist_y = Py(j,:);
       x_idxs = find(dist_x);
       y_idxs = find(dist_y);
       if length(x_idxs)==1 || length(y_idxs)==1
           P(dy*(i-1)+j,:) = P0(dy*(i-1)+j,:);
       else
           sol = logsinkhorn(K(x_idxs, y_idxs), dist_x(x_idxs)', dist_y(y_idxs), sink_iter);
           sol_full = zeros(dx, dy);
           for idx1=1:length(x_idxs)
               for idx2=1:length(y_idxs)
                   sol_full(x_idxs(idx1), y_idxs(idx2)) = sol(idx1, idx2);
               end
           end
           P(dy*(i-1)+j,:) = reshape(sol_full', [], dx*dy);
       end
    end
end
if max(max(abs(P0*h-P*h))) < 1e-10
    P = P0;
end
end