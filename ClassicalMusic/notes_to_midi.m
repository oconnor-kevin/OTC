%%
% notes_to_midi.m
%
% Take a sequence of piano keys and save a midi file containing those keys.

function notes_to_midi(notes, file_path, file_name)
    n_notes = length(notes);
    fid = fopen(strcat(file_path, file_name, '.csv'), 'w');
    dur = 228;
    
    % Write header.
    fprintf(fid, '%d,%d,%s,%d,%d,%d\n', 0, 0, 'Header', 1, 3, 192);
    fprintf(fid, '%d,%d,%s\n', 1, 0, 'Start_track');
    fprintf(fid, '%d,%d,%s,%d,%d,%d,%d\n', 1, 0, 'Time_signature', 4, 2, 24, 8);
    fprintf(fid, '%d,%d,%s,%d\n', 1, 0, 'Tempo', 500000);    
    fprintf(fid, '%d,%d,%s\n', 1, (n_notes+5)*dur, 'End_track');
    
    % Write first track.
    fprintf(fid, '%d,%d,%s\n', 2, 0, 'Start_track');    
    for i = 1:n_notes
        fprintf(fid, '%d,%d,%s,%d,%d,%d\n', 2, dur*i, 'Note_on_c', 1, notes(i,1), 100);
        fprintf(fid, '%d,%d,%s,%d,%d,%d\n', 2, dur*(i+1), 'Note_off_c', 1, notes(i,1), 0);
    end
    fprintf(fid, '%d,%d,%s\n', 2, (n_notes+5)*dur, 'End_track');    
 
    % Write second track.
    fprintf(fid, '%d,%d,%s\n', 3, 0, 'Start_track');    
    for i = 1:n_notes
        fprintf(fid, '%d,%d,%s,%d,%d,%d\n', 3, dur*i, 'Note_on_c', 1, notes(i,2), 100);
        fprintf(fid, '%d,%d,%s,%d,%d,%d\n', 3, dur*(i+1), 'Note_off_c', 1, notes(i,2), 0);
    end
    fprintf(fid, '%d,%d,%s\n', 3, (n_notes+5)*dur, 'End_track');    
    
    fprintf(fid, '%d,%d,%s\n', 0, 0, 'End_of_file');
    fclose(fid);
    
    % Convert CSV to MIDI
    system(strcat('ClassicalMusic\csvmidi.exe', {' '}, strcat(file_path, file_name, '.csv'), {' '}, strcat(file_path, file_name, '.mid')));
end