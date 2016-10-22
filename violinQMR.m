% violinQMR.m
% This script will load in the t1 and mtv values from each froi in each
% hemisphere and make subplots comparing each one 


dataDir = '.../Localizer/results/indepAnalysis';
cd(dataDir)

% Select which qMRI measure you want to plot T1 values (qt1) or MTV values
% (qtv)
t1 = true;
tv = false;

% Here are the fROIs we will plot. These were saved out from mvInitLongi.m
file = {'right_pfus2_face_allSubs.mat'}

colors = [255 0 0;
    102 0 0];
colors = colors/255;

figure;

% load the file
load(file{1})
toPlot = cell(1,2);

if t1
    adults = qt1(find(a>18));
    kids   = qt1(find(a<17));
else
    adults = qtv(find(a>18));
    kids   = qtv(find(a<17));
end

toPlot{2} = adults';
toPlot{1} = kids';

violin(toPlot,'xlabel',{'Children', 'Adults'},'facecolor',colors(1,:),'plotlegend',false,'facealpha',[1])
[h,p,ci,st] = ttest2(kids,adults);
title({'Right pFus' ; ['t = ' num2str(st.tstat) ', p = ' num2str(p)]}); box off


%% Plot T1 in face versus place rois in adults
% A different violin example plotted in Figure 3
dataDir = '.../Localizer/results/indepAnalysis';
cd(dataDir)

% Select which qMRI measure you want to plot T1 values (qt1) or MTV values
% (qtv)
t1 = true;
tv = false;

colors = [200 25 25;
         255 210 77]; 

colors = colors/255;

figure('Position',[100 100 600 500]);

% load the file
load('right_pfus2_face_allSubs.mat')
if tv
    qmr = qtv;
elseif t1
    qmr  = qt1;
end

toPlot = cell(1,2);
a(qt1<1.3)=[];
qmr(qt1<1.3)=[];
adultsF = qmr(find(a>18));
toPlot{1} = adultsF';

load('right_cos2_place_allSubs.mat')
if tv
    qmr = qtv;
elseif t1
    qmr  = qt1;
elseif sir
    qmr = qsir;
end

% One subject has an anatomical anomaly in their collateral sulcus
% affecting the T1 estimation (they have a T1 relaxation time close to 1
% second, which is several standard deviations from the mean as seen in the
% CoS T1 distributions in Figure 1C. We will exclude their CoS roi).
a(qt1<1.2)=[];
qmr(qt1<1.2)=[];
adultsP = qmr(find(a>18));
toPlot{2} = adultsP';

violin(toPlot,'xlabel',{'Fus-faces', 'CoS-places'},'facecolor',colors,'plotlegend',false,'facealpha',[1])
[h,pA,ci,stA] = ttest2(adultsF,adultsP);
box off; set(gca,'FontSize',24,'ylim',[1.2 1.8],'ytick',[1.2:0.2:1.8])

