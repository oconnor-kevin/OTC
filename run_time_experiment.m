%%
% run_time_experiment.m
%
% Run time experiment comparing exact_otc and approx_otc.


% d = 10, xi=10, sink_iter=10
% d = 20, xi=12, sink_iter=10
% d = 30, xi=14, sink_iter=10
% d = 40, xi=15, sink_iter=10
% d = 50, xi=15, sink_iter=10
% d = 60, xi=15, sink_iter=10
% d = 70, xi=15, sink_iter=10

% xi=200, sink_iter=200
% xi=100, sink_iter=100
% xi=75, sink_iter=50
% xi=50, sink_iter=25
% xi=1, sink_iter=10

% Algorithm parameters.
L = 100;
T = 1000;
xi = 50;
sink_iter = 25;
tol = 0.001;

% Run experiments.
n_iters = 5;
dim_range = 10;
tau = 0.1;
exact_times = zeros(dim_range, n_iters);
exact_costs = zeros(dim_range, n_iters);
approx_times = zeros(dim_range, n_iters);
approx_costs = zeros(dim_range, n_iters);
greedy_times = zeros(dim_range, n_iters);
greedy_costs = zeros(dim_range, n_iters);
run_exact = 1;
run_approx = 0;
run_greedy = 1;
sparse_cost = 1;
for dim_iter=1:dim_range
    for iter=1:n_iters
        % Set dimension.
        d = 10*dim_iter;

        % Simulate marginals and cost.
        c = abs(normrnd(0, 1, d, d));
        c = c ./ max(max(c));
        if sparse_cost
            c = exp(20*c)./max(max(exp(20*c)));            
        end
        
        Px = normrnd(0, 1, d, d);
        Px = exp(tau*Px)./sum(exp(tau*Px),2);
        Py = normrnd(0, 1, d, d);
        Py = exp(tau*Py)./sum(exp(tau*Py),2);

        % Run algorithms.
        if run_exact
            [exact_sol, iter_times_exact] = exact_otc(Px, Py, c, 1);
        end
        if run_approx
            [approx_sol, iter_times_approx] = approx_otc(Px, Py, c, L, T, xi, sink_iter, tol, 1);
        end
        if run_greedy
            [greedy_sol, iter_times_greedy] = greedy_otc(Px, Py, c, 1);
        end
        
        % Save times.
        if run_exact
            exact_times(dim_iter, iter) = sum(iter_times_exact);
        end
        if run_approx
            approx_times(dim_iter, iter) = sum(iter_times_approx);
        end
        if run_greedy
            greedy_times(dim_iter, iter) = sum(iter_times_greedy);
        end

        % Save expected cost.
        if run_exact
            iter_costs_exact = exact_sol^100*reshape(c', d^2, []);
            exact_costs(dim_iter, iter) = min(iter_costs_exact);
        end
        if run_approx
            iter_costs_approx = approx_sol^100*reshape(c', d^2, []);
            approx_costs(dim_iter, iter) = iter_costs_approx(1);
        end
        if run_greedy
            iter_costs_greedy = greedy_sol^100*reshape(c', d^2, []);
            greedy_costs(dim_iter, iter) = min(iter_costs_greedy);
        end


        % Print data.
        disp('d');
        disp(d);
        if run_exact
            disp('Exact');
            disp(iter_times_exact);
            disp(sum(iter_times_exact));
            disp(min(iter_costs_exact));
        end
        if run_approx
            disp('Approx');
            disp(iter_times_approx);
            disp(sum(iter_times_approx));
            disp(iter_costs_approx(1));
        end
        if run_greedy
            disp('Greedy');
            disp(iter_times_greedy);
            disp(min(iter_costs_greedy));
        end
    end
end

experiment_id = datetime('now');
experiment_id.Format = 'yyyy_MM_dd_HH_mm_ss';
experiment_id = string(experiment_id);
experiment_id = append(experiment_id, '_xi', string(xi), '_sinkiter', string(sink_iter), '_tol', string(tol));
exact_costs_file_name = append('runtime_exp_', experiment_id, '_exact_costs.csv');
approx_costs_file_name = append('runtime_exp_', experiment_id, '_approx_costs.csv');
greedy_costs_file_name = append('runtime_exp_', experiment_id, '_greedy_costs.csv');
exact_times_file_name = append('runtime_exp_', experiment_id, '_exact_times.csv');
approx_times_file_name = append('runtime_exp_', experiment_id, '_approx_times.csv');
greedy_times_file_name = append('runtime_exp_', experiment_id, '_greedy_times.csv');


if run_exact
    csvwrite(exact_costs_file_name, exact_costs);
    csvwrite(exact_times_file_name, exact_times);
end
if run_approx
    csvwrite(approx_costs_file_name, approx_costs);    
    csvwrite(approx_times_file_name, approx_times);
end
if run_greedy
    csvwrite(greedy_costs_file_name, greedy_costs);
    csvwrite(greedy_times_file_name, greedy_times);
end
    




