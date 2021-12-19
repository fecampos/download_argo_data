clear all; close all; clc;

addpath(genpath('/home/fecg/Desktop/Roms/m_map')); addpath(genpath('/media/fecg/FECG/gsw_matlab_v3'))

my1 = customcolormap_preset('red-white-blue');

my2 = customcolormap_preset('red-yellow-green');

file = '../3901231_prof.nc';

lon = ncread(file,'LONGITUDE',1,108); 

lat = ncread(file,'LATITUDE',1,108); 

time = ncread(file,'JULD',1,108)+datenum('1950-01-01')-1; nt = length(time);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file = 'out.nc';

depth = ncread(file,'depth',1,25); ti = ncread(file,'time'); 

temp = squeeze(ncread(file,'thetao',[1 1 1 1],[1 1 25 inf]));

salt = squeeze(ncread(file,'so',[1 1 1 1],[1 1 25 inf]));

[zz tt] = meshgrid(-depth,time);

mlp = zeros(length(time),1);

for i = 1:length(ti)
  [mlp(i), qe, imf] = get_mld(zz(i,:),temp(:,i));
end

close all; figure('units','normalized','Position',[0.1 0.1 0.7 0.5]);
subplot(4,5,[10 15])
m_proj('miller','lat',[-7 -2],'lon',[-84 -79]); hold on
m_grid('tickdir','out','linewi',2); hold on
m_plot(lon(1),lat(1),'o','MarkerSize',8,'MarkerEdgeColor','g','MarkerFaceColor','g');
m_plot(lon(end),lat(end),'o','MarkerSize',8,'MarkerEdgeColor','b','MarkerFaceColor','b');
m_plot(lon,lat,'k','MarkerSize',8,'MarkerEdgeColor','b','MarkerFaceColor','b');
m_gshhs_h('patch',[0 0 0]); title({'ARGO 3901231','11-03-16 -> 25-12-18'})


for i = length(ti)
  subplot(4,5,[1 2 3 4 6 7 8 9])
  pcolor(repmat(time(1:i),[1 25]),zz(1:i,:),temp(:,1:i)'); hold on; shading interp; colormap jet
  contour(repmat(time(1:i),[1 25]),zz(1:i,:),temp(:,1:i)',[14 16 18 20 22 24 26 28 30],'k','showtext','on'); 
  plot(time(1:i),mlp(1:i),'color','r','linewidth',3)
  datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-150 0]); caxis([14 28]); title('potential temperature [14 28]')

  subplot(4,5,[11 12 13 14 16 17 18 19])
  pcolor(repmat(time(1:i),[1 25]),zz(1:i,:),salt(:,1:i)'); hold on; shading interp; colormap jet
  contour(repmat(time(1:i),[1 25]),zz(1:i,:),salt(:,1:i)',[34:0.2:37],'k','showtext','on'); 
  plot(time(1:i),mlp(1:i),'color','r','linewidth',3)
  datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-150 0]); caxis([34.3 36]); title('practical absolute [34.3 36]')
end

  set(gcf,'Color','white','Renderer','zbuffer')
  set(gca,'Color','white','XColor','black', 'YColor','black')
  set(gcf, 'PaperPositionMode', 'manual');
  set(gcf, 'PaperPosition', [0.3 0 22.0 8.0]); 
  set(gcf,'InvertHardcopy','off'); 
  print('-dpng','-r100',['glorys12v1_comparison.png']); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc

addpath(genpath('/home/fecg/Desktop/Roms/m_map')); addpath(genpath('/media/fecg/FECG/gsw_matlab_v3'))

my1 = customcolormap_preset('red-white-blue');

my2 = customcolormap_preset('red-yellow-green');

file = '../3901231_prof.nc';

lon = ncread(file,'LONGITUDE',1,108); 

lat = ncread(file,'LATITUDE',1,108); 

time = ncread(file,'JULD',1,108)+datenum('1950-01-01')-1; nt = length(time); time = time(2:end);

file = 'extract_time.nc';

lx = ncread(file,'longitude');

ly = ncread(file,'latitude'); 

[yy xx] = meshgrid(ly,lx);

temp = squeeze(ncread(file,'thetao',[1 1 1 1],[inf inf 1 inf]));

salt = squeeze(ncread(file,'so',[1 1 1 1],[inf inf 1 inf]));

u = squeeze(ncread(file,'uo',[1 1 1 1],[inf inf 1 inf])); v = squeeze(ncread(file,'vo',[1 1 1 1],[inf inf 1 inf])); spd = sqrt(u.^2+v.^2);

ssh = squeeze(ncread(file,'zos',[1 1 1],[inf inf inf]));


close all; figure('units','normalized','Position',[0.1 0.1 0.7 0.5]);
subplot(1,2,1)
m_proj('miller','lat',[-7 -2],'lon',[-84 -79]); hold on
m_grid('tickdir','out','linewi',2); hold on
m_coast('patch',[0 0 0]); title('SSH [-0.5 0.5]')

subplot(1,2,2)
m_proj('miller','lat',[-7 -2],'lon',[-84 -79]); hold on
m_grid('tickdir','out','linewi',2); hold on
m_coast('patch',[0 0 0]); title('Surface velocity [0 1]')

vidObj = VideoWriter('vel_ssh_glorys12v1.avi');
vidObj.Quality = 100;
vidObj.FrameRate = 10;
open(vidObj);


for i = 1:length(time)
  ax(1) = subplot(1,2,1);
  m_pcolor(xx,yy,squeeze(ssh(:,:,i))); hold on; shading interp; colormap(ax(1),my1);
  m_contour(xx,yy,squeeze(ssh(:,:,i)),[-0.5:0.01:0.5],'k','showtext','on'); 
  m_plot(lon(1:i),lat(1:i),'color','k','linewidth',3)
  m_coast('patch',[0 0 0]); 
  caxis([-0.4 0.4]); title('SSH [-0.5 0.5]')

  ax(2) = subplot(1,2,2);
  m_pcolor(xx,yy,squeeze(spd(:,:,i))); hold on; shading interp; colormap(ax(2),jet);
  m_quiver(xx,yy,squeeze(u(:,:,i)),squeeze(v(:,:,i)),1,'k'); 
  m_plot(lon(1:i),lat(1:i),'color','k','linewidth',3)
  m_coast('patch',[0 0 0]); 
  caxis([0 1]); title('Surface velocity [0 1]')

   F = getframe(gcf);
   writeVideo(vidObj,F.cdata);
end
close(gcf)

close(vidObj);

for i = 1:length(time)
  ax(1) = subplot(1,2,1);
  m_pcolor(xx,yy,squeeze(temp(:,:,i))); hold on; shading interp; colormap(ax(1),flipud(hot));
  m_contour(xx,yy,squeeze(temp(:,:,i)),[13:0.5:32],'k','showtext','on'); 
  m_plot(lon(1:i),lat(1:i),'color','k','linewidth',3)
  m_coast('patch',[0 0 0]); 
  caxis([18 32]); title('Conservative temperature [13 32]')

  ax(2) = subplot(1,2,2);
  m_pcolor(xx,yy,squeeze(salt(:,:,i))); hold on; shading interp; colormap(ax(2),jet);
  m_contour(xx,yy,squeeze(salt(:,:,i)),[33.0:0.1:35.5],'k','showtext','on'); 
  m_plot(lon(1:i),lat(1:i),'color','k','linewidth',3)
  m_coast('patch',[0 0 0]); 
  caxis([33 35.5]); title('Salinity absolute [33 35.5]')

   F = getframe(gcf);
   writeVideo(vidObj,F.cdata);
end
close(gcf)

close(vidObj);



