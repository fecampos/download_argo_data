clear all; close all; clc;

addpath(genpath('/home/fecg/Desktop/Roms/m_map')); addpath(genpath('/media/fecg/FECG/gsw_matlab_v3'))

my2 = customcolormap_preset('red-yellow-blue');

file = '3901231_prof.nc';

lon = ncread(file,'LONGITUDE',2,108); 

lat = ncread(file,'LATITUDE',2,108); 

time = ncread(file,'JULD',2,108)+datenum('1950-01-01')-1; nt = length(time);

temp1 = ncread(file,'TEMP_ADJUSTED',[1 2],[inf 108]);

salt1 = ncread(file,'PSAL_ADJUSTED',[1 2],[inf 108]);

depth1 = ncread(file,'PRES_ADJUSTED',[1 2],[inf 108]);

temp=gsw_pt_from_t(salt1,temp1,depth1,0);

h=gsw_z_from_p(depth1,lat);
mld_argo = zeros(length(time),1);

for i = 1:length(time)
  [mld_argo(i), qe, imf] = get_mld(h(:,i),temp(:,i));
end


close all; figure('units','normalized','Position',[0.1 0.1 0.8 0.6]);
subplot(4,5,[10 15])
m_proj('miller','lat',[-8 0],'lon',[-84 -78]); hold on
m_grid('tickdir','out','linewi',2); hold on
m_plot(lon(1),lat(1),'o','MarkerSize',8,'MarkerEdgeColor','g','MarkerFaceColor','g');
m_plot(lon(end),lat(end),'o','MarkerSize',8,'MarkerEdgeColor','b','MarkerFaceColor','b');
m_gshhs_h('patch',[0 0 0]); title({'ARGO 3901231','11-03-16 -> 25-12-18'})

nFrames = 10;
vidObj = VideoWriter('argo_temp_salt.avi');
vidObj.Quality = 100;
vidObj.FrameRate = 10;
open(vidObj);

for i = 2:length(time)
  subplot(4,5,[10 15])
  m_plot(lon(1:i),lat(1:i),'k'); title({'ARGO 3901231',datestr(time(i))})

  subplot(4,5,[1 2 3 4 6 7 8 9])
  pcolor(repmat(time(1:i),[1 1023])',h(:,1:i),temp(:,1:i)); hold on; shading interp; colormap jet
  contour(repmat(time(1:i),[1 1023])',h(:,1:i),temp(:,1:i),[14 16 18 20 22 24 26 28 30],'k','showtext','on'); 
  plot(time(1:i),mld_argo(1:i),'color','r','linewidth',3)
  datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-150 0]); caxis([14 28]); title('ARGO temperature pot [14 28]')

  subplot(4,5,[11 12 13 14 16 17 18 19])
  pcolor(repmat(time(1:i),[1 1023])',h(:,1:i),salt1(:,1:i)); hold on; shading interp; colormap jet
  contour(repmat(time(1:i),[1 1023])',h(:,1:i),salt1(:,1:i),[34:0.2:37],'k','showtext','on'); 
  plot(time(1:i),mld_argo(1:i),'color','r','linewidth',3)
  datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-150 0]); caxis([34.3 36]); title('Practical salinity [34.3 36]')

   F = getframe(gcf);
   writeVideo(vidObj,F.cdata);
end
close(gcf)

close(vidObj);

%cb = colorbar; set(cb,'location','southoutside','position',[0.13 0.06 0.61 0.009]); cb.Title.String = '^{o}C'; cb.FontSize = 18; cb.FontWeight='bold';

set(gcf,'Color','white','Renderer','zbuffer')
set(gca,'Color','white','XColor','black', 'YColor','black')
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0.3 0 30.0 20.0]); % aqui cambiar
set(gcf,'InvertHardcopy','off'); 
print('-dpng','-r300',['argo-cow4-comparison_mld.png']); 






