% histoQMR.m
%
% This script will load the data file saved out from
% mvInitLongi_ventralCortex.m and plot random effects histograms with
% shaded standard error . 

%% Fus-faces and CoS-places

dataDir = '.../Localizer/results/indepAnalysis';
cd(dataDir);

load right_pfus2_faceVox_allSubs.mat

% We need to remove subjects that don't have an roi
check = mean(T1valsVox,2);
T1valsVox(check==0,:) = [];
ages(check'==0) = [];

nA = sum(ages>18);
nK = sum(ages<18);

face_mean_t1_adult = nanmean(T1valsVox(ages>18,:),1);
face_mean_t1_child = nanmean(T1valsVox(ages<18,:),1);
face_mean_tv_adult = nanmean(MTVvalsVox(ages>18,:),1);
face_mean_tv_child = nanmean(MTVvalsVox(ages<18,:),1);

face_ste_t1_adult = nanstd(T1valsVox(ages>18,:),1) / sqrt(nA);
face_ste_t1_child = nanstd(T1valsVox(ages<18,:),1) / sqrt(nK);
face_ste_tv_adult = nanstd(MTVvalsVox(ages>18,:),1)/ sqrt(nA);
face_ste_tv_child = nanstd(MTVvalsVox(ages<18,:),1)/ sqrt(nK);

load right_cos2_placeVox_allSubs.mat

% We need to remove subjects that don't have an roi
check = mean(T1valsVox,2);
T1valsVox(check==0,:) = [];
ages(check'==0) = [];

nA = sum(ages>18);
nK = sum(ages<18);

place_mean_t1_adult = nanmean(T1valsVox(ages>18,:),1);
place_mean_t1_child = nanmean(T1valsVox(ages<18,:),1);
place_mean_tv_adult = nanmean(MTVvalsVox(ages>18,:),1);
place_mean_tv_child = nanmean(MTVvalsVox(ages<18,:),1);

place_ste_t1_adult = nanstd(T1valsVox(ages>18,:),1) / sqrt(nA);
place_ste_t1_child = nanstd(T1valsVox(ages<18,:),1) / sqrt(nK);
place_ste_tv_adult = nanstd(MTVvalsVox(ages>18,:),1)/ sqrt(nA);
place_ste_tv_child = nanstd(MTVvalsVox(ages<18,:),1)/ sqrt(nK);

% Adults fusiform vs. cos T1
f = figure('Position',[100 100 600 400]); hold on;
H1 = shadedErrorBar([],face_mean_t1_adult,face_ste_t1_adult,[0.5 0 0],1);
H2 = shadedErrorBar([],place_mean_t1_adult,place_ste_t1_adult,[0.5,0.4,0.2],1);
set(gca,'xlim', [0 35], 'xtick', [0:5:35],'xticklabel',{'0' '0.7' '0.95' '1.2' '1.45' '1.7' '1.95' '2.2'},'ytick',[0:0.5:2.5],'yticklabel',{'0' '' '5' '' '10' ''},'fontsize',16);
xlabel('T1 relaxation [s]','fontsize',16)
ylabel('Probability density [%]')

% Children pfus vs. cos T1
r = figure('Position',[100 100 600 400]); hold on; grid on;
H1 = shadedErrorBar([],face_mean_t1_child,face_ste_t1_child,[1 0 0],1);
H2 = shadedErrorBar([],place_mean_t1_child,place_ste_t1_child,[1 0.8 0.4],1);
set(gca,'xlim', [0 35], 'xtick', [0:5:35],'xticklabel',{'0' '0.7' '0.95' '1.2' '1.45' '1.7' '1.95' '2.2'},'ytick',[0:0.5:4],'yticklabel',{'0' '' '5' '' '10' '' '15' '' '20'},'fontsize',16);
xlabel('T1 relaxation [s]','fontsize',16)
ylabel('Probability density [%]')

% Adults vs. Children Fusiform
s = figure('Position',[100 100 600 400]); hold on; grid on;
H1 = shadedErrorBar([],face_mean_t1_adult,face_ste_t1_adult,[0.5,0,0],1);
H2 = shadedErrorBar([],face_mean_t1_child,face_ste_t1_child,[1,0,0],1);
set(gca,'xlim', [0 35], 'xtick', [0:5:35],'xticklabel',{'0' '0.7' '0.95' '1.2' '1.45' '1.7' '1.95' '2.2'},'ytick',[0:0.5:4],'yticklabel',{'0' '' '5' '' '10' '' '15' '' '20'},'fontsize',16);
xlabel('T1 relaxation [s]','fontsize',16)
ylabel('Probability density [%]')


% Adults vs. Children CoS
s = figure('Position',[100 100 600 400]); hold on; grid on;
H1 = shadedErrorBar([],place_mean_t1_adult,place_ste_t1_adult,[0.5,0.4,0.2],1);
H2 = shadedErrorBar([],place_mean_t1_child,place_ste_t1_child,[1 0.8 0.4],1);
set(gca,'xlim', [0 35], 'xtick', [0:5:35],'xticklabel',{'0' '0.7' '0.95' '1.2' '1.45' '1.7' '1.95' '2.2'},'ytick',[0:0.5:2.5],'yticklabel',{'0' '' '5' '' '10' ''},'fontsize',16);
xlabel('T1 relaxation [s]','fontsize',16)
ylabel('Probability density [%]')

