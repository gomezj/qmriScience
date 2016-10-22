function computeGLM(sub, scanNum, dtName, glmName, gray, eventsPerBlock)
% function computeGLM(scan, dt)
% 
% ScanNum= number of the scan that you would like to compute the GLM on.
% Make sure that the scan group is correct.
%
% dtName= Name of the dataType containing the scan. 
%


if notDefined('scanNum'), fprintf('Please define the scan for %s', sub); return; end
if notDefined('dtName'), dtName='MotionComp_RefScan1'; end
if notDefined('gray'), gray=0; end

% Load the subject's mrSession file
% crash protection if the dataType specified does not exist
load mrSESSION.mat;
dts=strcmpi({dataTYPES.name},dtName);
 if sum(dts)==1
     dt=find(dts==1);
     fprintf('Found %s for dataTYPES %d\n',dtName, dt);
 else
     fprintf('Error: Found %d %s dataTYPES, skipping... \n\n',sum(dts),dtName);
     go=0;
     return
 end

% initialize a view of the 'inplane' data: format collected by scanner will
% also load the ROI coordinates
if gray==1
    hI=initHiddenGray(dt, scanNum);
    fprintf('Running GLM on the gray for %s', sub);
else
    hI = initHiddenInplane(dt, scanNum);
end
% get datatype and scangroup for this sessions
[scangrp dtcurr] = er_getScanGroup(hI);
% enforce consistent preprocessing / event-related parameters
params = er_getParams(hI);
params.eventAnalysis=1;
params.detrend = 1; % high-pass filter (remove the low frequency trend)
params.detrendFrames=20;
params.inhomoCorrection = 1; % divide by mean (transforms from raw scanner units to % signal)
params.temporalNormalization = 0; % no matching 1st temporal frame
params.annotation=glmName;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLM SPM HRF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.glmHRF = 3; % SPM hrf
params.eventsPerBlock = eventsPerBlock; 
%%%%%%%%%%%%%%%%%%%%%%%%%%% RUN GLM ON RAW DATA %%%%%%%%%%
params.lowPassFilter=0; % no temporal low pass filter of the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
er_setParams(hI, params, scanNum, dt);
% need to define odd runs scan group


tic; [newDt, newScan] = applyGlm(hI,dtcurr,scangrp, params); toc
