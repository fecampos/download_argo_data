clear all; close all; clc;

addpath(genpath('/home/fecg/Desktop/Roms/m_map')); addpath(genpath('/media/fecg/FECG/gsw_matlab_v3')); addpath(genpath('/media/fecg/share_info/analysis/scripts_argo'))

my2 = customcolormap_preset('red-yellow-blue');

file = dir('./*_prof.nc'); file = file.name;

lon = ncread(file,'LONGITUDE',1,inf);

lat = ncread(file,'LATITUDE',1,inf);

time = ncread(file,'JULD',1,inf)+datenum('1950-01-01')-1; nt = length(time);

temp_argo = ncread(file,'TEMP_ADJUSTED',[1 1],[inf inf]);

salt1 = ncread(file,'PSAL_ADJUSTED',[1 1],[inf inf]);

depth1 = ncread(file,'PRES_ADJUSTED',[1 1],[inf inf]);

[datestr(time,'yyyy-mm-dd'),num2str(lon),num2str(lat),num2str([0:nt-1]','%03.f')]

temp_argo = gsw_pt_from_t(salt1,temp_argo,depth1,0);

h=gsw_z_from_p(depth1,lat); mld_argo = zeros(length(time),1); 

temp_cow4 = squeeze(ncread('./6901504_Sprof_cow4.nc','temp'));
h2 = ncread('6901504_Sprof_cow4.nc','depth'); nz = length(h2); mld_cow4 = zeros(length(time),1); h2 = repmat(-h2,[1 nt]);

temp_glob = squeeze(ncread('./6901504_Sprof_glorys12v1.nc','thetao',[1 1 1 1],[inf inf 25 inf]));
h3 = ncread('./6901504_Sprof_glorys12v1.nc','depth',1,25); mld_glob = zeros(length(time),1); h3 = repmat(-h3,[1 nt]);

for i = 1:length(time)
  [mld_argo(i), qe, imf] = get_mld(h(:,i),temp_argo(:,i));
  [mld_cow4(i), re, img] = get_mld(h2(:,i),temp_cow4(:,i));
  [mld_glob(i), se, imh] = get_mld(h3(:,i),temp_glob(:,i));
end

i=length(time);

close all; figure('units','normalized','Position',[0.1 0.1 0.8 0.6]);
subplot(6,5,[15 20])
m_proj('miller','lat',[-12 -8],'lon',[-88 -79]); hold on
m_grid('tickdir','out','linewi',2); hold on
m_plot(lon(1),lat(1),'o','MarkerSize',8,'MarkerEdgeColor','g','MarkerFaceColor','g');
m_plot(lon(end),lat(end),'o','MarkerSize',8,'MarkerEdgeColor','b','MarkerFaceColor','b');
m_plot(lon,lat,'k');
m_gshhs_h('patch',[0 0 0]); title({'ARGO 6901504',[datestr(time(1),'yyyy-mm-dd') ' -> ' datestr(time(end),'yyyy-mm-dd')]})

subplot(6,5,[1 2 3 4 6 7 8 9])
pcolor(repmat(time(1:i),[1 129])',h(:,1:i),temp_argo(:,1:i)); hold on; shading interp; colormap jet
contour(repmat(time(1:i),[1 129])',h(:,1:i),temp_argo(:,1:i),[14 16 18 20 22 24 26 28 30],'k','showtext','on'); 
plot(time(1:i),mld_argo(1:i),'color','k','linewidth',3)
datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-100 0]); caxis([14 28]); title('ARGO','fontweight','bold')

subplot(6,5,[11 12 13 14 16 17 18 19])
pcolor(repmat(time(1:i),[1 51])',h2(:,1:i),temp_cow4(:,1:i)); hold on; shading interp; colormap jet
contour(repmat(time(1:i),[1 51])',h2(:,1:i),temp_cow4(:,1:i),[14 16 18 20 22 24 26 28 30],'k','showtext','on'); 
plot(time(1:i),mld_cow4(1:i),'color','k','linewidth',3)
datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-100 0]); caxis([14 28]);  title('COW4','fontweight','bold')

subplot(6,5,[21 22 23 24 26 27 28 29])
pcolor(repmat(time(1:i),[1 25])',h3(:,1:i),temp_glob(:,1:i)); hold on; shading interp; colormap jet
contour(repmat(time(1:i),[1 25])',h3(:,1:i),temp_glob(:,1:i),[14 16 18 20 22 24 26 28 30],'k','showtext','on'); 
plot(time(1:i),mld_glob(1:i),'color','k','linewidth',3)
datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-100 0]); caxis([14 28]);  title('GLORYS12V1','fontweight','bold')

cb = colorbar; set(cb,'location','southoutside','position',[0.13 0.06 0.61 0.009]); cb.Title.String = '^{o}C'; cb.FontSize = 18; cb.FontWeight='bold';

set(gcf,'Color','white','Renderer','zbuffer')
set(gca,'Color','white','XColor','black', 'YColor','black')
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0.3 0 22.0 12.0]); 
set(gcf,'InvertHardcopy','off'); 
print('-dpng','-r300',['comparison_temperature_6901504.png']); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; figure('units','normalized','Position',[0.1 0.1 0.8 0.6]);

subplot(6,5,[15 20])
m_proj('miller','lat',[-12 -8],'lon',[-88 -79]); hold on
m_grid('tickdir','out','linewi',2); hold on
m_plot(lon(1),lat(1),'o','MarkerSize',8,'MarkerEdgeColor','g','MarkerFaceColor','g');
m_plot(lon(end),lat(end),'o','MarkerSize',8,'MarkerEdgeColor','b','MarkerFaceColor','b');
m_gshhs_h('patch',[0 0 0]); title({'ARGO 6901459',[datestr(time(1),'yyyy-mm-dd') ' -> ' datestr(time(end),'yyyy-mm-dd')]})

nFrames = 10;
vidObj = VideoWriter('argo_temp_comparison_6901504.avi');
vidObj.Quality = 100;
vidObj.FrameRate = 20;
open(vidObj);

for i = 2:length(time);

  subplot(6,5,[15 20])
  m_plot(lon(1:i),lat(1:i),'k'); title({'ARGO 6901504',datestr(time(i))})

  subplot(6,5,[1 2 3 4 6 7 8 9])
  pcolor(repmat(time(1:i),[1 129])',h(:,1:i),temp_argo(:,1:i)); hold on; shading interp; colormap jet
  contour(repmat(time(1:i),[1 129])',h(:,1:i),temp_argo(:,1:i),[14 16 18 20 22 24 26 28 30],'k','showtext','on'); 
  plot(time(1:i),mld_argo(1:i),'color','k','linewidth',3)
  datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-100 0]); caxis([14 28]); title('ARGO','fontweight','bold')

  subplot(6,5,[11 12 13 14 16 17 18 19])
  pcolor(repmat(time(1:i),[1 51])',h2(:,1:i),temp_cow4(:,1:i)); hold on; shading interp; colormap jet
  contour(repmat(time(1:i),[1 51])',h2(:,1:i),temp_cow4(:,1:i),[14 16 18 20 22 24 26 28 30],'k','showtext','on'); 
  plot(time(1:i),mld_cow4(1:i),'color','k','linewidth',3)
  datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-100 0]); caxis([14 28]);  title('COW4','fontweight','bold')

  subplot(6,5,[21 22 23 24 26 27 28 29])
  pcolor(repmat(time(1:i),[1 25])',h3(:,1:i),temp_glob(:,1:i)); hold on; shading interp; colormap jet
  contour(repmat(time(1:i),[1 25])',h3(:,1:i),temp_glob(:,1:i),[14 16 18 20 22 24 26 28 30],'k','showtext','on'); 
  plot(time(1:i),mld_glob(1:i),'color','k','linewidth',3)
  datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-100 0]); caxis([14 28]);  title('GLORYS12V1','fontweight','bold')

  cb = colorbar; set(cb,'location','southoutside','position',[0.13 0.06 0.61 0.009]); cb.Title.String = '^{o}C'; cb.FontSize = 18; cb.FontWeight='bold';
  F = getframe(gcf);
  writeVideo(vidObj,F.cdata);
end
close(gcf)

close(vidObj);

