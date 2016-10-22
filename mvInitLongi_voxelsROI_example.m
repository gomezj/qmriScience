% mvInitLongi_voxelsROI.m
%
% This code will get the voxels from an roi or list of rois to combine.

% Which ROIS do you want to load and combine?
roiList = {'rh_pFus_Faces'}; % this can be a list that will get combined into one fROI

% What do you want the output combined ROI to be called?
saveName = 'right_pfus_face';
saveFlag = false;

% Name of mat file that will contain final data vectors.
% Will be stored in FMRI/Localizer/results/indepAnalysis
fileName = 'right_pfus2_faceVox_example_allSubs';

% Example subject
subs = {'JG24'};
sessions = {'JG24_01062014'};
ages = [24];

mriDir = '/sni-storage/kalanit/biac2/kgs/projects/Longitudinal/FMRI/Localizer/data';
cd(mriDir);

T1vals    = zeros(1,length(subs));
MTVvals   = zeros(1,length(subs));
subjects = {};

tEdge = [0.5:0.05:2.3]; % This value splits both MTV and T1 into bin sizes that are 1/10th of their respective unit ranges (.1s or .01 tissue volume fraction)
vEdge = [0.05:0.01:0.4];
T1valsVox  = zeros(length(subs),length(tEdge)-1);
MTVvalsVox = zeros(length(subs),length(vEdge)-1);



for i = 1:length(sessions)
    %% Initialize a hidden gray for motionComp_refscan1 and
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

    roiDil = roi;
    
    if saveFlag
    % Let's save dilated ROI for quality check and figures later on
    local = false; forceSave = true;
    [vw, status, forceSave] = saveROI(vw, roiDil, local, forceSave);
    end

    %% Now we will initialize timecourseUI for each scan combination
    
    clear vw view
    view = initHiddenGray(3,1);
    view = loadROI(view,saveName);
    coords1 = view.ROIs(end).coords; 
    len1 = size(coords1, 2);
    
    roiColor = 1;
    
    roiData1 = zeros(viewGet(view, 'anatomy size'));
    for ii = 1:len1
        roiData1(coords1(1,ii), coords1(2,ii), coords1(3,ii)) = roiColor;
    end
    
    
    mmPerVox = viewGet(view, 'mmPerVox');
    [data1, xform, ni] = mrLoadRet2nifti(roiData1, mmPerVox);

    cd 3DAnatomy
    cd ..
    anatDir = pwd;
    T1ni = readFileNifti(fullfile(anatDir,'mrQ_aligned','OutPutFiles_1','BrainMaps','T1_map_lsq_rs1mm.nii.gz'));
    MTVni= readFileNifti(fullfile(anatDir,'mrQ_aligned','OutPutFiles_1','BrainMaps','TV_map_rs1mm.nii.gz'));
    
    
    % Threshold to ignore voxels partially voluming white matter and CSF
    MTVni.data(MTVni.data<=0.05) = NaN;
    MTVni.data(MTVni.data>=0.4) = NaN;
    T1ni.data(T1ni.data<=0.5) = NaN;
    T1ni.data(T1ni.data>=2.3) = NaN;
    
    % Now let's get the qmri map means from independent voxels in each run
    T1 = nanmean(T1ni.data(data1==1)); 
    TV = nanmean(MTVni.data(data1==1));
  
    T1vox = [T1ni.data(data1==1)];
    TVvox = [MTVni.data(data1==1)];
    
    % Store these values in our vector and finally move on to next subject
    T1vals(i) = T1;
    MTVvals(i)=TV;
    subjects{end+1} = subs{i};
    
    % The below only runs on matlab version r2015a
    t1s = histogram(T1vox,tEdge,'Normalization','pdf');
    T1valsVox(i,:)  = t1s.Values;
    
    tvs = histogram(TVvox,vEdge,'Normalization','pdf');
    MTVvalsVox(i,:) = tvs.Values;
    
    % Let's clear some variables to avoid issues
    clearvars -except MTVvalsVox T1valsVox tEdge vEdge i saveName sessions mriDir T1vals MTVvals subjects ages subs fileName roiList saveFlag
    
    
end % this ends the sessions loop


% Let's save our #1 funtime data superstar vectors
% let's remove nan and store these into a new variable
    qt1 = T1vals(~isnan(T1vals));
    qtv = MTVvals(~isnan(MTVvals));
    a = ages(~isnan(T1vals));

saveDir = '...Localizer/results/indepAnalysis';
save(fullfile(saveDir,fileName),'T1vals','MTVvals','subjects','ages','qt1','qtv','a','T1valsVox','MTVvalsVox')
