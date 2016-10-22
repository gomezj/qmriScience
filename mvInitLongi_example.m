% mvInitLongi.m
%
% This code will do an independent selectivity analysis given an roi and 3
% runs of kid localizer that have been transformed to the volume (using
% ip2VolTseries in Longitudinal/FMRI/Localizer/code/indepAnalysis. It will
% dilate the given ROI (which we got from t>3 voxels using all 3 runs of
% kidLoc), and then within that dilated ROI, will take two runs, find the
% t>3 selective voxels within the dilated ROI, and then extract the new
% t-values from those voxels from the left-out-run (and will extract the
% qMRI values from these same voxels). Then it will calculate the mean
% selectivity from all combinations of left-out runs and the mean qMRI
% values (indexed with the left-out voxels) and save out a selectivity 
% value and a qMRI value for each subject.

% Which ROIS do you want to load and combine?
roiList = {'rh_pFus_Faces'}; % this can be a list that will get combined into one fROI

% What are your active and inactive conditions?
% 1,2=adult,child faces 3,4=body,limb
% 7,8=places,houses 9,10=word,number
active = [1 2];
inactive=[3 4 5 6 7 8 9 10];

% What do you want the output combined ROI to be called?
saveName = 'right_pfus_face';
saveFlag = false;

% Name of mat file that will contain final data vectors.
% Will be stored in FMRI/Localizer/results/indepAnalysis
fileName = 'right_pfus_face_example_allSubs';


% Example subjects 
subs     = {'JG24'};
sessions = {'JG24_01062014'};
ages     = [24];

% mriDir is where all subject folders are located:
mriDir = '...FMRI/Localizer/data';
cd(mriDir);
selectivity = zeros(1,length(subs));
T1vals    = zeros(1,length(subs));
MTVvals   = zeros(1,length(subs));
subjects = {};

tEdge = [0.5:0.05:2.3]; % This value splits both MTV and T1 into bin sizes that are 1/10th of their respective unit ranges (.1s or .01 tissue volume fraction)
vEdge = [0.05:0.01:0.4];


for i = 1:length(sessions)
    %% Initialize a hidden gray for motionComp_refscan1
    cd(fullfile(mriDir,sessions{i}))
    view = initHiddenGray(3,1);
    fprintf('\n\nProcessing %s\n\n',sessions{i})
    
    %% Combine and Dilate the fROI(s) of choice
    % If more than one roi to be combined, check if all exist for a subject
    checkVec = zeros(1,length(roiList));
    for r = 1:length(roiList)
        checkVec(r) = exist(fullfile(mriDir,sessions{i},'3DAnatomy','ROIs',[roiList{r} '.mat']),'file');
    end
    
    % If the subject has none of the ROIs, set vals to NaN and move to next sub
    if sum(checkVec) == 0
        selectivity(i) = NaN;
        T1vals(i) = NaN;
        MTVvals(i)= NaN;
        subjects{end+1} = subs{i};
        continue
    end
    
    % Now we will only consider those that exist for that subject
    roiListNew = roiList(find(checkVec));
    
    % Now load these ROIs into the hiddenGray
    for r = 1:length(roiListNew)
        view = loadROI(view,roiListNew{r});
    end
    
    % Need to combine the rois, which is done with indices of currently loaded rois, then we'll need
    % to save out that ROI (it becomes the selectedROI, or the last roi in vw.ROIs), so we can load and
    % dilate it after.
    rois = {}; % rois need to be stored in a cell
    for r=1:length(roiListNew)
        rois{r} = view.ROIs(r);
    end
    vw = view; clear view;
    [vw, roi, ~] = combineROIs(vw, rois, 'union', saveName);

    % Now let's dilate!
    color = 'g';
    radius = 4;% size of spherical convolution kernel
    scriptFlag = true; % This was necessary, otherwise roiDilate would change the vw struct and it couldn't find the selected ROI
    name = [saveName '_dilated' num2str(radius) 'mm'];
    [vw roiDil] = roiDilate(vw, roi, radius, name, color, scriptFlag);

    if saveFlag
    % Let's save dilated ROI for quality check and figures later on
    local = false; forceSave = true;
    [vw, status, forceSave] = saveROI(vw, roiDil, local, forceSave);
    end
    
    % % Now we will transform this dilated ROI into inplane space
    % hI = initHiddenInplane(3,1);
    % ipROI = vol2ipROI(roiDil,vw,hI);
    % [hI, status, forceSave] = saveROI(hI, ipROI, [1], forceSave);
    % hI = loadROI(hI,ipROI.name);
    %% Now we will initialize timecourseUI for each scan combination
    roiName = roiDil.name;
    mv12 = mv_init(vw,roiName,[1 2]); 
    mv13 = mv_init(vw,roiName,[1 3]);
    mv23 = mv_init(vw,roiName,[2 3]);
    % NOTE: in mv structure, the coords are different from the roi coords...
    
    % Set HRF to SPM difference of gammas and define events per block
    mv12.params.glmHRF = 3; mv12.params.eventsPerBlock = 4;
    mv13.params.glmHRF = 3; mv13.params.eventsPerBlock = 4;
    mv23.params.glmHRF = 3; mv23.params.eventsPerBlock = 4;
    
    % Now let's apply the glm to each mv structure
    mv12 = mv_applyGlm(mv12);  %mean(mean(mv12.glm.betas))
    mv13 = mv_applyGlm(mv13);
    mv23 = mv_applyGlm(mv23);
    
    % Now we compute a contrast
    [stat,ces,Tvals12,units] = glm_contrast(mv12.glm,active,inactive,'T');
    [stat,ces,Tvals13,units] = glm_contrast(mv13.glm,active,inactive,'T');
    [stat,ces,Tvals23,units] = glm_contrast(mv23.glm,active,inactive,'T');
    
    % Now we will initialize mv structures for the left out runs
    mv1 = mv_init(vw,roiName,[1]); mv1.params.glmHRF = 3; mv1.params.eventsPerBlock = 4;
    mv2 = mv_init(vw,roiName,[2]); mv2.params.glmHRF = 3; mv2.params.eventsPerBlock = 4;
    mv3 = mv_init(vw,roiName,[3]); mv3.params.glmHRF = 3; mv3.params.eventsPerBlock = 4;
    
    % And apply the GLM to the left out mv structures
    mv1 = mv_applyGlm(mv1);
    mv2 = mv_applyGlm(mv2);
    mv3 = mv_applyGlm(mv3);
    
    % Now compute the contrast on the left out mv structures
    [stat,ces,Tvals1,units] = glm_contrast(mv1.glm,active,inactive,'T');
    [stat,ces,Tvals2,units] = glm_contrast(mv2.glm,active,inactive,'T');
    [stat,ces,Tvals3,units] = glm_contrast(mv3.glm,active,inactive,'T');
    
    % From t>3 voxel in two runs, we will get selectivity from those same
    % voxels in the left out run.
    run1Indices = find(Tvals23 >= 3);
    run2Indices = find(Tvals13 >= 3);
    run3Indices = find(Tvals12 >= 3);
    run1MeanT = mean(Tvals1(run1Indices));
    run2MeanT = mean(Tvals2(run2Indices));
    run3MeanT = mean(Tvals3(run3Indices));
    
    % Store the mean selectivity of all 3 independent runs into our vector
    selectivity(i) = (run1MeanT + run2MeanT + run3MeanT)/3;
    subjects{end+1} = subs{i};
    
    % Now we need to take the indices of each independent run, transform those
    % indices into volume coordinates, transform them again into nifti
    % coordinates, and then index our qmri maps with them.
    % I noticed that mv.coords is not the same size as roi.coords, but is this
    % because mv.coords only contains those voxels restricted to gray?
    coords1 = mv1.coords(:,run1Indices); len1 = size(coords1, 2);
    coords2 = mv2.coords(:,run2Indices); len2 = size(coords2, 2);
    coords3 = mv3.coords(:,run3Indices); len3 = size(coords3, 2);
    
    roiColor = 1;
    
    roiData1 = zeros(viewGet(vw, 'anatomy size'));
    for ii = 1:len1
        roiData1(coords1(1,ii), coords1(2,ii), coords1(3,ii)) = roiColor;
    end
    
    roiData2 = zeros(viewGet(vw, 'anatomy size'));
    for ii = 1:len2
        roiData2(coords2(1,ii), coords2(2,ii), coords2(3,ii)) = roiColor;
    end
    
    roiData3 = zeros(viewGet(vw, 'anatomy size'));
    for ii = 1:len3
        roiData3(coords3(1,ii), coords3(2,ii), coords3(3,ii)) = roiColor;
    end
    
    mmPerVox = viewGet(vw, 'mmPerVox');
    [data1, xform, ni] = mrLoadRet2nifti(roiData1, mmPerVox);
    [data2, xform, ni] = mrLoadRet2nifti(roiData2, mmPerVox);
    [data3, xform, ni] = mrLoadRet2nifti(roiData3, mmPerVox);
    
    
    % Now that we have the data structure in the style of a nifti, we can index
    % the qmr brain maps!
    cd 3DAnatomy
    cd ..
    anatDir = pwd;
    T1ni = readFileNifti(fullfile(anatDir,'mrQ_aligned','OutPutFiles_1','BrainMaps','T1_map_lsq_rs1mm.nii.gz'));
    MTVni= readFileNifti(fullfile(anatDir,'mrQ_aligned','OutPutFiles_1','BrainMaps','TV_map_rs1mm.nii.gz'));

    % Threshold to exclude voxels partially voluming white matter and CSF
    % These values are anatomically infeasible numbers taken from the
    % literature (e.g. a volume with <5% tissue is likely not cortical, T1
    % relaxation time quicker than 0.5s is likely white matter, etc).
    MTVni.data(MTVni.data<=0.05) = NaN;
    MTVni.data(MTVni.data>=0.4) = NaN;
    T1ni.data(T1ni.data<=0.5) = NaN;
    T1ni.data(T1ni.data>=2.3) = NaN;
    
    % Now let's get the qmri map means from independent voxels in each run
    run1T1 = nanmean(T1ni.data(data1==1)); run1TV = nanmean(MTVni.data(data1==1)); 
    run2T1 = nanmean(T1ni.data(data2==1)); run2TV = nanmean(MTVni.data(data2==1)); 
    run3T1 = nanmean(T1ni.data(data3==1)); run3TV = nanmean(MTVni.data(data3==1)); 
    
    % Store these values in our vector and finally move on to next subject
    T1vals(i) = (run1T1 + run2T1 + run3T1)/3;
    MTVvals(i)= (run1TV + run2TV + run3TV)/3;
    
    % Let's clear some variables to avoid issues
    clearvars -except i active inactive saveName sessions mriDir selectivity T1vals MTVvals SIRvals subjects ages subs fileName roiList saveFlag
    
    
end % this ends the sessions loop

% Let's save the data as is, and removing NaNs to ease future analyses
    qt1 = T1vals(~isnan(selectivity));
    qtv = MTVvals(~isnan(selectivity));
    qsel= selectivity(~isnan(selectivity));
    a = ages(~isnan(selectivity));
    s = subs(~isnan(selectivity));
    
saveDir = '...Localizer/results/indepAnalysis';
save(fullfile(saveDir,fileName),'selectivity','T1vals','MTVvals','subjects','ages','qt1','qtv','qsel','a')
cd(saveDir)

