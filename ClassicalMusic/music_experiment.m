%%
% music_experiment.m
%

L = 100;
T = 1000;
xi = 50;
sink_iter = 20;
tol = 1e-5;

% Construct song list
cd 'C:\Users\oconn\Dropbox\Research\OTC_Experiments\ClassicalMusic\FittedModels\LHMM';
file_list = dir;
file_list = {file_list.name}';
song_list = [];
for i=1:length(file_list)
    file = file_list{i};
    if contains(file, '.csv')
        temp_arr = strsplit(file, ["notes.csv", "phi0.csv", "phi1.csv", "phi2.csv", "pi.csv", "time.csv", "tmat.csv", "z.csv"]);
        song = temp_arr(1);
        song_list = [song_list; song];
    end
end
song_list = unique(song_list);

composer_list = [];
key_list = [];
for i=1:length(song_list)
    song = song_list{i};
    song_arr = strsplit(song, "-");
    composer_list = [composer_list; song_arr(1)];
    key_list = [key_list; song_arr(end)];    
end

n_songs = length(song_list);
exp_costs = cell(n_songs*(n_songs - 1)/2, 4);
song_iter = 0;

for song1_idx=1:length(song_list)
    for song2_idx=(song1_idx+1):length(song_list)
%for song1_idx=1:5
%    for song2_idx=(song1_idx+1):5

        song_iter = song_iter + 1;
        
        cd 'C:\Users\oconn\Dropbox\Research\OTC_Experiments\ClassicalMusic\FittedModels\LHMM';
        
        % Read data     
        song1_str = song_list{song1_idx};
        notes1 = readmatrix(strcat(song1_str, 'notes.csv'));
        phi1_0 = readmatrix(strcat(song1_str, 'phi0.csv'));
        phi1_1 = readmatrix(strcat(song1_str, 'phi1.csv'));        
        phi1_2 = readmatrix(strcat(song1_str, 'phi2.csv'));
        pi1 = readmatrix(strcat(song1_str, 'pi.csv'));
        tmat1 = readmatrix(strcat(song1_str, 'tmat.csv'));

        song2_str = song_list{song2_idx};
        notes2 = readmatrix(strcat(song2_str, 'notes.csv'));
        phi2_0 = readmatrix(strcat(song2_str, 'phi0.csv'));
        phi2_1 = readmatrix(strcat(song2_str, 'phi1.csv'));
        phi2_2 = readmatrix(strcat(song2_str, 'phi2.csv'));
        pi2 = readmatrix(strcat(song2_str, 'pi.csv'));
        tmat2 = readmatrix(strcat(song2_str, 'tmat.csv'));
        
        rng(315);
        n_hidden_states = size(tmat1);
        n_hidden_states = n_hidden_states(1);
        n_notes1 = length(unique(notes1));
        n_notes2 = length(unique(notes2));

        cd 'C:\Users\oconn\Dropbox\Research\OTC_Experiments\ClassicalMusic';
        
        disp(song1_str);
        disp(song2_str);
        
        %% Construct cost matrix from emission probabilities
        % Start by constructing cost for every pair of notes
        c_notes = zeros(n_notes1, n_notes2);
        alphabet1 = sort(unique(notes1));
        alphabet2 = sort(unique(notes2));
        for idx1=1:n_notes1
            for idx2=1:n_notes2
                note1 = alphabet1(idx1);
                note2 = alphabet2(idx2);
                
                if mod(note1, 12) == mod(note2, 12) % octave and unison
                    c_notes(idx1, idx2) = 0;
                elseif any(mod(abs(note1 - note2), 12) == [5 7]) % perfect consonance
                    %c_notes(idx1, idx2) = 0;
                    c_notes(idx1, idx2) = 1;
                elseif any(mod(abs(note1 - note2), 12) == [4 9]) % imperfect consonance
                    %c_notes(idx1, idx2) = 0;
                    c_notes(idx1, idx2) = 2;
                else
                    %c_notes(idx1, idx2) = 1;
                    c_notes(idx1, idx2) = 10;
                end
            end
        end

        % Cost at emission layer
        c1 = zeros(n_hidden_states);
        emissions1 = zeros(n_hidden_states*n_hidden_states, n_notes1*n_notes2);
        for idx1=1:n_hidden_states
            for idx2=1:n_hidden_states
                dist1 = phi1_0(idx1,:);
                dist2 = phi2_0(idx2,:);
                [sol, val] = computeot_lp(c_notes', dist1', dist2);
                c1(idx1, idx2) = val;
                emissions1(n_hidden_states*(idx1-1)+idx2, :) = reshape(sol', [], n_notes1*n_notes2);
            end
        end
        % Cost at first hidden layer
        c2 = zeros(n_hidden_states);
        emissions2 = zeros(n_hidden_states*n_hidden_states, n_hidden_states*n_hidden_states);
        for idx1=1:n_hidden_states
            for idx2=1:n_hidden_states
                dist1 = phi1_1(idx1,:);
                dist2 = phi2_1(idx2,:);
                [sol, val] = computeot_lp(c1', dist1', dist2);
                c2(idx1, idx2) = val;
                emissions2(n_hidden_states*(idx1-1)+idx2, :) = reshape(sol', [], n_hidden_states*n_hidden_states);
            end
        end
        % Cost at bottom hidden layer
        c = zeros(n_hidden_states);
        emissions3 = zeros(n_hidden_states*n_hidden_states, n_hidden_states*n_hidden_states);
        for idx1=1:n_hidden_states
            for idx2=1:n_hidden_states
                dist1 = phi1_2(idx1,:);
                dist2 = phi2_2(idx2,:);
                [sol, val] = computeot_lp(c2', dist1', dist2);
                c(idx1, idx2) = val;
                emissions3(n_hidden_states*(idx1-1)+idx2, :) = reshape(sol', [], n_hidden_states*n_hidden_states);
            end
        end
        
        c_unnorm = c;
        if sum(c) ~= 0
           c = c ./ sum(sum(c));
        end
        emissions1 = emissions1 ./ sum(emissions1, 2);
        emissions2 = emissions2 ./ sum(emissions2, 2);
        emissions3 = emissions3 ./ sum(emissions3, 2);

        %% Compute optimal transition couplings
        % Compute optimal transition coupling via ExactOTC
        optcoup_exactotc = exact_otc(tmat1, tmat2, c, 0);

        % Compute optimal transition coupling via FastEntropicOTC
        optcoup_approxotc = approx_otc(tmat1, tmat2, c, L, T, xi, sink_iter, 0); 

        %% Compute expected costs
        c_vec = reshape(c_unnorm', n_hidden_states*n_hidden_states, []);
        cost_exactotc = dot(get_stat_dist(optcoup_exactotc), c_vec);
        cost_approxotc = dot(get_stat_dist(optcoup_approxotc), c_vec);
        exp_costs(song_iter,:) = {cost_exactotc cost_approxotc};
        
        %% Draw samples from each optimal transition coupling
        n_samples = 100;
        % Draw random samples
        seq_exactotc = sample_layered_hmm(n_samples, optcoup_exactotc, emissions1, emissions2, emissions3);
        seq_approxotc = sample_layered_hmm(n_samples, optcoup_approxotc, emissions1, emissions2, emissions3);

        % Translate samples to pairs of notes
        notes_exactotc = zeros(n_samples, 2);
        for note_idx=1:n_samples
            for idx1=1:n_notes1
                for idx2=1:n_notes2
                    if seq_exactotc(note_idx)==n_notes2*(idx1-1)+idx2
                        notes_exactotc(note_idx,:) = [alphabet1(idx1) alphabet2(idx2)];
                    end
                end
            end
        end

        notes_approxotc = zeros(n_samples, 2);
        for note_idx=1:n_samples
            for idx1=1:n_notes1
                for idx2=1:n_notes2
                    if seq_approxotc(note_idx)==n_notes2*(idx1-1)+idx2
                        notes_approxotc(note_idx,:) = [alphabet1(idx1) alphabet2(idx2)];
                    end
                end
            end
        end


        %% Convert notes to midi file
        file_path = 'C:\Users\oconn\Dropbox\Research\OTC_Experiments\ClassicalMusic\GeneratedPieces';
        
        file_name = strcat(song1_str, song2_str, 'exact_otc');
        notes_to_midi(notes_exactotc, file_path, file_name);

        file_name = strcat(song1_str, song2_str, 'approx_otc');
        notes_to_midi(notes_approxotc, file_path, file_name);
    end   
end

% Save expected costs
exp_costs_table = cell2table(exp_costs);
exp_costs_table.Properties.VariableNames = {'exactotc_cost' 'approxotc_cost'};
disp(exp_costs_table);
writetable(exp_costs_table,'expcosts.csv');

%% Clustering

% Make distance matrices
fullind_distances = zeros(n_songs);
ind_distances = zeros(n_songs);
exactotc_distances = zeros(n_songs);
approxotc_distances = zeros(n_songs);
greedyotc_distances = zeros(n_songs);
twoletterot_distances = zeros(n_songs);
for idx1=1:n_songs
    for idx2=1:n_songs
        song1 = song_list{idx1};
        song2 = song_list{idx2};
        if ~strcmp(song1, song2)
            col1 = table2array(exp_costs_table(:,1));
            col2 = table2array(exp_costs_table(:,2));
            row = find((strcmp(col1, song1) & strcmp(col2, song2)) | (strcmp(col1, song2) & strcmp(col2, song1)));
            fullind_distances(idx1, idx2) = table2array(exp_costs_table(row, 3));
            ind_distances(idx1, idx2) = table2array(exp_costs_table(row, 4));
            exactotc_distances(idx1, idx2) = table2array(exp_costs_table(row, 5));
            approxotc_distances(idx1, idx2) = table2array(exp_costs_table(row, 6));
            greedyotc_distances(idx1, idx2) = table2array(exp_costs_table(row, 7));
            twoletterot_distances(idx1, idx2) = table2array(exp_costs_table(row, 8));
        end
    end
end

% Save distance matrices
writecell(song_list, 'song_list.csv');
writecell(key_list, 'key_list.csv');
writecell(composer_list, 'composer_list.csv');
writematrix(exactotc_distances,'exactotc_distance_matrix.csv');
writematrix(approxotc_distances,'entropicotc_distance_matrix.csv');

