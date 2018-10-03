function [dqdt] = Quaternion_fx_v1(q,v,P)
%
% The Dynamic function dq/dt = f(q,v,P) to be integrated over time
%
%  q is the state vector of length 8:
%
%  States 1-8:
%  for each quaternion state represent it's dynamic change i.e
%  its velocity and acceleration 
%
%  if x is a state then xx is its velocity and xxx its acceleration
%
%  s: - slowly changing variable - i.e. the movement can change - the input
%  to the du=ynamic system
%
%  as per
%  Pastor et al 'Learning from Generalization'
%
%  Learn parameters, P.K ,  P.D , P.tau , P.alpha.... per state 
%  Learn Parameters of canonical function P.w, P.h, P.c per state
%  initialization parameters P.x0, P.g
%
%
%  then the observer model just reports w, x, y and z
%
%  for the moment I am leaning just one quaterion (i.e. a three state model) - fill in rest as same
%
%  R Moran 16/07/18

ww = q(1);
w  = q(2);
s  = q(3)+v;

% add later the other states in quaternion
% xx = q(3);
% x  = q(4);
% yy = q(5);
% y  = q(6);
% zz = q(7);
% z  = q(8);
 


% www  =   (P.K*(P.g - w) - P.D*ww - P.K*(P.g - P.x0)*s + P.K*f_canonical(s,P))/P.tau;  % dynamic parameters to be learned
% ww   =   www/P.tau;
% ss   =   (-P.alpha*s)/P.tau;

www  =   (P.K*(w) - P.D*ww - P.K*(P.x0) + P.K*f_canonical(s,P))/P.tau;  % dynamic parameters to be learned
ww   =   www/P.tau;
ss   =   (-P.alpha*s)/P.tau;

dqdt  = [www ww ss]; % return the temporal derivative

% expand later
% xx   = xxx/tau;
% xxx  = (Kx*(g - x) - Dx*xx - Kx*(g - x0)*s + Kx*f_canonical(s,P))/tau; 
% yy   = yyy/tau;
% yyy  =
% zz   = zzz/tau;
% zzz  =


function f = f_canonical(s,P)
% parameters of nonlinear function - sum over gaussians
%
% P.w, P.h, P.c

% use two weights and two gaussians
psi(1) =  exp(-P.h(1)*((s-P.c(1))^2));
psi(2) =  exp(-P.h(2)*((s-P.c(2))^2));

% use two weights and two gaussians
f  = sum((P.w.*psi).*s) + sum(psi);

return  




 