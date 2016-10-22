 function [] = glmWrapper(subj, dtName,scanNum, GLMscan)
% glmWrapper(subj,dtName, scanNum, GLMscan)
% subj={'vaidehi', 'jesse'};
% dtName = the default is 'MotionComp_RefScan1', but you can change it
% scanNum =[1 3]; % this is a vector where each number corresponds to the
% number of the first scan in the group. Example: for the first subject, if
% you want to run GLM on grouped scans 1 2 and 3, just enter 1. For the
% next subject, if you want to the GLM on grouped scan 4 5 and 6, you enter
% 4, so you scanNum vector would be [1 4] for these two subjects. 
% which you are going to run the glm on
% Wrapper script for computing the GLMS and Contrasts from localizer.
% GLMscan = for GLM [1]
% vn, jg, 03/2015
  

 display('Did you GROUP SCANS???');
 fmriDir = '.../Localizer/data/';
 codeDir = '.../Localizer/code/GLM';
 addpath(codeDir);

%%%%%% RUN GLM for the LOCALIZER RUNS %%%%%%%%%%%%%%%%%%%%%%55
%% data type:
% these should be input variables
if notDefined('dtName')
    dtName = 'MotionComp_RefScan1';
end
dtName
% set glmName 
if notDefined('scanNum'), fprintf('Please define the scan for subjects'); return; end
if notDefined('gray'), gray=0; end %gray=[1]; % If you would like to initialize hiddenGray, set gray to 1. Else it will initHiddenInplane


%% this is the same for all subjects in the kidsloc study %%%
glmName = 'Localizer_GLM';
eventsPerBlock=4;

%%%% main loop
for s = 1:length(subj)
    cd( fullfile(fmriDir, subj{s}));
    fprintf('*** Session %s *** \n', subj{s});
    computeGLM(subj{s}, scanNum(s), dtName, glmName, gray ,eventsPerBlock); 
    compute_allcontrasts(GLMscan); %Contrasts are used to define category-selective regions

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
