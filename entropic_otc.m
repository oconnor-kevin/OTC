%%
% entropic_otc.m
%
% Entropic transition coupling iteration.

function [exp_cost, P, times] = entropic_otc(Px, Py, c, L, T, xi, sink_iter, time_iters)
dx = size(Px, 1);
dy = size(Py, 1);
max_c = max(max(c));
tol = 1e-5*max_c;

g_old = max_c*ones(dx*dy, 1);
g = g_old-10*tol;
exp_cost = 0;
P = get_ind_tc(Px, Py);
times = [];
iter_ctr = 0;
while g_old(1) - g(1) > tol
    iter_ctr = iter_ctr + 1;
    fprintf('EntropicOTC Iteration: %d\n', iter_ctr);
    P_old = P;
    g_old = g;
    
    if time_iters
        tic;
    end
    
    % Approximate transition coupling evaluation.
    [g, h] = approx_tce(P, c, L, T);
    exp_cost = g(1);
    disp(exp_cost);
    
    % Entropic transition coupling improvement.
    P = entropic_tci(h, P_old, Px, Py, xi, sink_iter);
    
    if time_iters
        times = [times, toc];
    end
end
end