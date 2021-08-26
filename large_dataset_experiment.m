%%
% large_dataset_experiment.m
%
% Run time experiment testing limits of entropic_otc for chains with large
%  state spaces.

% Algorithm parameters.
L = 50;
T = 100;
xi = 75;
sink_iter = 50;

% Run experiments.
n_iters = 2;
%dim_range = [1e2, 1e3, 1e4, 1e5];
dim_range = [1e2];
tau = 0.1;
entropic_times = zeros(dim_range, n_iters);
entropic_costs = zeros(dim_range, n_iters);

for dim_iter=1:size(dim_range)
    for iter=1:n_iters
        % Set dimension.
        d = dim_range(dim_iter);

        % Simulate marginals and cost.
        c = abs(normrnd(0, 1, d, d));
        c = c ./ max(max(c));
        
        Px = normrnd(0, 1, d, d);
        Px = exp(tau*Px)./sum(exp(tau*Px),2);
        Py = normrnd(0, 1, d, d);
        Py = exp(tau*Py)./sum(exp(tau*Py),2);

        % Run entropic_otc.
        [entropic_sol, iter_times_entropic] = entropic_otc(Px, Py, c, L, T, xi, sink_iter, 1);
        
        % Save times.
        entropic_times(dim_iter, iter) = sum(iter_times_entropic);

        % Print data.
        disp('d');
        disp(d);
        disp('EntropicOTC');
        disp(iter_times_entropic);
        disp(sum(iter_times_entropic));
    end
end

experiment_id = datetime('now');
experiment_id.Format = 'yyyy_MM_dd_HH_mm_ss';
experiment_id = string(experiment_id);
experiment_id = append(experiment_id, '_xi', string(xi), '_sinkiter', string(sink_iter));
entropic_times_file_name = append('runtime_exp_', experiment_id, '_entropic_times.csv');

csvwrite(entropic_times_file_name, entropic_times);
