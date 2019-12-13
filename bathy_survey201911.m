% Rotate and interpolate GPS data

clear all
close all


% Bathy file | .txt with xyz matrix | RD coordinates
bathyfile = 'Z:\EgmondDuinOntwikkeling\201911 Egmond 39-43 bathy_topo\Data\xyz_bathy.txt';
topofile = 'Z:\EgmondDuinOntwikkeling\data\MLS\20191108\totalmap_circle.mat';
[bpath, bname, bext] = fileparts(bathyfile);
xyz = load(bathyfile);

% Get xyz (what to do with quality/type of data?)
xrd = xyz(:,1);
yrd = xyz(:,2);
zrd = xyz(:,3);
xyzRD = [xrd,yrd,zrd];

% Rotate and translate RD coordinates to local C3D Argus coordinates
xyz  = xyzRD2argC3D(xyzRD); % sets z-values to zero

% Topo data (lidar) | totalmap
load(topofile);
xt = Scant.Xg; 
yt = Scant.Yg;
zt = Scant.Zp;

% Combine bathy and topo data
x = [xyz(:,1); xt(:)];
y = [xyz(:,2); yt(:)];
z = [xyz(:,3); zt(:)];

% Loess interpolation of data
% Define grid locations (choose relevant range. For now min and max values
% taken)
dx = 5;
dy = 5;
xi = -200:dx:700;%-55:dx:1005;%ceil(min(x)):dx:floor(max(x));
yi = -2500:dy:1750; %-1273:dy:757;%ceil(min(y)):dy:floor(max(y));

% Define smoothing scales (suitable values still to be defined)
lx = 10;
ly = 200;

% Interpolate
[Xi,Yi,Zi, Ei] = loess_grid2dh(x,y,z, xi,yi, lx,ly);

% Remove data points with large errors (e.g. > 1m)
errors = find(Ei>0.25);
Zi(errors) = nan;

save([bname,'_GRID.mat'],'Xi', 'Yi', 'Zi', 'Ei')

% plot
disp('Plotting...')

% arrays to plot over bathy - Rijksstrandpalen 40-42
% -> Arguscoordinates (x,y)
% rsp = [...
%     -21.8               -2250               39
%     -19.4               -2000               39.25 
%     -17.0               -1750               39.5
%     -14.6               -1500               39.75
%     -12.2541749024097	-1251.40354610232   40
%     -9.60491698166487	-1001.09777023514   40.25
%     -7.82244052867019 	-751.909442302845   40.5   
%     -5.17318260792537 	-501.603666435668   40.75
%     -2.77459115430914 	-249.313661165862   41
%     0                   0                   41.25
%     1.65714321943036  	250.180442633613    41.5
%     4.4317343737395   	499.494103799475    41.75
%      6.95565906092001   	750.791994367966    42
%      9.4                1000                42.25
%      11.8               1250                42.5
%      14.2               1500                42.75
%     ];
rsp = [...
    -21.8               -2250               39
    -19.4               -2000               39.25
    -17.0               -1750               39.5
    -9.60491698166487	-1001.09777023514   40.25
    -5.17318260792537 	-501.603666435668   40.75
    -2.77459115430914 	-249.313661165862   41
    0                   0                   41.25
    4.4317343737395   	499.494103799475    41.75
    11.8               1250                42.5
    14.2               1500                42.75
    ];

rspnrs = num2str(rsp(:,3));

figure
set(gcf, 'Position', [1718 180 857 674])
% Bathy
%pcolor(Xi,Yi,Zi)
surf(Xi,Yi,Zi)
caxis([-9 3])
shading flat
colorbar('location','south')
colormap(jet)
hold on
% Contours
contour3(Xi,Yi,Zi,-10:0.25:10,'k:')   
contour(Xi,Yi,Zi,[0 0 0],'k','linewidth',2)   

% Rijksstrandpalen
rspxiyiz = nan(size(rsp,1),size(rsp,2));
% Arrays
for i=1:size(rsp,1)
    % Find rsp coordinates in interpolated grid
    [tmpx, xpos] = min(abs(Xi(1,:)-rsp(i,1))); % Find nearest x-coord in grid
    [tmpy, ypos] = min(abs(Yi(:,1)-rsp(i,2))); % Find nearest y-coord in grid
    rspxiyiz(i,:) = [Xi(1,xpos), Yi(ypos,1), Zi(ypos,xpos)];
    
    % Plot cross-shore array
    plot3(Xi(1,:),Yi(ypos,:),Zi(ypos,:),'k')
end
plot3(rspxiyiz(:,1),rspxiyiz(:,2),rspxiyiz(:,3)+.5,'ko')
text(rspxiyiz(:,1),rspxiyiz(:,2),rspxiyiz(:,3)+.5,rspnrs)

% title([{['Interpolated bathymetry Egmond: ',bname]},{'January 2019'}],'interpreter','none')
xlabel('Cross-shore (m)')
ylabel('Alongshore (m)')
set(gca,'dataaspectratio',[50 200 1])
set(gca,'xlim',[-60 800])
set(gca,'zlim',[-10 5])
set(gca,...
    'CameraPosition',[468.453 -4751.3 125.628],...
    'CameraTarget', [370 -250 -2.5],...
    'CameraViewAngle', 8.01243);