clear all; close all; clc;

addpath(genpath('/home/fecg/Desktop/Roms/m_map')); addpath(genpath('/media/fecg/FECG/gsw_matlab_v3'))

my1 = customcolormap_preset('red-white-blue');

my2 = customcolormap_preset('red-yellow-green');

file = '3901231_prof.nc';

lon = ncread(file,'LONGITUDE',1,108); 

lat = ncread(file,'LATITUDE',1,108); 

time = ncread(file,'JULD',1,108)+datenum('1950-01-01')-1; nt = length(time);

temp = ncread(file,'TEMP_ADJUSTED',[1 1],[inf 108]);

salt = ncread(file,'PSAL_ADJUSTED',[1 1],[inf 108]);

pres = ncread(file,'PRES_ADJUSTED',[1 1],[inf 108]);

depth = gsw_z_from_p(pres,lat);

[salt, in_ocean] = gsw_SA_from_SP(salt,pres,lon,lat);

temp = gsw_CT_from_t(salt,temp,pres);

mlp = zeros(length(time),1);

for i = 1:length(time)
  [mlp(i), qe, imf] = get_mld(depth(:,i),temp(:,i));
end

rho = gsw_rho(salt,temp,pres);

[N2, p_mid] = gsw_Nsquared(salt,temp,pres,repmat(lat,[1 1023])'); mdepth = gsw_z_from_p(p_mid,lat);

spic0 = gsw_spiciness0(salt,temp);
spic1 = gsw_spiciness1(salt,temp);

clear salt temp pres 

close all; figure('units','normalized','Position',[0.1 0.1 0.7 0.5]);
subplot(4,5,[10 15])
m_proj('miller','lat',[-7 -2],'lon',[-84 -79]); hold on
m_grid('tickdir','out','linewi',2); hold on
m_plot(lon(1),lat(1),'o','MarkerSize',8,'MarkerEdgeColor','g','MarkerFaceColor','g');
m_plot(lon(end),lat(end),'o','MarkerSize',8,'MarkerEdgeColor','b','MarkerFaceColor','b');
m_gshhs_h('patch',[0 0 0]); title({'ARGO 3901231','11-03-16 -> 25-12-18'})

vidObj = VideoWriter('argo_CT_vs_SA.avi');
vidObj.Quality = 100;
vidObj.FrameRate = 10;
open(vidObj);


for i = 2:length(time)
  subplot(4,5,[10 15])
  m_plot(lon(1:i),lat(1:i),'k'); title({'ARGO 3901231',datestr(time(i))})

  subplot(4,5,[1 2 3 4 6 7 8 9])
  pcolor(repmat(time(1:i),[1 1023])',depth(:,1:i),temp(:,1:i)); hold on; shading interp; colormap jet
  contour(repmat(time(1:i),[1 1023])',depth(:,1:i),temp(:,1:i),[14 16 18 20 22 24 26 28 30],'k','showtext','on'); 
  plot(time(1:i),mlp(1:i),'color','r','linewidth',3)
  datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-150 0]); caxis([14 28]); title('Conservative temperature [14 28]')

  subplot(4,5,[11 12 13 14 16 17 18 19])
  pcolor(repmat(time(1:i),[1 1023])',depth(:,1:i),salt(:,1:i)); hold on; shading interp; colormap jet
  contour(repmat(time(1:i),[1 1023])',depth(:,1:i),salt(:,1:i),[34:0.2:37],'k','showtext','on'); 
  plot(time(1:i),mlp(1:i),'color','r','linewidth',3)
  datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-150 0]); caxis([34.3 36]); title('Salinity absolute [34.3 36]')

   F = getframe(gcf);
   writeVideo(vidObj,F.cdata);
end
close(gcf)

close(vidObj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all; figure('units','normalized','Position',[0.1 0.1 0.7 0.5]);
subplot(4,5,[10 15])
m_proj('miller','lat',[-7 -2],'lon',[-84 -79]); hold on
m_grid('tickdir','out','linewi',2); hold on
m_plot(lon(1),lat(1),'o','MarkerSize',8,'MarkerEdgeColor','g','MarkerFaceColor','g');
m_plot(lon(end),lat(end),'o','MarkerSize',8,'MarkerEdgeColor','b','MarkerFaceColor','b');
m_gshhs_h('patch',[0 0 0]); title({'ARGO 3901231','11-03-16 -> 25-12-18'})

vidObj = VideoWriter('argo_CT_vs_SA.avi');
vidObj.Quality = 100;
vidObj.FrameRate = 10;
open(vidObj);

for i = 2:length(time)
  subplot(4,5,[10 15])
  m_plot(lon(1:i),lat(1:i),'k'); title({'ARGO 3901231',datestr(time(i))})

  ax(1) = subplot(4,5,[1 2 3 4 6 7 8 9]);
  pcolor(repmat(time(1:i),[1 1022])',mdepth(:,1:i),N2(:,1:i)); hold on; shading interp; colormap(ax(1),my1)
%  contour(repmat(time(1:i),[1 1022])',mdepth(:,1:i),N2(:,1:i),[-1:0.25:1]*4e-3,'k','showtext','on'); 
  plot(time(1:i),mlp(1:i),'color','r','linewidth',3)
  datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-150 0]); caxis([-1 1]*1.5e-3); title('Bouyancy freq [-1 1]x1.5e^{-3}')

  ax(2) = subplot(4,5,[11 12 13 14 16 17 18 19]);
  pcolor(repmat(time(1:i),[1 1023])',depth(:,1:i),rho(:,1:i)); hold on; shading interp; colormap(ax(2),jet)
  contour(repmat(time(1:i),[1 1023])',depth(:,1:i),rho(:,1:i),[1020:1030],'k','showtext','on'); 
  plot(time(1:i),mlp(1:i),'color','r','linewidth',3)
  datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-150 0]); caxis([1020 1030]); title('in-situ density  [1020 1030]')

   F = getframe(gcf);
   writeVideo(vidObj,F.cdata);
end
close(gcf)

close(vidObj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all; figure('units','normalized','Position',[0.1 0.1 0.7 0.5]);
subplot(4,5,[10 15])
m_proj('miller','lat',[-7 -2],'lon',[-84 -79]); hold on
m_grid('tickdir','out','linewi',2); hold on
m_plot(lon(1),lat(1),'o','MarkerSize',8,'MarkerEdgeColor','g','MarkerFaceColor','g');
m_plot(lon(end),lat(end),'o','MarkerSize',8,'MarkerEdgeColor','b','MarkerFaceColor','b');
m_gshhs_h('patch',[0 0 0]); title({'ARGO 3901231','11-03-16 -> 25-12-18'})

vidObj = VideoWriter('argo_rho_vs_pi.avi');
vidObj.Quality = 100;
vidObj.FrameRate = 10;
open(vidObj);

for i = 2:length(time)
  subplot(4,5,[10 15])
  m_plot(lon(1:i),lat(1:i),'k'); title({'ARGO 3901231',datestr(time(i))})

  ax(1) = subplot(4,5,[1 2 3 4 6 7 8 9]);
  pcolor(repmat(time(1:i),[1 1023])',depth(:,1:i),spic0(:,1:i)); hold on; shading interp; colormap(ax(1),my1)
  contour(repmat(time(1:i),[1 1023])',depth(:,1:i),spic0(:,1:i),[-2:0.5:8],'k','showtext','on'); 
  plot(time(1:i),mlp(1:i),'color','r','linewidth',2)
  datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-150 0]); caxis([-0.5 6]); title('\pi')

  ax(2) = subplot(4,5,[11 12 13 14 16 17 18 19]);
  pcolor(repmat(time(1:i),[1 1023])',depth(:,1:i),rho(:,1:i)); hold on; shading interp; colormap(ax(2),jet)
  contour(repmat(time(1:i),[1 1023])',depth(:,1:i),rho(:,1:i),[1020:1030],'k','showtext','on'); 
  plot(time(1:i),mlp(1:i),'color','r','linewidth',3)
  datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-150 0]); caxis([1020 1030]); title('in-situ density  [1020 1030]')

   F = getframe(gcf);
   writeVideo(vidObj,F.cdata);
end
close(gcf)

close(vidObj);




