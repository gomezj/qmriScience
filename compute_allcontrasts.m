function compute_allcontrasts(glm_scan)
% Usage:compute_allcontrasts(glm_scan)
%
% hI: view for GLM dataTYPE (output by applyGlm function)
% glm_scan: number of  scan within GLMs dataTYPES, use 2 for 'Localizer_GLM'
%
% This code is appropriate localizer scans with
% parfiles corresponding to the conditions listed below:
% 0 Fixation 
% 1 Faces Adults
% 2 Faces Child
% 3 Body
% 4 Limb 
% 5 Car
% 6 Guitar
% 7 Place
% 8 House
% 9 Word
% 10 Number
%%%%%%%%%%%%
% VSN 05/2014
hI = initHiddenInplane('GLMs');
hI = setCurScan(hI,glm_scan);
% ALL face contrasts
hI=computeContrastMap2(hI, [1 2], [3 4 5 6 7 8 9 10],'Faces_vs_allnonFace','test','T', 'mapUnits', 'T'); % contrast for all faces versus every non face category 
hI=computeContrastMap2(hI, [1] ,  [3 4 5 6 7 8 9 10],'FacesAdult_vs_allnonFace','test','T', 'mapUnits', 'T'); % contrast with adult faces versus every non face category
hI=computeContrastMap2(hI, [2] ,  [3 4 5 6 7 8 9 10],'FacesChild_vs_allnonFace','test','T', 'mapUnits', 'T'); % contrast with child faces versus every non face category

% All body contrasts
hI=computeContrastMap2(hI, [3 4], [1 2 5 6 7 8 9 10],'Body_vs_allnonBody','test','T', 'mapUnits', 'T'); % contrast with body parts and limbs versus everthing non-body
hI=computeContrastMap2(hI, [3],   [1 2 5 6 7 8 9 10],'Bodyparts_vs_allnonBody','test','T', 'mapUnits', 'T'); % contrast with body parts versus everthing non-body
hI=computeContrastMap2(hI, [4],   [1 2 5 6 7 8 9 10],'Limbs_vs_allnonBody','test','T', 'mapUnits', 'T'); % contrast with body parts versus everthing non-body

% All Scene contrasts
hI=computeContrastMap2(hI, [7 8], [1 2 3 4 5 6 9 10],'PlaceHouses_vs_allnonScenes','test','T', 'mapUnits', 'T'); % contrast with scenes versus everything non-scence
hI=computeContrastMap2(hI, [7],   [1 2 3 4 5 6 9 10],'Place_vs_allnonScenes','test','T', 'mapUnits', 'T'); % contrast with only places versus everything non-scene
hI=computeContrastMap2(hI, [8],   [1 2 3 4 5 6 9 10],'Houses_vs_allnonScenes','test','T', 'mapUnits', 'T'); % contrast with only houses versus everything non-scene

% All word/number constrasts
hI=computeContrastMap2(hI, [9 10], [1 2 3 4 5 6 7 8],'WordNumber_vs_allnonWord','test','T', 'mapUnits', 'T'); % contrast with word & number versus everything non-word/number
hI=computeContrastMap2(hI, [9],    [1 2 3 4 5 6 7 8] ,'Word_vs_allnonWord','test','T', 'mapUnits', 'T'); % contrast with word versus everything else non word/number
hI=computeContrastMap2(hI, [10],   [1 2 3 4 5 6 7 8] ,'Number_vs_allnonNumber','test','T', 'mapUnits', 'T'); % contrast with number versus everything non word/number


% face versus place
hI=computeContrastMap2(hI, [1 2],   [7 8] ,'Face_vs_Place','test','T', 'mapUnits', 'T'); % contrast with face vesus place 

hI=computeContrastMap2(hI, [1 2 3 4],   [5 6 7 8 9 10] ,'Animate_vs_Inanimate','test','T', 'mapUnits', 'T'); % contrast with animate versus inanimae

