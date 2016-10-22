% jesseIndepBehavioral.m
%
% This script will load the data from the independent functional analysis
% script and correlate behavioral scores with qMRI and fMRI measures in fROIs of VTC
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ages and behavioral scores of all subjects. NaN indicates that the
% subject was unable to complete the test. 
ages  =     [26              23               23              22              22              24               24             22               25              23                23              24                 24               26              25              22              23              24              24              23             25               23                28               24               27                7                10               6              9                10               5                 7                11                 10                11               6                 7                 10              12              9                  6               10              10               11              10                6                 5];
cfmtb  =    [99              NaN              72              88               82             67               88             89              78              93                94               93                100              99              NaN             99              86              NaN             83              99             89                98               81               97                94                 72               50              83                82               76               86                67               51                 61               78               NaN                 56               74              94             54                 57               76             75               78              68                71                31 ];
recPlace=   [56.3            NaN              56.3            75               75             63               56             56.3            43.8            75                69               56                81               56              NaN             69              44              NaN             50              50             63                63               69               69                69                 87               75              56                56               44               75                81               63                 44               56               75                  69               81              56.3           63                 56               62             62.5             63              63                81                81 ];

%% Face-selective ROIs and face memory
% Let's load the data. It came from the indepndent analysis mvInitLongi.m
dataDir = '...Localizer/results/indepAnalysis';
cd(dataDir)
load right_pfus2_face_allSubs.mat

% And we have to make the anatomical data match the behavioral
t1Face = T1vals; t1Face(isnan(cfmtb)) = NaN;
selFace = selectivity; selFace(isnan(cfmtb)) = NaN;
cfmtboys = cfmtb; cfmtboys(isnan(t1Face)) = NaN;
a = ages;

% Now remove NaNs
a(isnan(t1Face)) = [];
t1Face(isnan(t1Face)) = [];
selFace(isnan(selFace)) = [];
cfmtboys(isnan(cfmtboys)) = [];

% let's plot
f = figure; scatter(t1Face,cfmtboys,125,'r','filled','MarkerEdgeColor','k'); lsline; colormap('gray'); %colorbar;
[r,p] = corrcoef(t1Face,cfmtboys); axis square; set(gca,'TickDir','out','FontSize',16);
title({'Left pFus-faces T1 versus CFMT';['R= ' num2str(r(1,2)) ', p= ' num2str(p(1,2))]}); xlabel('T1 relaxation','FontSize',20); ylabel('Face Recognition %-correct','FontSize',20);
set(gca,'xlim',[1.2 1.8]);  

f2 = figure; scatter(t1Face,selFace,125,'r','filled','MarkerEdgeColor','k'); lsline; colormap('gray'); %colorbar; 
[r,p] = corrcoef(t1Face,selFace); axis square; set(gca,'TickDir','out','FontSize',16);
title({'Right Fus-faces T1 versus Selectivity';['R= ' num2str(r(1,2)) ', p= ' num2str(p(1,2))]}); xlabel('T1 relaxation','FontSize',20); ylabel('Selectivity (t-value)','FontSize',20);
set(gca,'xlim',[1.2 1.8]); 

% Plot ages separately
% f = figure; scatter(t1Face,cfmtboys,'w','.'); hold on; lsline;
% scatter(t1Face(a>18),cfmtboys(a>18),125,'r','filled','MarkerEdgeColor','k','Marker','d'); 
% hold on; 
% scatter(t1Face(a<18),cfmtboys(a<18),125,'r','filled','MarkerEdgeColor','k','Marker','o'); 
% axis square; set(gca,'xlim',[1.2 1.8]); grid on;
% [r,p] = corrcoef(t1Face,cfmtboys);
% title({'Left mFus-faces T1 versus CFMT';['R= ' num2str(r(1,2)) ', p= ' num2str(p(1,2))]}); xlabel('T1 relaxation','FontSize',20); ylabel('Selectivity (t-value)','FontSize',20);

%% Place-selective ROIs and place memory
dataDir = '...Localizer/results/indepAnalysis';
cd(dataDir)
load right_cos2_place_allSubs.mat


% And we have to make the anatomical data match the behavioral
t1Place = T1vals; t1Place(isnan(recPlace)) = NaN; 
selPlace = selectivity; selPlace(isnan(recPlace)) = NaN;
recmemplace = recPlace; recmemplace(isnan(t1Place)) = NaN;
a = ages;

% Now remove NaNs
a(isnan(t1Place)) = [];
t1Place(isnan(t1Place)) = [];
selPlace(isnan(selPlace)) = [];
recmemplace(isnan(recmemplace)) = [];

% One subject has an anatomical anomaly in their collateral sulcus
% affecting the T1 estimation (they have a T1 relaxation time close to 1
% second, which is several standard deviations from the mean as seen in the
% CoS T1 distributions in Figure 1C. We will exclude their CoS roi).
a(t1Place<1.2)=[];
recmemplace(t1Place<1.2)=[];
selPlace(t1Place<1.2)=[];
t1Place(t1Place<1.2)=[];

% let's plot t1 vs. behavior
f = figure; scatter(t1Place,recmemplace,125,'g','filled','MarkerEdgeColor','k'); lsline; 
[r,p] = corrcoef(t1Place,recmemplace);
title({'Right CoS-place T1 versus RecMem Places';['R= ' num2str(r(1,2)) ', p= ' num2str(p(1,2))]}); xlabel('T1 relaxation'); ylabel('Place Recognition (%-correct)');

% let's plot t1 vs. selectivity
f = figure; scatter(t1Place,selPlace,125,'g','filled','MarkerEdgeColor','k'); lsline;
[r,p] = corrcoef(t1Place,selPlace);
title({'Right CoS-place T1 versus Selectivity';['R= ' num2str(r(1,2)) ', p= ' num2str(p(1,2))]}); xlabel('T1 relaxation'); ylabel('Place Selectivity (t-value)');

%% Predict CFMT-boys using both T1 and Selectivity

% Let's make a model that predicts the cfmt boys score using both T1 and
% selectivity (or other factors like curvature or thickness of cortex)
% The code below was taken from mathworks website on multivariate general linear model, their
% multivariate regression function.  
% http://www.mathworks.com/help/stats/multivariate-general-linear-model.html
% We are producing a simple linear model of the following form:
% Y = Xt1(beta1) + Xsel(beta2) + e, where Xt1 is the t1 relaxation rate and
% Xsel is the selectivity of each subject's right FFA, and e is the error
% term. Y is the predicted output, in this case performance on CFMT-boys. 

% Set up behavioral scores and get tissue data
cfmtb  =    [99              NaN              72              88               82             67               88             89              78              93                94               93                100              99              NaN             99              86              NaN             83              99             89                98               81               97                94                 72               50              83                82               76               86                67               51                 61               78               NaN                 56               74              94             54                 57               76             75               78              68                71                31 ];

% get the tissue data
dataDir = '.../Localizer/results/indepAnalysis/python';
cd(dataDir)
load right_pfus2_face_allSubs.mat
% dataDir = '.../Localizer/results/indepAnalysis';
% cd(dataDir)
% load right_pfus_face_thickness_curvature_allSubs.mat


% make sure behavior and tissue data align
t1Face = T1vals; t1Face(isnan(cfmtb)) = NaN;
selFace = selectivity; selFace(isnan(cfmtb)) = NaN;
cfmtboys = cfmtb; cfmtboys(isnan(t1Face)) = NaN;
t1Face(isnan(t1Face)) = [];
selFace(isnan(selFace)) = [];
cfmtboys(isnan(cfmtboys)) = [];

Y = cfmtboys';
%Y = qsel';

[n,d]=size(Y);
x1 = zscore(t1Face)';
x2 = zscore(selFace)';
% x1 = zscore(qt1)';
% x2 = zscore(qThick)';

Xmat = [ones(n,1) x1 x2];
Xcell = cell(1,n);

for i = 1:n
Xcell{i} = [kron([Xmat(i,:)],eye(d))];
end

[beta,sigma,e,v] = mvregress(Xcell,Y);

figure; 
scatter((cfmtboys),((t1Face)*(beta(2)) + (selFace)*(beta(3)))  )
lsline; xlabel('Observed CFMT-boys Score (%-correct)'); ylabel('Predicted CFMT-boys Score');
[r,p] = corrcoef((cfmtboys),((t1Face)*(beta(2)) + (selFace)*(beta(3)))  );
title({'Predicting Face Recognition Memory using T1rr and Selectivity', ['r-squared = ' num2str(r(1,2)^2) ', p = ' num2str(p(1,2))]})

% figure; 
% scatter((qsel),((qt1)*(beta(2)) + (qThick)*(beta(3)))  )
% lsline; xlabel('Observed Selectivity (t-value)'); ylabel('Predicted Selectivity (t-value)');
% [r,p] = corrcoef((qsel),((qt1)*(beta(2)) + (qThick)*(beta(3)))  );
% title({'Predicting Face Selectivity using T1 and Thickness', ['r-squared = ' num2str(r(1,2)^2) ', p = ' num2str(p(1,2))]})


