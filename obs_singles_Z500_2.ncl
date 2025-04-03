load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"       ; loading our libraries...
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

season = "DJF"  ;"DJF" or "JJA"
num_end = 113

wks = gsn_open_wks("pdf","/Volumes/data2/ASerakos/plots/obs_plots/"+season+"_+NAM_Z500")

;----- LOAD IN DATA ------
plot = new(8,graphic)
precip_file := addfile("/Volumes/data2/ASerakos/data/obs_data/geopht/geopht.nc","r")
precip_25 := precip_file->hgt(600:1967,10,:,:) ;---> Z500 jan 1901 - dec 2014
printVarSummary(precip_25)

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

do t=6,6
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
res@gsnRightString = "n = " + num_val
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

res@mpCenterLonF = -90

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


;res@gsnDraw             = False           ; don't draw
;res@gsnFrame            = False           ; don't advance frame

;res@lbLabelBarOn = False
res@cnLevelSelectionMode = "ExplicitLevels"

if (season.eq."DJF") then
    res@cnLevels := (/-84,-77,-70,-63,-56,-49,-42,-35,-28,-21,-14,-7,0,7,14,21,28,35,42,49,56,63,70,77,84/)
    res@cnFillColors :=(/2,3,4,6,8,9,11,13,15,17,19,23,27,34,37,42,46,48,50,52,54,56,58,60,62,65/)
else
;    res@cnLevels := (/-72,-60,-54,-48,-42,-36,-30,-24,-18,-12,-6,0,6,12,18,24,30,36,42,48,54,60,72/)
;    res@cnLevels := (/-44,-40,-36,-32,-28,-24,-20,-16,-12,-8,-4,0,4,8,12,16,20,24,28,32,36,40,44/)
    res@cnLevels := (/-38.5,-35,-31.5,-28,-24.5,-21,-17.5,-14,-10.5,-7,-3.5,0,3.5,7,10.5,14,17.5,21,24.5,28,31.5,35,38.5/)
    res@cnFillColors :=(/3,4,6,8,9,11,13,15,17,19,23,27,34,37,42,46,48,50,52,54,56,58,60,62/)
end if

gsn_define_colormap(wks,"cmp_b2r")


plot(t) = gsn_csm_contour_map(wks,pos_data_avg(:,:),res)

end do

;pres2 = True

;pres2@txFontHeightF = 0.014
;pres2@gsnPanelLabelBar = True
;;pres2@lbOrientation = "vertical"
;pres2@gsnMaximize = True
;pres2@lbOrientation = "Horizontal"
;pres2@lbTitleFont = 21
;pres2@lbPerimOn = False
;pres2@lbTitleFontHeightF = 0.015
;pres2@lbTitlePosition = "bottom"
;pres2@lbLabelAngleF    =    45                 ; angle labels
;pres2@lbLabelFontHeightF = 0.010
;pres2@gsnFrame            = False      ; don't advance frame yet
;pres2@gsnPaperOrientation = "portrait"

;pres2@pmLabelBarOrthogonalPosF = -.0125           ; move whole thing down

;gsn_panel(wks,plot,(/2,4/),pres2)

;delete(pres2)
;frame(wks)      ; now advance frame for all plots


end

