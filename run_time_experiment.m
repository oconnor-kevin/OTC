%%
% run_time_experiment.m
%
% Run time experiment comparing exact_otc and entropic_otc.

% xi=75, sink_iter=50
% xi=100, sink_iter=100
% xi=200, sink_iter=200

% Algorithm parameters.
L = 100;
T = 1000;
xi = 75;
sink_iter = 50;
tol = 0.001;

% Run experiments.
n_iters = 5;
dim_range = 10;
tau = 0.1;
exact_times = zeros(dim_range, n_iters);
exact_costs = zeros(dim_range, n_iters);
entropic_times = zeros(dim_range, n_iters);
entropic_costs = zeros(dim_range, n_iters);
run_exact = 1;
run_entropic = 1;

for dim_iter=1:dim_range
    for iter=1:n_iters
        % Set dimension.
        d = 10*dim_iter;

        % Simulate marginals and cost.
        c = abs(normrnd(0, 1, d, d));
        c = c ./ max(max(c));
        
        Px = normrnd(0, 1, d, d);
        Px = exp(tau*Px)./sum(exp(tau*Px),2);
        Py = normrnd(0, 1, d, d);
        Py = exp(tau*Py)./sum(exp(tau*Py),2);

        % Run algorithms.
        if run_exact
            [exact_sol, iter_times_exact] = exact_otc(Px, Py, c, 1);
        end
        if run_entropic
            [entropic_sol, iter_times_entropic] = entropic_otc(Px, Py, c, L, T, xi, sink_iter, 1);
        end
        
        % Save times.
        if run_exact
            exact_times(dim_iter, iter) = sum(iter_times_exact);
        end
        if run_entropic
            entropic_times(dim_iter, iter) = sum(iter_times_entropic);
        end

        % Save expected cost.
        if run_exact
            iter_costs_exact = exact_sol^100*reshape(c', d^2, []);
            exact_costs(dim_iter, iter) = min(iter_costs_exact);
        end
        if run_entropic
            iter_costs_entropic = entropic_sol^100*reshape(c', d^2, []);
            entropic_costs(dim_iter, iter) = iter_costs_entropic(1);
        end

        % Print data.
        disp('d');
        disp(d);
        if run_exact
            disp('ExactOTC');
            disp(iter_times_exact);
            disp(sum(iter_times_exact));
            disp(min(iter_costs_exact));
        end
        if run_entropic
            disp('EntropicOTC');
            disp(iter_times_entropic);
            disp(sum(iter_times_entropic));
            disp(iter_costs_entropic(1));
        end
    end
end

experiment_id = datetime('now');
experiment_id.Format = 'yyyy_MM_dd_HH_mm_ss';
experiment_id = string(experiment_id);
experiment_id = append(experiment_id, '_xi', string(xi), '_sinkiter', string(sink_iter), '_tol', string(tol));
exact_costs_file_name = append('runtime_exp_', experiment_id, '_exact_costs.csv');
entropic_costs_file_name = append('runtime_exp_', experiment_id, '_entropic_costs.csv');
exact_times_file_name = append('runtime_exp_', experiment_id, '_exact_times.csv');
entropic_times_file_name = append('runtime_exp_', experiment_id, '_entropic_times.csv');

if run_exact
    csvwrite(exact_costs_file_name, exact_costs);
    csvwrite(exact_times_file_name, exact_times);
end
if run_entropic
    csvwrite(entropic_costs_file_name, entropic_costs);    
    csvwrite(entropic_times_file_name, entropic_times);
end
    




