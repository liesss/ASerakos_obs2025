load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"       ; loading our libraries...
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

data_sour = (/"cru","cru","noaa-cires","noaa-cires","noaa-cires"/)
data_sour2 = (/"CRU TS4.0","CRU TS4.0","NOAA-CIRES V2c","NOAA-CIRES V2c","NOAA-CIRES V2c"/)
var_short = (/"precip","temp","Z500","V850","U"/)
var_long = (/"Precipitation Anomalies (mm/day)","Near-Surface Temp Anomalies (~S~o~N~C)","500hPa Geopotential Height Anomalies (m)","850hPa Meridional Winds (m/s)"/)

var = 2 ;0=precip 1=temp 2=Z 3=V 4=U

if (var.eq.0.or.var.eq.1) then
    num_end = 114
    year_end = 2015
else
    num_end = 113
    year_end = 2014
end if

;--------- LOAD IN PRECIP FILE ------------
if (var.eq.0) then
    precip_file = addfile("/Volumes/data2/ASerakos/data/obs_data/precip/cru_ts4.00.1901.2015.pre.dat.nc","r")
    precip_251 = precip_file->pre ;---> jan 1901 - dec 2015

    precip_25 = precip_251 /30
    copy_VarMeta(precip_251,precip_25)
    precip_25@units = "mm/day"
else if (var.eq.1) then
    precip_file = addfile("/Volumes/data2/ASerakos/data/obs_data/temp/cru_ts4.00.1901.2015.tmp.dat.nc","r")
    precip_25 = precip_file->tmp ;---> jan 1901 - dec 2015
else if (var.eq.2) then
    precip_file = addfile("/Volumes/data2/ASerakos/data/obs_data/geopht/geopht.nc","r")
    precip_25 = precip_file->hgt(600:1967,10,:,:) ;---> Z500 jan 1901 - dec 2014
else if (var.eq.3) then
    precip_file = addfile("/Volumes/data2/ASerakos/data/obs_data/wind/vwnd.mon.mean.nc","r")
    precip_25 = precip_file->vwnd(600:1967,3,:,:) ;---> V850 jan 1901 - dec 2014
else
    precip_file = addfile("/Volumes/data2/ASerakos/data/obs_data/wind/uwnd.mon.mean.nc","r")
    precip_25 = precip_file->uwnd(600:1967,:,:,:) ;---> jan 1901 - dec 2014
end if
end if
end if
end if

printVarSummary(precip_25)
;return

;--------- LOAD IN INDEX FILES -------------
year_file = addfile("/Volumes/data2/ASerakos/data/PNA_data/pna_djfavg_1901-2017.nc","r")
pna_file = addfile("/Volumes/data2/ASerakos/data/PNA_data/pna_djfavg_1901-2017.nc","r")
nao_file = addfile("/Volumes/data2/ASerakos/data/NAO_data/nao_djfavg_1901-2017.nc","r")
nam_file = addfile("/Volumes/data2/ASerakos/data/NAM_data/nam_djfavg_1901-2017.nc","r")
amo_file = addfile("/Volumes/data2/ASerakos/data/AMO_data/amo_djfavg_1901-2017.nc","r")
enso_file = addfile("/Volumes/data2/ASerakos/data/enso_data/enso_djfavg_1901-2017.nc","r")

;index_array = new((/462,462,462/),float)
;index_array(:,0,0) = year_file(348:809)
;index_array(0,:,0) = mon_file(348:809)
;index_array(0,0,:) = pna_file(348:809)

year = year_file->year(0:num_end)   ;0:114 --> 1901-2015
                                ;0:113 --> 1901-2014
pna = pna_file->pna_djf(0:num_end)
nao = nao_file->nao_djf(0:num_end)
nam = nam_file->nam_djf(0:num_end)
amo = amo_file->amo_djf(0:num_end)
enso = enso_file->enso_djf(0:num_end)

;-------------------------------------------

precip_djf = month_to_season(precip_25,"DJF")
;precip_djf = precip_25(11::12,:,:)
;print(precip_djf(0,50,100))
printVarSummary(precip_djf)

precip_djf_anom = dim_rmvmean_n_Wrap(precip_djf,0)

precip_25_avg = dim_avg_n_Wrap(precip_25,0)

;print(precip_25_avg&lat)

;printVarSummary(precip_25_avg)

;-------------------------------------------
pna_mean = avg(pna)
pna_sd = stddev(pna)
p_pna = pna_mean + pna_sd
n_pna = pna_mean - pna_sd

;print(p_pna)
;print(n_pna)

nao_mean = avg(nao)
nao_sd = stddev(nao)
p_nao = nao_mean + nao_sd
n_nao = nao_mean - nao_sd

nam_mean = avg(nam)
nam_sd = stddev(nam)
p_nam = nam_mean + nam_sd
n_nam = nam_mean - nam_sd

;print(p_nao)
;print(n_nao)

amo_mean = avg(amo)
amo_sd = stddev(amo)
p_amo = amo_mean + amo_sd
n_amo = amo_mean - amo_sd

;print(p_amo)
;print(n_amo)

enso_mean = avg(enso)
enso_sd = stddev(enso)
p_enso = enso_mean + enso_sd
n_enso = enso_mean - enso_sd

;print(p_enso)
;print(n_enso)

pos_val = new(4,float)
pos_val(0) = p_pna
pos_val(1) = p_nao
pos_val(2) = p_amo
pos_val(3) = p_enso

neg_val = new(4,float)
neg_val(0) = n_pna
neg_val(1) = n_nao
neg_val(2) = n_amo
neg_val(3) = n_enso

;-------------------------------------------
hn := new(num_end+1,float)

ind2 = amo.gt.0 ;p_pna
;ind2 = nao.gt.0 ;p_nao
;ind2 = nam.gt.0
;ind5 = amo.lt.0 ;p_amo
ind5 = enso.lt.0    ;p_enso

;hn := where(ind1.eq.True.and.ind2.eq.True.and.ind4.eq.True.and.ind5.eq.True,pna,hn@_FillValue)
;hn := where(ind2.eq.True.and.ind4.eq.True.and.ind5.eq.True,pna,hn@_FillValue)
;hn := where(ind1.eq.True.and.ind4.eq.True.and.ind5.eq.True,pna,hn@_FillValue)
;hn := where(ind2.eq.True.and.ind5.eq.True,pna,hn@_FillValue)
hn := where(ind2.eq.True,pna,hn@_FillValue)
index_values := get1Dindex(hn,pna)
pos_ind := ind(hn)
num_val := num(hn)

print(pos_ind)
print(num_val)

pos_data = precip_djf_anom(pos_ind,:,:)
pos_years = floattointeger(year(pos_ind))
print(pos_years)
printVarSummary(pos_years)
printVarSummary(pos_data)
;return

;-------------------------------------------
hnn := new(num_end+1,float)

hnn := where(ind2.eq.False,pna,hnn@_FillValue)
index_values := get1Dindex(hnn,pna)
pos_ind_n := ind(hnn)
num_val_n := num(hnn)

print(pos_ind_n)
print(num_val_n)

pos_data_n = precip_djf_anom(pos_ind_n,:,:)
pos_years_n = floattointeger(year(pos_ind_n))
print(pos_years_n)
printVarSummary(pos_years_n)
printVarSummary(pos_data_n)

;-------------------------------------------

;weight_name = (/"PNA","NAM","AMO","ENSO"/)
weight_name = (/"+AMO","-AMO"/)

wks = gsn_open_wks("pdf","/Volumes/data2/ASerakos/plots/obs_plots/"+var_short(var)+"_plots/"+data_sour(var)+"_"+var_short(var)+"_1901-"+year_end+"_djf_+amo-amo_weighted_comp")
plot1 = new(2,graphic)
plot2 = new(2,graphic)

n=0
do x=2,3
    if (x.eq.0) then
        dataindex = pna
    else if (x.eq.1) then
        dataindex = nam
    else if (x.eq.2) then
        dataindex = amo
    else
        dataindex = amo
    end if
    end if
    end if
;------------------------------------------- CREATING WEIGHTS ----
if (var.eq.0.or.var.eq.1) then
    weig_data := new((/num_val,360,720/),float)
else
    weig_data := new((/num_val,91,180/),float)
end if
printVarSummary(weig_data)
print(pos_ind)

copy_VarMeta(pos_data,weig_data)

do w=0,num_val-1
;print(dataindex(pos_ind))
avg_pna := avg(dataindex(pos_ind))
sd_pna := stddev(dataindex(pos_ind))
;print(avg_pna)

w_pna := (dataindex(pos_ind)/avg_pna)
;print(w_pna)
cc=avg(w_pna)
;print(cc)

;print(num(pos_ind))
weig_data(w,:,:) = w_pna(w) * pos_data(w,:,:)
end do

weig_data2 = dim_avg_n_Wrap(weig_data,0)
;printVarSummary(weig_data2)

;-----------------------------------------------------------------------------

if (var.eq.0.or.var.eq.1) then
    weig_data_n := new((/num_val_n,360,720/),float)
else
    weig_data_n := new((/num_val_n,91,180/),float)
end if
printVarSummary(weig_data_n)
print(pos_ind_n)

copy_VarMeta(pos_data_n,weig_data_n)

do w=0,num_val_n-1
;print(dataindex(pos_ind))
avg_pna_n := avg(dataindex(pos_ind_n))
sd_pna_n := stddev(dataindex(pos_ind_n))
;print(avg_pna)

w_pna_n := (dataindex(pos_ind_n)/avg_pna_n)
;print(w_pna)
cc_n=avg(w_pna_n)
;print(cc)

;print(num(pos_ind))
weig_data_n(w,:,:) = w_pna_n(w) * pos_data_n(w,:,:)
end do

;weig_data2_n = dim_avg_n_Wrap(weig_data_n,0)
;printVarSummary(weig_data2)

;-----------------------------------------------------------------------------

if (x.eq.2) then
    weig_data2 = dim_avg_n_Wrap(weig_data,0)
;    weig_data2 = dim_avg_n_Wrap(pos_data,0)
else if (x.eq.3) then
   weig_data2 = dim_avg_n_Wrap(weig_data_n,0)
;    weig_data2 = dim_avg_n_Wrap(pos_data_n,0)
end if
end if

;-----------------------------------------------------------------------------

;----------------------- resources for Z contours --------------------------
res3 = True
res3@cnLinesOn = True
res3@cnLevelSpacingF = 7
res3@cnLineLabelsOn      = False       ; do not draw contour labels
res3@cnInfoLabelOn = False
res3@gsnLeftString = ""
res3@gsnRightString = ""
res3@gsnDraw             = False       ; Do not draw plot
res3@gsnFrame            = False       ; Do not advance frome

;-----------------------------------------------------------------------------

cres = True

cres@gsnScale = True   ; forcing x/y axes labels to the same size
cres@tiMainFont = 21
cres@tiMainFontHeightF = 0.015

cres@sfXCStartV := min(precip_25_avg&lon)
cres@sfXCEndV := max(precip_25_avg&lon)

res3@sfXCStartV := min(precip_25_avg&lon)
res3@sfXCEndV := max(precip_25_avg&lon)

if (var.eq.0.or.var.eq.1) then
    cres@sfYCStartV := min(precip_25_avg&lat)
    cres@sfYCEndV := max(precip_25_avg&lat)
else
    cres@sfYCStartV := max(precip_25_avg&lat)
    cres@sfYCEndV := min(precip_25_avg&lat)

    res3@sfYCStartV := max(precip_25_avg&lat)
    res3@sfYCEndV := min(precip_25_avg&lat)
end if

cres@pmTickMarkDisplayMode = "Always"

;cres@tiMainString = ""

cres@cnMonoLineColor = False

cres@cnFillOn = True
;cres@cnMonoFillPattern = True
;cres@cnMonoFillColor = False
cres@cnLinesOn            = False    ; turn off contour lines

cres@cnLineLabelsOn = False
cres@cnInfoLabelOn = False

cres@mpGridAndLimbDrawOrder = "PreDraw"
;cres@pmLabelBarDisplayMode = "Always"
;cres@pmLabelBarSide = "Bottom"
;cres@lbOrientation = "Horizontal"
cres@lbTitleFont = 21
cres@lbPerimOn = False
cres@lbTitleFontHeightF = 0.015
;cres@lbTitlePosition = "bottom"
cres@lbLabelAngleF    =    45                 ; angle labels
cres@pmLabelBarOrthogonalPosF = .10           ; move whole thing down
;cres@gsnStringFontHeightF = 0.02

cres@gsnAddCyclic = False
cres@mpCenterLonF = 180

;cres@cnLevelSpacingF := 2			; set the interval between contours

cres@gsnMaximize = True

cres@gsnDraw             = False           ; don't draw
cres@gsnFrame            = False           ; don't advance frame

cres@lbLabelBarOn = False
cres@cnLevelSelectionMode = "ExplicitLevels"

;cres@tiMainString = "DJF " + (pos_years(u) -1) + "-" + pos_years(u) + "         " + valuez(0,i) + ", " + valuez(1,i) + ", " + valuez(2,i) + ", " + valuez(3,i)

if (var.eq.0) then
;   cres@cnLevels := (/-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10/)
    cres@cnLevels := (/-1.5,-1.35,-1.2,-1.05,-0.9,-0.75,-0.6,-0.45,-0.3,-0.15,0,0.15,0.3,0.45,0.6,0.75,0.9,1.05,1.2,1.35,1.5/)
    cres@cnFillColors :=(/65,62,60,57,55,52,49,46,42,37,34,27,24,22,19,17,15,13,9,6,4,2/)
else if (var.eq.1) then
    cres@cnLevels := (/-3.6,-3.3,-3,-2.7,-2.4,-2.1,-1.8,-1.5,-1.2,-0.9,-0.6,-0.3,0,0.3,0.6,0.9,1.2,1.5,1.8,2.1,2.4,2.7,3,3.3,3.6/)
    cres@cnFillColors :=(/2,3,4,6,8,9,11,13,15,17,19,23,27,34,37,42,46,48,50,52,54,56,58,60,62,65/)
else if (var.eq.2) then
    cres@cnLevels := (/-85,-77,-70,-63,-56,-49,-42,-35,-28,-21,-14,-7,0,7,14,21,28,35,42,49,56,63,70,77,85/)
;    cres@cnLevels := (/-60,-55,-50,-45,-40,-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40,45,50,55,60/)
;    cres@cnLevels := (/-48,-44,-40,-36,-32,-28,-24,-20,-16,-12,-8,-4,0,4,8,12,16,20,24,28,32,36,40,44,48/)
    cres@cnFillColors :=(/2,3,4,6,8,9,11,13,15,17,19,23,27,34,37,42,46,48,50,52,54,56,58,60,62,65/)
else if (var.eq.3) then
;    cres@cnLevels := (/-2.4,-2.2,-2.0,-1.8,-1.6,-1.4,-1.2,-1.0,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.2,2.4/)
    cres@cnLevels := (/-3.6,-3.3,-3.0,-2.7,-2.4,-2.1,-1.8,-1.5,-1.2,-0.9,-0.6,-0.3,0,0.3,0.6,0.9,1.2,1.5,1.8,2.1,2.4,2.7,3.0,3.3,3.6/)
    cres@cnFillColors :=(/2,3,4,6,8,9,11,13,15,17,19,23,27,34,37,42,46,48,50,52,54,56,58,60,62,65/)
end if
end if
end if
end if
gsn_define_colormap(wks,"cmp_b2r")

cres@gsnCenterString = weight_name(n)
if (x.eq.2) then
    cres@gsnRightString := "Values = "+num_val+""
    cres@gsnLeftString := "Avg = "+decimalPlaces(avg_pna,2,False)+", SD = "+decimalPlaces(sd_pna,2,False)+""
else if (x.eq.3) then
    cres@gsnRightString := "Values = "+num_val_n+""
    cres@gsnLeftString := "Avg = "+decimalPlaces(avg_pna_n,2,False)+", SD = "+decimalPlaces(sd_pna_n,2,False)+""
end if
end if

plot1(n) = gsn_csm_contour_map(wks,weig_data2(:,:),cres)
if (var.eq.2) then
    plot1a = gsn_csm_contour(wks,weig_data2(:,:),res3)
    overlay(plot1(n),plot1a)
    delete (plot1a)
end if

printVarSummary(precip_25_avg)

if (var.eq.0.or.var.eq.1) then
    usa_precip_coord = precip_25_avg({15.25:88.75},{-179.75:-50.75})
    usa_precip := weig_data2({15.25:88.75},{-179.75:-50.75})
else
    usa_precip_coord = precip_25_avg({14:88},{180:316})
    usa_precip := weig_data2({14:88},{180:316})

;    usa_precip_coord = precip_25_avg({14:88},{-180:-50})
;   usa_precip := weig_data2({14:88},{-180:-50})
end if

res3@sfXCStartV := min(usa_precip_coord&lon)
res3@sfXCEndV := max(usa_precip_coord&lon)
res3@sfYCStartV := min(usa_precip_coord&lat)
res3@sfYCEndV := max(usa_precip_coord&lat)

cres@sfXCStartV := min(usa_precip_coord&lon)
cres@sfXCEndV := max(usa_precip_coord&lon)
cres@sfYCStartV := min(usa_precip_coord&lat)
cres@sfYCEndV := max(usa_precip_coord&lat)

if (var.eq.0.or.var.eq.1) then
    cres@mpLimitMode = "LatLon"
    cres@mpMaxLatF = 88.75
    cres@mpMinLatF = 15.25
    cres@mpMaxLonF = -50.75    ;316
    cres@mpMinLonF = -179.75    ;183
else
    cres@mpLimitMode = "LatLon"
    cres@mpMaxLatF = 88
    cres@mpMinLatF = 14
    cres@mpMaxLonF = 316    ;316
    cres@mpMinLonF = 180    ;183
end if


if (var.eq.0) then
;    cres@cnLevels := (/-3.0,-2.7,-2.4,-2.1,-1.8,-1.5,-1.2,-0.9,-0.6,-0.3,0,0.3,0.6,0.9,1.2,1.5,1.8,2.1,2.4,2.7,3.0/)
    cres@cnLevels := (/-1.5,-1.35,-1.2,-1.05,-0.9,-0.75,-0.6,-0.45,-0.3,-0.15,0,0.15,0.3,0.45,0.6,0.75,0.9,1.05,1.2,1.35,1.5/)
    cres@cnFillColors :=(/65,62,60,57,55,52,49,46,42,37,34,27,24,22,19,17,15,13,9,6,4,2/)
else if (var.eq.1) then
    cres@cnLevels := (/-3.6,-3.3,-3,-2.7,-2.4,-2.1,-1.8,-1.5,-1.2,-0.9,-0.6,-0.3,0,0.3,0.6,0.9,1.2,1.5,1.8,2.1,2.4,2.7,3,3.3,3.6/)
    cres@cnFillColors :=(/2,3,4,6,8,9,11,13,15,17,19,23,27,34,37,42,46,48,50,52,54,56,58,60,62,65/)
else if (var.eq.2) then
    cres@cnLevels := (/-85,-77,-70,-63,-56,-49,-42,-35,-28,-21,-14,-7,0,7,14,21,28,35,42,49,56,63,70,77,85/)
;    cres@cnLevels := (/-60,-55,-50,-45,-40,-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40,45,50,55,60/)
;    cres@cnLevels := (/-48,-44,-40,-36,-32,-28,-24,-20,-16,-12,-8,-4,0,4,8,12,16,20,24,28,32,36,40,44,48/)
    cres@cnFillColors :=(/2,3,4,6,8,9,11,13,15,17,19,23,27,34,37,42,46,48,50,52,54,56,58,60,62,65/)
else if (var.eq.3) then
;    cres@cnLevels := (/-2.4,-2.2,-2.0,-1.8,-1.6,-1.4,-1.2,-1.0,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.2,2.4/)
    cres@cnLevels := (/-3.6,-3.3,-3.0,-2.7,-2.4,-2.1,-1.8,-1.5,-1.2,-0.9,-0.6,-0.3,0,0.3,0.6,0.9,1.2,1.5,1.8,2.1,2.4,2.7,3.0,3.3,3.6/)
    cres@cnFillColors :=(/2,3,4,6,8,9,11,13,15,17,19,23,27,34,37,42,46,48,50,52,54,56,58,60,62,65/)
end if
end if
end if
end if
gsn_define_colormap(wks,"cmp_b2r")

cres@gsnCenterString = weight_name(n)

if (x.eq.2) then
    cres@gsnRightString := "Values = "+num_val+""
    cres@gsnLeftString := "Avg = "+decimalPlaces(avg_pna,2,False)+", SD = "+decimalPlaces(sd_pna,2,False)+""
else if (x.eq.3) then
    cres@gsnRightString := "Values = "+num_val_n+""
    cres@gsnLeftString := "Avg = "+decimalPlaces(avg_pna_n,2,False)+", SD = "+decimalPlaces(sd_pna_n,2,False)+""
end if
end if

plot2(n) = gsn_csm_contour_map(wks,usa_precip(:,:),cres)
if (var.eq.2) then
    plot2a = gsn_csm_contour(wks,usa_precip(:,:),res3)
    overlay(plot2(n),plot2a)
    delete(plot2a)
end if

n=n+1
delete(weig_data2)
delete(cres@mpLimitMode)
delete(cres@mpMaxLatF)
delete(cres@mpMinLatF)
delete(cres@mpMaxLonF)
delete(cres@mpMinLonF)

end do

pres = True
pres@txFontHeightF = 0.014
pres@gsnPanelLabelBar = True
pres@lbOrientation = "horizontal"
pres@gsnMaximize = True
pres@lbTitleFont = 21
pres@lbPerimOn = False
pres@lbTitleFontHeightF = 0.015
;pres@pmLabelBarOrthogonalPosF = -.01           ; move whole thing down
pres@mpPerimOn   = False

pres@txString := "DJF "+var_long(var)+", Weighted Composites, ~C~           "+data_sour2(var)+" (1901-"+year_end+"),    +AMO -AMO"
pres@gsnPaperOrientation = "portrait"
gsn_panel(wks,plot1,(/2,1/),pres)
pres@gsnPaperOrientation = "portrait"
gsn_panel(wks,plot2,(/2,1/),pres)


end






