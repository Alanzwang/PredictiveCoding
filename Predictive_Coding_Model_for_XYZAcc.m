% Free Energy based Hierarcical Model designed to learn and predict
% trajectories
%
% employing subfunctions from spm based on: DEM_coupled_oscillators
%
% https://www.fil.ion.ucl.ac.uk/spm/software/
%
% data from Zeiliang using x,y,z, coordinates of acceleration
%
% Rosalyn Moran 16/07/2018


% Load & Plot the Data
clear all; close all
% mypath = ['C:\Users\k1775598\OneDrive - King''','s College London\Predicting_the_Future_Cardiff\Data\'];
% 
% load([mypath,'wXYZ_Quaternion']) 
load quaternion_wxyz.mat;

lineStyles = linspecer(4,'qualitative');% forces the colors to all be distinguishable (up to 12)

% Downsample data
figure
hold on
Y(:,1) = decimate(Quaternion(:,1),20);
plot(Y(:,1),'Color',lineStyles(1,:),'LineWidth',2)

Y(:,2) = decimate(Quaternion(:,2),20);
plot(Y(:,2),'Color',lineStyles(2,:),'LineWidth',2)

Y(:,3) = decimate(Quaternion(:,3),20);
plot(Y(:,3),'Color',lineStyles(3,:),'LineWidth',2)

Y(:,4) = decimate(Quaternion(:,4),20);
plot(Y(:,4),'Color',lineStyles(4,:),'LineWidth',2)
legend('w','x','y','z')

%------------------- Learn trajectory of Y1 (in this example we will try to
%   learn the dynamics of the orange line)







%----------------- PART A   Specify Generative Model - a 2 level hierarchy
 
% specify states and parameters
%==========================================================================
N     = 300;                             % number of time points
dt    = 1/64;                            % sampling interval (sec) %dt is arbirtrary for now
 

 % Initial model states  for fx function.... dqdt  = [www ww ss];
 %--------------------------------------------------------------------------
 x     = zeros(3,1);                      % amplitude
 
% model parameters as per Pastor
%--------------------------------------------------------------------------
%  as per
%  Pastor et al 'Learning from Generalization'
% 
%  Learn parameters, P.K ,  P.D , P.tau , P.alpha.... per state 
%  Learn Parameters of canonical function P.w, P.h, P.c per state
%  initialization parameters P.x0, P.g
%  
%  start learning from these priors

P.K      =  1; % spring constant
P.D      =  1; % damping term
P.tau    =  10; % temporal scaling factor
P.alpha  =  1;
P.w      =  [1 2];
P.h      =  [1 2];
P.c      =  [1 2];
P.x0     =  0; %% start position
P.g      =  2; %% goal position 

% observation function (to generate timeseries)
%--------------------------------------------------------------------------
g = 'Quaternion_gx_v1';

% equations of motion (simplified coupled oscillator model)
%--------------------------------------------------------------------------
f = 'Quaternion_fx_v1';


% causes or exogenous input (a Gaussian function of peristimulus time)
%--------------------------------------------------------------------------
U = [1:-1/N:1/N] %descending input as per Pastor  % exogenous input at start of recording - like someone begins to move arm
T = (1:N)*dt;                            % sample times (seconds)
U = U/1000;
figure; plot(T,U)
title('forcing function')

% parameters for generalised filtering (see spm_LAP)
%--------------------------------------------------------------------------
E.n     = 4;                             % embedding dimension          
E.d     = 1;                             % data embedding 
E.nN    = 8;                             % number of iterations
E.s     = 1/2;                           % smoothness of fluctuations

% first level state space model
%--------------------------------------------------------------------------
M(1).E  = E;                             % filtering parameters
M(1).x  = x;                             % initial states 
M(1).f  = f;                             % equations of motion
M(1).g  = g;                             % observation mapping
M(1).pE = P;                             % model parameters
M(1).V  = exp(12);                       % precision of observation noise
M(1).W  = exp(16);                       % precision of state noise

% second level � causes or exogenous forcing term of body
%--------------------------------------------------------------------------
M(2).v  = 0;                             % initial causes
M(2).V  = exp(16);                       % precision of exogenous causes


% create data from model with known parameters (P)
%==========================================================================
DEM = spm_DEM_generate(M,U,P);
figure
plot(DEM.Y,'Color',lineStyles(1,:),'LineWidth',2) %% this is the data that the model 'holds' before seeing the real data
title('Data generated from model a priori')






% %----------------- PART B:  Invert the model based on Real recorded signal.....
% 
% % data and iniital 'bump' input - model first 100 time points
% %--------------------------------------------------------------------------
DATA_TO_MODEL = Y(1:100,1)';
DEM.Y         = DATA_TO_MODEL;
DEM.U         = U(1:100);

 

% place new observation function and priors in generative model - give
% the model a variable extiamtes of all parameters i.e. non zer variance
% matrix
% initialization of priors over parameters - as shown above
%--------------------------------------------------------------------------
pE       = P;                                % prior parameters
pC       = diag(length(spm_vec(P)));         % prior variance 
DEM.M(1).pE = pE;
DEM.M(1).pC = pC;
DEM.M(1).V  = exp([8 8]);   % precision of observation & input noise
DEM.M(1).W  = exp([  8]);   % precision of states
 
  
% Inversion using generalised filtering in spm_LAP
%==========================================================================
LAP   = spm_LAP(DEM);


predicted_data = LAP.qU.v{1};
figure
plot(predicted_data,'Color',lineStyles(1,:),'LineWidth',4) %% this is the data that the model 'holds' before seeing the real data
hold on
plot(DATA_TO_MODEL,'--','Color','k','LineWidth',4)
title('Data predicted from model a posteriori and actual data')
estimated_model_parameters = LAP.qP.P{1};





% % PART C      ------------------------------------------------------------- Checks & Plots
% % Check 1 : Check good estiamte is not due to noise
% % % check with these plots
% figure
% plot(LAP.qU.x{1}')
% title('estimated states')
% 
% figure
% plot(LAP.qU.v{2}')
% title('estimated input')
% 
% figure
% plot(LAP.qU.w{1}')
% title('estimated noise in states')
% 
% figure
% plot(LAP.qU.z{1}')
% title('estimated noise in observation')
% 
% figure
% plot(LAP.qU.z{2}')
% title('estimated noise in input')

 
 
% Check 2 : regenerate data based on new parameters
% Posterior_Parameters  = LAP.qP.P{1};
% U                     = LAP.qU.v{2};
% M(1).x                = LAP.qU.x{1}(:,end);
% DEM2 = spm_DEM_generate(M,U,Posterior_Parameters );
% figure
% plot(DEM2.Y,'Color',lineStyles(1,:),'LineWidth',2) %% this is the data that the model 'holds' before seeing the real data
% title('Data generated from model a posteriori II')
 


