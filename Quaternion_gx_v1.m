function [g] = Quaternion_gx_v1(q,v,P)
%
% From The Dynamic function dq/dt = f(q,v,P) to be integrated over time
% dqdt  = [www ww ss]; 
%  return the amplitude of the state i.e q(2)
%
%
%  R Moran 16/07/18
 
g = q(2);
 
 