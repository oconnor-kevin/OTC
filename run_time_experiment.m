%%
% run_time_experiment.m
%
% Run time experiment comparing exact_otc and entropic_otc.

rng(315);

% Algorithm parameters
L = 100;
T = 1000;
xi_vec = [75 100 200];
sink_iter_vec = [50 100 200];

% Experiment parameters
n_iters = 5;
d_vec = [10 20 30 40 50 60 70 80 90 100];
tau = 0.1;
results = cell2table(cell(0,9), 'VariableNames', {'d', 'Algorithm', 'Xi', 'Tau', 'L', 'T', 'Sink_Iter', 'Cost', 'Runtime'});;

for d=d_vec
    for iter=1:n_iters
        disp(['d: ', num2str(d)]);
        disp(['iter: ', num2str(iter)]);
        
        % Simulate marginals and cost.
        c = abs(normrnd(0, 1, d, d));
        c = c ./ max(max(c));
        
        Px = normrnd(0, 1, d, d);
        Px = exp(tau*Px)./sum(exp(tau*Px),2);
        Py = normrnd(0, 1, d, d);
        Py = exp(tau*Py)./sum(exp(tau*Py),2);

        %% Run ExactOTC
        [exact_sol, times_exact_vec] = exact_otc(Px, Py, c, 1);

        % Save runtime
        time_exact = sum(times_exact_vec);

        % Save cost
        [cost_exact_vec, ~] = exact_tce(exact_sol, c);
        cost_exact = min(cost_exact_vec);

        disp('ExactOTC');
        disp('Runtimes: ');
        disp(times_exact_vec);
        disp(['Total Runtime: ', num2str(time_exact)]);
        disp(['Cost: ', num2str(cost_exact)]);

        % Append to results table
        results = [results;{d, 'ExactOTC', 'Inf', tau, L, T, 0, cost_exact, time_exact}];

        %% Run EntropicOTC
        for idx=1:length(xi_vec)
            xi = xi_vec(idx);
            sink_iter = sink_iter_vec(idx);
            [entropic_sol, times_entropic_vec] = entropic_otc(Px, Py, c, L, T, xi, sink_iter, 1);

            % Save runtime
            time_entropic = sum(times_entropic_vec);

            % Save cost
            [cost_entropic_vec, ~] = exact_tce(entropic_sol, c);
            cost_entropic = min(cost_entropic_vec);

            disp('EntropicOTC');
            disp(['Xi: ', num2str(xi)]);
            disp('Runtimes: ');
            disp(times_entropic_vec);
            disp(['Total Runtime: ', num2str(time_entropic)]);
            disp(['Cost: ', num2str(cost_entropic)]);

            % Append to results table
            results = [results;{d, 'EntropicOTC', num2str(xi), tau, L, T, sink_iter, cost_entropic, time_entropic}];            
        end
    end
end

% Save results
experiment_id = datetime('now');
experiment_id.Format = 'yyyy_MM_dd_HH_mm_ss';
experiment_id = string(experiment_id);
file_name = append('runtime_exp_', experiment_id, '_results.csv');
writetable(results, file_name);

% Display results
disp(['Experiment ID: ', num2str(experiment_id)]);
disp(results);
