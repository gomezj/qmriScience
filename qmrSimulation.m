% qmrSimulations.m
%
% This code will plot results from a simulation to counter the argument
% that all the tissue volume development could be coming solely from
% myelination of axons. 

% The volume change in pFus-faces from childhood to adulthood is 0.0091mm^3
% If this change were due solely to increases in myelination of axons, then
% we can do some simple geometry to calculate how much an axon would have
% increase its myelination. We will assume the average length of an axon
% passing through a voxel is 0.5mm, and then we will sweep through three key
% parameters (axon number = A, initial myelin thickness = imt, and axon diameter = D). 

% We will bound our axon number using data measures from several animals
% reported in Carlo et al. 2012 (Upper limit of 50k neurons in cubic mm).
% From LaMantia, however, in the corpus callosum, only 73% to 96% of axons
% are myelinated by adulthood. So the upper limit of 50k axons per voxel is
% extremely liberal because (1) it was determined from V1 in animals which
% is probably denser than IT and (2) not all neurons will have myelinated
% axons, so they can't contribute to the development. So our range of axons
% number (A) will be 30,000<A<48,000

% We will bound our axon diameter using data measured from LaMantia et al.
% 1990 (from 0.4 micron diamter to 0.8 micron diameter, Figure 12).
% Note however that these are myelinated axons, so the diameter includes 
% myelin sheath thickness, so we will adjust the bounds to be 0.2 - 0.7.
% Unmyelinated axons are between 0.2 to 0.4 microns as reference. 
 
% We will bound initial myelin thickness from the same LaMantia paper to be
% between 0 to 0.1 micrometers. These were estimated from Figure 10, where axons
% can be either unmyelinated (zero) or very myelinated, with the thickness
% of myelin wrapping extending up to a thickness equal to the diameter of
% the smallest axon pictured in Figure 10, which they say is 0.1 microns.
% Again, these numbers are likely VERY liberal especially when one views
% the myelin stains of the fusiform in supplemental figure 8 which shows
% the amount of myelin within the adult cortex is likely an order of
% magnitude less than an in white matter from which these simulation
% numbers are being derived.

% Equation realting the volume change observed in pFus-faces from childhood
% to adulthood. First we need to know how much tissue volume increase there
% was:
% 615400000 is cubic um of macromolecules in kids right pFus, then there is 
% 77540400 cubic um of volume increase, so deltaV=77540400;

% This is plugged into the equation relating certain parameters to vol increase:
% r2 = sqrt( ((deltaV)/((A)*(pi)*(500))) + (D)^2 ); 

% Set our variable limits:
% Diameter range:
D = linspace(0.2, 0.7);
% Initial myelin thickness
imt = linspace(0, 0.1); % we won't sweep this variable and assume it's included in D
% Number of axons myelinated
A = linspace(30000, 48000);

% Now create the simulation surface
dataSurf = zeros(100,100);
for x=1:length(A)
    
    for y=1:length(D)
        r2 = sqrt( ((77540400)/((A(x))*(pi)*(500))) + (D(y)/2)^2 );
        r1 = (D(y)/2);
        dataSurf(x,y) = ((r2 - r1)/(r1)) * 100;
        %dataSurf(x,y) = (sqrt( ((9100000)/((A(x))*(pi)*(500))) + (D(y)/2)^2 ) - (D(y)/2) ) / (D(y)/2);
        
    end

end

% dataSurf thus contains a matrix whose values say, for a given number of
% axons and initial starting diameter of those axons in a given cubic mm of cortex,
% how much would the myelin have to increase radially in micrometers to
% account for the volume change

figure;
surf(dataSurf);
xlabel('Axon Number','FontSize',16)
ylabel('Initial Axon Diameter','FontSize',16)
zlabel({'Required Radial Increase of Sheath', 'as a Percentage of Initial Axon Radius'},'FontSize',16)
set(gca,'XTick',[0,50,100],'XTickLabel',{'30,000' '39,000' '48,000'})
set(gca,'YTick',[0,50,100],'YTickLabel',{'0.2' '0.4475' '0.7'})
set(gca,'FontSize',14)
view(37.5,30)

% Or plot lines in a 2D plot
figure; 
colors = [1 0.4 0.4; 1 0.7 0.4; 1 1 0.4; 0.7 1 0.4; 0.4 1 0.4; 0.4 1 0.7; 0.4 1 1; 0.4 0.7 1; 0.4 0.4 1; 0.2 0.2 1];
xax = [1:100];
plot(xax, dataSurf(1,:),'Color',colors(1,:),'LineWidth',3);
hold on;
for i=2:11
   plot(xax, dataSurf(10*(i-1),:),'Color',colors(i-1,:),'LineWidth',3);
   hold on;
end
grid on; 
set(gca,'XTickLabel',{'0.2' '0.25' '0.3' '0.35' '0.4' '0.45' '0.5' '0.55' '0.6' '0.65' '0.7'},'FontSize',14)
legend(num2str(A(1)),num2str(round(A(10))),num2str(round(A(20))),num2str(round(A(30))),num2str(round(A(40))),num2str(round(A(50))),num2str(round(A(60))),num2str(round(A(70))),num2str(round(A(80))),num2str(round(A(90))),num2str(round(A(100))))
xlabel('Initial Axon Diameter','FontSize',16)
ylabel({'Required Radial Increase of Sheath', 'as a Percentage of Initial Axon Radius'},'FontSize',16)
title({'Myelin sheath increases required to account for','tissue volume increase from childhood to adulthood in Fus-Faces'},'FontSize',18)
