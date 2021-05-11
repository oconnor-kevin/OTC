%%
% entropic_otc.m
%
% Run approximate transition coupling iteration to get the optimal 
% transition coupling.

function [P, times] = entropic_otc(Px, Py, c, L, T, xi, sink_iter, time_iters)
dx = size(Px, 1);
dy = size(Py, 1);

g_old = max(max(c))*ones(dx*dy, 1);
g = g_old-1e-10;
P = get_ind_tc(Px, Py);
times = [];
iter_ctr = 0;
while mean(g) < mean(g_old)
    iter_ctr = iter_ctr + 1;
    fprintf('EntropicOTC Iteration: %d\n', iter_ctr);
    P_old = P;
    g_old = g;
    
    if time_iters
        tic;
    end
    
    % Approximate transition coupling evaluation.
    [g, h] = approx_tce(P, c, L, T);
    disp(min(g));
    
    % Entropic transition coupling improvement.
    P = entropic_tci(h, P_old, Px, Py, xi, sink_iter);
    
    if time_iters
        times = [times, toc];
    end
end
end