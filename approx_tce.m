%%
% approx_tce.m
%
% Given a transition coupling P, cost vector c, and scalars L and T,
% performs approximate transition coupling evaluation. Returns gain and 
% bias vectors g and h.

function [g, h] = approx_tce(P, c, L, T)
d = size(P, 1);
c = reshape(c', d, []);
g = c;

for l=1:L
    g = P*g;
end

g = mean(g)*ones(d,1);
diff = c - g;
h = diff;
for t=1:T
    h = h + P*diff;
    diff = P*diff;
end
end