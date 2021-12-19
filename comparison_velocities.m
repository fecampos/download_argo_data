clear all; close all; clc;

addpath(genpath('/home/fecg/Desktop/Roms/m_map')); addpath(genpath('/media/fecg/FECG/gsw_matlab_v3'))

my2 = customcolormap_preset('red-white-blue');

file = '3901231_prof.nc';

lon = ncread(file,'LONGITUDE',2,107); 

lat = ncread(file,'LATITUDE',2,107); 

time = ncread(file,'JULD',2,107)+datenum('1950-01-01')-1; nt = length(time);

temp_argo = ncread(file,'TEMP_ADJUSTED',[1 2],[inf 107]);

salt1 = ncread(file,'PSAL_ADJUSTED',[1 2],[inf 107]);

depth1 = ncread(file,'PRES_ADJUSTED',[1 2],[inf 107]);

temp_argo = gsw_pt_from_t(salt1,temp_argo,depth1,0);

h=gsw_z_from_p(depth1,lat); mld_argo = zeros(length(time),1);

temp_cow4 = squeeze(ncread('3901231_prof_cow4.nc','temp'));
w_cow4 = squeeze(ncread('argo_profile_w_cow4.nc','wo'));
u_cow4 = squeeze(ncread('argo_profile_u_cow4.nc','uo'));
v_cow4 = squeeze(ncread('argo_profile_v_cow4.nc','vo'));

h2 = ncread('3901231_prof_cow4.nc','depth'); mld_cow4 = zeros(length(time),1); h2 = repmat(-h2,[1 107]);


for i = 1:length(time)
  [mld_cow4(i), re, img] = get_mld(h2(:,i),temp_cow4(:,i));
end

i = 107
close all; figure('units','normalized','Position',[0.1 0.1 0.8 0.6]);
subplot(6,5,[15 20])
m_proj('miller','lat',[-8 0],'lon',[-84 -78]); hold on
m_grid('tickdir','out','linewi',2); hold on
m_plot(lon(1),lat(1),'o','MarkerSize',8,'MarkerEdgeColor','g','MarkerFaceColor','g');
m_plot(lon(end),lat(end),'o','MarkerSize',8,'MarkerEdgeColor','b','MarkerFaceColor','b');
m_plot(lon,lat,'k');
m_gshhs_h('patch',[0 0 0]); title({'ARGO 3901231','11-03-16 -> 25-12-18'})

subplot(6,5,[1 2 3 4 6 7 8 9])
pcolor(repmat(time(1:i),[1 51])',h2(:,1:i),w_cow4(:,1:i)); hold on; shading interp; colormap(my2)
plot(time(1:i),mld_cow4(1:i),'color','k','linewidth',2)
datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-100 0]); caxis([-1 1]*1e-4);  title('vert vel COW4 [-1 1]x1e^{-4}','fontweight','bold')

subplot(6,5,[11 12 13 14 16 17 18 19])
pcolor(repmat(time(1:i),[1 51])',h2(:,1:i),u_cow4(:,1:i)); hold on; shading interp; colormap(my2)
plot(time(1:i),mld_cow4(1:i),'color','k','linewidth',2)
datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-100 0]); caxis([-1 1]*0.5);  title('zonal vel COW4 [-0.5 0.5]','fontweight','bold')

subplot(6,5,[21 22 23 24 26 27 28 29])
pcolor(repmat(time(1:i),[1 51])',h2(:,1:i),v_cow4(:,1:i)); hold on; shading interp; colormap(my2)
plot(time(1:i),mld_cow4(1:i),'color','k','linewidth',2)
datetick('x','yyyy'); xlim([time(1) time(end)]); ylim([-100 0]); caxis([-1 1]*0.5);  title('meridional vel COW4 [-0.5 0.5]','fontweight','bold')

set(gcf,'Color','white','Renderer','zbuffer')
set(gca,'Color','white','XColor','black', 'YColor','black')
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0.3 0 22.0 12.0]); 
set(gcf,'InvertHardcopy','off'); 
print('-dpng','-r300',['comparison_vel.png']); 


