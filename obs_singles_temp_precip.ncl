load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"       ; loading our libraries...
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

season = "DJF"  ;"DJF" or "JJA"
num_end = 113

wks = gsn_open_wks("pdf","/Volumes/data2/ASerakos/plots/obs_plots/"+season+"_singles_temp_precip")

do i=0,1

;----- LOAD IN DATA ------

if (i.eq.0) then
    plot = new(8,graphic)
    precip_file := addfile("/Volumes/data2/ASerakos/data/obs_data/temp/cru_ts4.00.1901.2015.tmp.dat.nc","r")
    precip_25 := precip_file->tmp(0:1367,:,:) ;---> jan 1901 - dec 2015
    printVarSummary(precip_25)

else if (i.eq.1) then
    plot2 = new(8,graphic)
    precip_file := addfile("/Volumes/data2/ASerakos/data/obs_data/precip/cru_ts4.00.1901.2015.pre.dat.nc","r")
    precip_251 := precip_file->pre ;---> jan 1901 - dec 2015

    precip_25 := precip_251 /30
    copy_VarMeta(precip_251,precip_25)
    precip_25@units := "mm/day"
    printVarSummary(precip_25)

else
    plot = new(8,graphic)
    precip_file := addfile("/Volumes/data2/ASerakos/data/obs_data/geopht/geopht.nc","r")
    precip_25 := precip_file->hgt(600:1967,10,:,:) ;---> Z500 jan 1901 - dec 2014
    printVarSummary(precip_25)

end if
end if


if (season.eq."DJF") then
    pna_file := addfile("/Volumes/data2/ASerakos/data/PNA_data/pna_djfavg_1901-2017.nc","r")
    nam_file := addfile("/Volumes/data2/ASerakos/data/NAM_data/nam_djfavg_1901-2017.nc","r")
    amo_file := addfile("/Volumes/data2/ASerakos/data/AMO_data/amo_djfavg_1901-2017.nc","r")
    enso_file := addfile("/Volumes/data2/ASerakos/data/enso_data/enso_djfavg_1901-2017.nc","r")

    pna := pna_file->pna_djf(0:num_end)
    nam := nam_file->nam_djf(0:num_end)
    amo := amo_file->amo_djf(0:num_end)
    enso := enso_file->enso_djf(0:num_end)

    precip_djf := month_to_season(precip_25,"DJF")

else
    pna_file := addfile("/Volumes/data2/ASerakos/data/PNA_data/pna_jjaavg_1901-2016.nc","r")
    nam_file := addfile("/Volumes/data2/ASerakos/data/NAM_data/nam_jjaavg_1901-2016.nc","r")
    amo_file := addfile("/Volumes/data2/ASerakos/data/AMO_data/amo_jjaavg_1901-2016.nc","r")
    enso_file := addfile("/Volumes/data2/ASerakos/data/enso_data/enso_jjaavg_1901-2016.nc","r")

    pna := pna_file->pna_jja(0:num_end)
    nam := nam_file->nam_jja(0:num_end)
    amo := amo_file->amo_jja(0:num_end)
    enso := enso_file->enso_jja(0:num_end)

    precip_djf := month_to_season(precip_25,"JJA")

end if

name_var = (/"+E","-E","+A","-A","+P","-P","+N","-N"/)

do t=0,7
hn := new(num_end+1,float)

if (t.eq.0) then
    ind1 = enso.gt.0
    hn := where(ind1.eq.True,pna,hn@_FillValue)
else if (t.eq.1) then
    ind1 = enso.lt.0
    hn := where(ind1.eq.True,pna,hn@_FillValue)
else if (t.eq.2) then
    ind1 = amo.gt.0
    hn := where(ind1.eq.True,pna,hn@_FillValue)
else if (t.eq.3) then
    ind1 = amo.lt.0
    hn := where(ind1.eq.True,pna,hn@_FillValue)
else if (t.eq.4) then
    ind1 = pna.gt.0
    hn := where(ind1.eq.True,pna,hn@_FillValue)
else if (t.eq.5) then
    ind1 = pna.lt.0
    hn := where(ind1.eq.True,pna,hn@_FillValue)
else if (t.eq.6) then
    ind1 = nam.gt.0
    hn := where(ind1.eq.True,pna,hn@_FillValue)
else if (t.eq.7) then
    ind1 = nam.lt.0
    hn := where(ind1.eq.True,pna,hn@_FillValue)
end if
end if
end if
end if
end if
end if
end if
end if

precip_djf_anom := dim_rmvmean_n_Wrap(precip_djf,0)

pos_ind := ind(hn)
num_val := num(hn)
print(num_val)

pos_data := precip_djf_anom(pos_ind,:,:)
pos_data_avg := dim_avg_n_Wrap(pos_data,0)

;------------------------------------------------------
res = True

;labeling axes
res@gsnScale = True   ; forcing x/y axes labels to the same size
res@tiMainFont = 21
res@tiMainFontHeightF = 0.005

res@gsnStringFontHeightF = 0.025

;res@trYReverse = True

; turning off the drawing of contours lines in one color
res@cnMonoLineColor = True

; defining color fill and pattern
res@cnFillOn = True
;res@cnMonoFillPattern = True
;res@cnMonoFillColor = False
;res@cnLinesOn            = False    ; turn off contour lines

res@gsnCenterString = name_var(t)
res@gsnRightString = "count = " + num_val
res@gsnLeftString = ""

;turn line labels and info label off
res@cnLineLabelsOn = False
res@cnInfoLabelOn = False

;label bar
res@lbTitleFont = 21
res@lbPerimOn = False
res@lbTitleFontHeightF = 0.015
;res@lbTitlePosition = "bottom"
res@lbLabelAngleF    =    45                 ; angle labels
res@pmLabelBarOrthogonalPosF = .10           ; move whole thing down


; changing settings to landscape
;res@gsnPaperOrientation = "auto"
;res@gsnMaximize = True

;removing white gap at 0
res@gsnAddCyclic = True

if (i.eq.2) then
    res@sfXCStartV := min(pos_data_avg&lon)
    res@sfXCEndV := max(pos_data_avg&lon)
    res@sfYCStartV := max(pos_data_avg&lat)
    res@sfYCEndV := min(pos_data_avg&lat)

    res@lbOrientation = "vertical"
    res@lbTitlePosition      = "Right"
    res@gsnPolar = "NH"
    res@mpProjection =  "Stereographic"
    res@mpPerimOn   = False
    res@mpMinLatF  = 10

else
    res@mpCenterLonF = 180

    res@cnLinesOn            = False    ; turn off contour lines
    res@mpLimitMode = "LatLon"
    res@mpMaxLatF = 88.75
    res@mpMinLatF = 15.25
    res@mpMaxLonF = -50.75    ;316
    res@mpMinLonF = -179.75    ;183

end if


res@gsnDraw             = False           ; don't draw
res@gsnFrame            = False           ; don't advance frame

res@lbLabelBarOn = False
res@cnLevelSelectionMode = "ExplicitLevels"

if (i.eq.0) then
    if (season.eq."DJF") then
        res@cnLevels := (/-3.6,-3.3,-3,-2.7,-2.4,-2.1,-1.8,-1.5,-1.2,-0.9,-0.6,-0.3,0,0.3,0.6,0.9,1.2,1.5,1.8,2.1,2.4,2.7,3,3.3,3.6/)
    else
        res@cnLevels := (/-1.8,-1.65,-1.5,-1.35,-1.2,-1.05,-0.9,-0.75,-0.6,-0.45,-0.3,-0.15,0,0.15,0.3,0.45,0.6,0.75,0.9,1.05,1.2,1.35,1.5,1.65,1.8/)
    end if
    res@cnFillColors :=(/2,3,4,6,8,9,11,13,15,17,19,23,27,34,37,42,46,48,50,52,54,56,58,60,62,65/)

else if (i.eq.1) then
    res@cnLevels := (/-1.5,-1.35,-1.2,-1.05,-0.9,-0.75,-0.6,-0.45,-0.3,-0.15,0,0.15,0.3,0.45,0.6,0.75,0.9,1.05,1.2,1.35,1.5/)
    res@cnFillColors :=(/65,62,60,57,55,52,49,46,42,37,34,27,24,22,19,17,15,13,9,6,4,2/)

else
    res@cnLevels := (/-84,-77,-70,-63,-56,-49,-42,-35,-28,-21,-14,-7,0,7,14,21,28,35,42,49,56,63,70,77,84/)
    res@cnFillColors :=(/2,3,4,6,8,9,11,13,15,17,19,23,27,34,37,42,46,48,50,52,54,56,58,60,62,65/)

end if
end if

gsn_define_colormap(wks,"cmp_b2r")

if (i.eq.0.or.i.eq.2) then
    plot(t) = gsn_csm_contour_map(wks,pos_data_avg(:,:),res)
    delete(res)
else
    plot2(t) = gsn_csm_contour_map(wks,pos_data_avg(:,:),res)
    delete(res)
end if

end do

pres2 = True

pres2@txFontHeightF = 0.014
pres2@gsnPanelLabelBar = True
;pres2@lbOrientation = "vertical"
pres2@gsnMaximize = True
pres2@lbOrientation = "Horizontal"
pres2@lbTitleFont = 21
pres2@lbPerimOn = False
pres2@lbTitleFontHeightF = 0.015
pres2@lbTitlePosition = "bottom"
pres2@lbLabelAngleF    =    45                 ; angle labels
pres2@lbLabelFontHeightF = 0.010
pres2@gsnFrame            = False      ; don't advance frame yet
pres2@gsnPaperOrientation = "landscape"

pres2@pmLabelBarOrthogonalPosF = -.0125           ; move whole thing down

if (i.eq.0) then
;    pres2@gsnPanelLeft = 0.255
    pres2@gsnPanelRight = 0.5
    gsn_panel(wks,plot,(/4,2/),pres2)
else if (i.eq.1) then
    pres2@gsnPanelLeft = 0.5
    ;pres2@gsnPanelRight = 0.255
    gsn_panel(wks,plot2,(/4,2/),pres2)
else
    gsn_panel(wks,plot,(/4,2/),pres2)
end if
end if

delete(pres2)


end do

frame(wks)      ; now advance frame for all plots




end





