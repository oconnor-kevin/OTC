%%
% sample_layered_hmm.m
%
% Draws sample from layered hidden Markov model

function [seq] = sample_layered_hmm(n, tmat, phi0, phi1, phi2)
    hidden_seq1 = hmmgenerate(n, tmat, phi2);
    seq = zeros(n, 1);
    for i=1:n
       temp = find(mnrnd(1, phi1(hidden_seq1(i),:)));
       try
           seq(i) = find(mnrnd(1, phi0(temp,:)/sum(phi0(temp,:))));
       catch
           warning('Problem with sample_layered_hmm');
           [~, seq(i)] = max(phi0(temp,:));
       end
    end
end