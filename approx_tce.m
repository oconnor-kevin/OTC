%%
% approx_tce.m
%
% Given a transition coupling P, cost vector c, and scalars L and T,
% performs approximate transition coupling evaluation. Returns gain and 
% bias vectors g and h.

function [g, h] = approx_tce(P, c, L, T)
d = size(P, 1);
c = reshape(c', d, []);
c_max = max(max(c));
g_old = c;
g = P*g_old;
l = 1;
tol = 1e-12;
while l <= L && max(abs(g - g_old)) > tol*c_max
    g_old = g;
    g = P*g_old;
    l = l+1;
end

g = mean(g)*ones(d,1);
diff = c - g;
h = diff;
t = 1;
while t <= T && max(abs(P*diff)) > tol*c_max
    h = h + P*diff;
    diff = P*diff;
    t = t+1;
end
end