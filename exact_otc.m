%%
% exact_otc.m
%
% Exact transition coupling iteration.

function [exp_cost, P, times] = exact_otc(Px, Py, c, time_iters)
dx = size(Px, 1);
dy = size(Py, 1);

P_old = zeros(dx*dy);
P = get_ind_tc(Px, Py);
times = [];
iter_ctr = 0;
while max(max(abs(P-P_old))) > 1e-10
    iter_ctr = iter_ctr + 1;
    P_old = P;
    fprintf('ExactOTC Iteration: %d\n', iter_ctr);
       
    if time_iters
        tic;
    end
    
    % Policy evaluation.
    [g, h] = exact_tce(P, c);
    exp_cost = min(g);
    disp(exp_cost);
    
    % Policy improvement.
    P = exact_tci(g, h, P_old, Px, Py);
    
    if time_iters
        times = [times, toc];
    end
    
    if all(all(P == P_old))
        return
    end
end
end