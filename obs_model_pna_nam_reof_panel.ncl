load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"       ; loading our libraries...
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

season = "JJA"  ;"DJF" or "JJA"
pattern = "PNA" ;"PNA" or "NAM"
combo = (/"control","+E_+A","-E_-A","+E_-A","-E_+A"/)
combo_name = (/"CONTROL","+ENSO+AMO","-ENSO-AMO","+ENSO-AMO","-ENSO+AMO"/)
num_end = 113

do i=0,4

wks := gsn_open_wks("pdf","/Volumes/data2/ASerakos/plots/cesm/model_comparison_plots/"+season+"_"+pattern+"_"+combo(i)+"_panel")
plot := new(6,graphic)

do r=0,5
hn := new(num_end+1,float)
;------ LOAD IN DATA ------
if (r.eq.0.or.r.eq.1) then
    precip_file := addfile("/Volumes/data2/ASerakos/data/obs_data/geopht/geopht.nc","r")
    precip_25 := precip_file->hgt(600:1967,10,:,:) ;---> Z500 jan 1901 - dec 2014
    if (season.eq."JJA") then
        if (pattern.eq."PNA") then
            pna_file := addfile("/Volumes/data2/ASerakos/data/PNA_data/pna_jjaavg_1901-2016.nc","r")
            pna := pna_file->pna_jja(0:num_end)
        else
            pna_file := addfile("/Volumes/data2/ASerakos/data/NAM_data/nam_jjaavg_1901-2016.nc","r")
            pna := pna_file->nam_jja(0:num_end)
        end if

        amo_file := addfile("/Volumes/data2/ASerakos/data/AMO_data/amo_jjaavg_1901-2016.nc","r")
        enso_file := addfile("/Volumes/data2/ASerakos/data/enso_data/enso_jjaavg_1901-2016.nc","r")
        amo := amo_file->amo_jja(0:num_end)
        enso := enso_file->enso_jja(0:num_end)

        precip_djf := month_to_season(precip_25,"JJA")
    else
        if (pattern.eq."PNA") then
            pna_file := addfile("/Volumes/data2/ASerakos/data/PNA_data/pna_djfavg_1901-2017.nc","r")
            pna := pna_file->pna_djf(0:num_end)
        else
            pna_file := addfile("/Volumes/data2/ASerakos/data/NAM_data/nam_djfavg_1901-2017.nc","r")
            pna := pna_file->nam_djf(0:num_end)
        end if
        amo_file := addfile("/Volumes/data2/ASerakos/data/AMO_data/amo_djfavg_1901-2017.nc","r")
        enso_file := addfile("/Volumes/data2/ASerakos/data/enso_data/enso_djfavg_1901-2017.nc","r")
        amo := amo_file->amo_djf(0:num_end)
        enso := enso_file->enso_djf(0:num_end)

        precip_djf := month_to_season(precip_25,"DJF")

    end if

    if (i.eq.0) then
        ind2 := enso.ne.3000.
        ind3 := amo.ne.3000.
    else if (i.eq.1) then
        ind2 := enso.gt.0
        ind3 := amo.gt.0
    else if (i.eq.2) then
        ind2 := enso.lt.0
        ind3 := amo.lt.0
    else if (i.eq.3) then
        ind2 := enso.gt.0
        ind3 := amo.lt.0
    else if (i.eq.4) then
        ind2 := enso.lt.0
        ind3 := amo.gt.0
    end if
    end if
    end if
    end if
    end if

    if (r.eq.0) then
        ind1 := pna.gt.0
        hn := where(ind1.eq.True.and.ind2.eq.True.and.ind3.eq.True,pna,hn@_FillValue)
    else if (r.eq.1) then
        ind1 := pna.lt.0
        hn := where(ind1.eq.True.and.ind2.eq.True.and.ind3.eq.True,pna,hn@_FillValue)
    end if
    end if

    pos_ind := ind(hn)
    num_val := num(hn)
    print(num_val)
    precip_djf_anom := dim_rmvmean_n_Wrap(precip_djf,0)
    printVarSummary(precip_djf_anom)

    pos_data1 := precip_djf_anom(pos_ind,:,:)
    pos_data := dim_avg_n_Wrap(pos_data1,0)

else if (r.eq.2.or.r.eq.3) then
    precip_file := addfile("/Volumes/data2/ASerakos/data/cesm/output/PC_timeseries/"+season+"_Z3_PC_REOF_MODEL_"+combo(i)+"_15-90N.nc","r")
    precip_251 := precip_file->REOF(:,:,:) ;---> Z500 jan 1901 - dec 2014

    if (season.eq."DJF") then
        if (i.eq.0) then
            if (pattern.eq."PNA") then
                if (r.eq.2) then
                    precip_25 := (precip_251(1,:,:)) * -1
                else
                    precip_25 := precip_251(1,:,:)
                end if
            else
                if (r.eq.2) then
                    precip_25 := precip_251(0,:,:)
                else
                    precip_25 := (precip_251(0,:,:)) * -1
                end if
            end if
        else if (i.eq.1) then
            if (pattern.eq."PNA") then
                if (r.eq.2) then
                    precip_25 := (precip_251(1,:,:)) * -1
                else
                    precip_25 := precip_251(1,:,:)
                end if
            else
                if (r.eq.2) then
                    precip_25 := precip_251(0,:,:)
                else
                    precip_25 := (precip_251(0,:,:)) * -1
                end if
            end if
        else if (i.eq.2) then
            if (pattern.eq."PNA") then
                if (r.eq.2) then
                    precip_25 := (precip_251(1,:,:)) * -1
                else
                    precip_25 := precip_251(1,:,:)
                end if
            else
                if (r.eq.2) then
                    precip_25 := (precip_251(0,:,:)) * -1
                else
                    precip_25 := precip_251(0,:,:)
                end if
            end if
        else if (i.eq.3) then
            if (pattern.eq."PNA") then
                if (r.eq.2) then
                    precip_25 := precip_251(2,:,:)
                else
                    precip_25 := (precip_251(2,:,:)) * -1
                end if
            else
                if (r.eq.2) then
                    precip_25 := (precip_251(0,:,:)) * -1
                else
                    precip_25 := precip_251(0,:,:)
                end if
            end if
        else if (i.eq.4) then
            if (pattern.eq."PNA") then
                if (r.eq.2) then
                    precip_25 := precip_251(1,:,:)
                else
                    precip_25 := (precip_251(1,:,:)) * -1
                end if
            else
                if (r.eq.2) then
                    precip_25 := precip_251(0,:,:)
                else
                    precip_25 := (precip_251(0,:,:)) * -1
                end if
            end if
        end if
        end if
        end if
        end if
        end if
    else if (season.eq."JJA") then
        if (i.eq.0) then
            if (pattern.eq."PNA") then
                if (r.eq.2) then
                    precip_25 := precip_251(4,:,:)
                else
                    precip_25 := (precip_251(4,:,:)) * -1
                end if
            else
                if (r.eq.2) then
                    precip_25 := precip_251(1,:,:)
                else
                    precip_25 := (precip_251(1,:,:)) * -1
                end if
            end if
        else if (i.eq.1) then
            if (pattern.eq."PNA") then
                if (r.eq.2) then
                    precip_25 := (precip_251(2,:,:)) * -1
                else
                    precip_25 := precip_251(2,:,:)
                end if
            else
                if (r.eq.2) then
                    precip_25 := (precip_251(0,:,:)) * -1
                else
                    precip_25 := precip_251(0,:,:)
                end if
            end if
        else if (i.eq.2) then
            if (pattern.eq."PNA") then
                if (r.eq.2) then
                    precip_25 := precip_251(0,:,:)
                else
                    precip_25 := (precip_251(0,:,:)) * -1
                end if
            else
                if (r.eq.2) then
                    precip_25 := (precip_251(1,:,:)) * -1
                else
                    precip_25 := precip_251(1,:,:)
                end if
            end if
        else if (i.eq.3) then
            if (pattern.eq."PNA") then
                if (r.eq.2) then
                    precip_25 := precip_251(3,:,:)
                else
                    precip_25 := (precip_251(3,:,:)) * -1
                end if
            else
                if (r.eq.2) then
                    precip_25 := (precip_251(1,:,:)) * -1
                else
                    precip_25 := precip_251(1,:,:)
                end if
            end if
        else if (i.eq.4) then
            if (pattern.eq."PNA") then
                if (r.eq.2) then
                    precip_25 := precip_251(1,:,:)
                else
                    precip_25 := (precip_251(1,:,:)) * -1
                end if
            else
                if (r.eq.2) then
                    precip_25 := (precip_251(0,:,:)) * -1
                else
                    precip_25 := precip_251(0,:,:)
                end if
            end if
        end if
        end if
        end if
        end if
        end if
    end if
    end if

    pos_data := precip_25
    copy_VarCoords(precip_251(0,:,:),pos_data)

else if (r.eq.4.or.r.eq.5) then
    precip_file := addfile("/Volumes/data2/ASerakos/data/cesm/output/PC_timeseries/"+season+"_Z3_PC_REOF_MODEL_"+combo(i)+"_rcp8.5_15-90N.nc","r")
    precip_251 := precip_file->REOF(:,:,:) ;---> Z500 jan 1901 - dec 2014

    if (season.eq."DJF") then
        if (i.eq.0) then
            if (pattern.eq."PNA") then
                if (r.eq.4) then
                    precip_25 := precip_251(2,:,:)
                else
                    precip_25 := (precip_251(2,:,:)) * -1
                end if
            else
                if (r.eq.4) then
                    precip_25 := precip_251(0,:,:) * -1
                else
                    precip_25 := precip_251(0,:,:)
                end if
            end if
        else if (i.eq.1) then
            if (pattern.eq."PNA") then
                if (r.eq.4) then
                    precip_25 := (precip_251(1,:,:)) * -1
                else
                    precip_25 := precip_251(1,:,:)
                end if
            else
                if (r.eq.4) then
                    precip_25 := precip_251(0,:,:)
                else
                    precip_25 := (precip_251(0,:,:)) * -1
                end if
            end if
        else if (i.eq.2) then
            if (pattern.eq."PNA") then
                if (r.eq.4) then
                    precip_25 := (precip_251(1,:,:)) * -1
                else
                    precip_25 := precip_251(1,:,:)
                end if
            else
                if (r.eq.4) then
                    precip_25 := (precip_251(0,:,:)) * -1
                else
                    precip_25 := precip_251(0,:,:)
                end if
            end if
        else if (i.eq.3) then
            if (pattern.eq."PNA") then
                if (r.eq.4) then
                    precip_25 := (precip_251(1,:,:)) * -1
                else
                    precip_25 := precip_251(1,:,:)
                end if
            else
                if (r.eq.4) then
                    precip_25 := precip_251(0,:,:)
                else
                    precip_25 := (precip_251(0,:,:)) * -1
                end if
            end if
        else if (i.eq.4) then
            if (pattern.eq."PNA") then
                if (r.eq.4) then
                    precip_25 := precip_251(1,:,:)
                else
                    precip_25 := (precip_251(1,:,:)) * -1
                end if
            else
                if (r.eq.4) then
                    precip_25 := (precip_251(0,:,:)) * -1
                else
                    precip_25 := precip_251(0,:,:)
                end if
            end if
        end if
        end if
        end if
        end if
        end if
    else if (season.eq."JJA") then
        if (i.eq.0) then
            if (pattern.eq."PNA") then
                if (r.eq.4) then
                    precip_25 := (precip_251(2,:,:)) * -1
                else
                    precip_25 := precip_251(2,:,:)
                end if
            else
                if (r.eq.4) then
                    precip_25 := (precip_251(0,:,:)) * -1
                else
                    precip_25 := precip_251(0,:,:)
                end if
            end if
        else if (i.eq.1) then
            if (pattern.eq."PNA") then
                if (r.eq.4) then
                    precip_25 := (precip_251(2,:,:)) * -1
                else
                    precip_25 := precip_251(2,:,:)
                end if
            else
                if (r.eq.4) then
                    precip_25 := (precip_251(0,:,:)) * -1
                else
                    precip_25 := precip_251(0,:,:)
                end if
            end if
        else if (i.eq.2) then
            if (pattern.eq."PNA") then
                if (r.eq.4) then
                    precip_25 := (precip_251(1,:,:)) * -1
                else
                    precip_25 := precip_251(1,:,:)
                end if
            else
                if (r.eq.4) then
                    precip_25 := precip_251(0,:,:)
                else
                    precip_25 := (precip_251(0,:,:)) * -1
                end if
            end if
        else if (i.eq.3) then
            if (pattern.eq."PNA") then
                if (r.eq.4) then
                    precip_25 := precip_251(2,:,:)
                else
                    precip_25 := (precip_251(2,:,:)) * -1
                end if
            else
                if (r.eq.4) then
                    precip_25 := precip_251(0,:,:)
                else
                    precip_25 := (precip_251(0,:,:)) * -1
                end if
            end if
        else if (i.eq.4) then
            if (pattern.eq."PNA") then
                if (r.eq.4) then
                    precip_25 := (precip_251(1,:,:)) * -1
                else
                    precip_25 := precip_251(1,:,:)
                end if
            else
                if (r.eq.4) then
                    precip_25 := precip_251(0,:,:)
                else
                    precip_25 := (precip_251(0,:,:)) * -1
                end if
            end if
        end if
        end if
        end if
        end if
        end if

    end if
    end if

    pos_data := precip_25
    copy_VarCoords(precip_251(0,:,:),pos_data)

end if
end if
end if

printVarSummary(pos_data)

;------------------ PLOTTING -----------------

;-------------------------------------------------------------

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

res@gsnRightString = ""
res@gsnLeftString = ""

;turn line labels and info label off
res@cnLineLabelsOn = False
res@cnInfoLabelOn = False

;label bar
;res@pmLabelBarDisplayMode = "Always"
;res@pmLabelBarSide = "Bottom"
;res@lbOrientation = "Horizontal"
;res@lbTitleString = "SST (C)"
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

res@mpCenterLonF = 180

;res@mpGridAndLimbOn        = True               ; turn on grid lines
;res@pmTickMarkDisplayMode  = "Always"           ; turn on fancy tickmarks

;res@mpLandFillColor        = "grey"
;res@cnFillDrawOrder      = "Predraw"  ; draw contours first

;res@cnLinesOn = True
;res@cnLevelSpacingF = 10.0


;res@sfXCStartV := min(pos_data&lon)
;res@sfXCEndV := max(pos_data&lon)
;res@sfYCStartV := max(pos_data&lat)
;res@sfYCEndV := min(pos_data&lat)

res@mpCenterLonF = -90
res@lbOrientation = "vertical"
res@lbTitlePosition      = "Right"
res@gsnPolar = "NH"
res@mpProjection =  "Stereographic"
res@mpPerimOn   = False
res@mpMinLatF  = 15                            ; minimum lat

;res@cnLinesOn            = False    ; turn off contour lines
;res@mpLimitMode = "LatLon"
;res@mpMaxLatF = 88.75
;res@mpMinLatF = 15.25
;res@mpMaxLonF = -50.75    ;316
;res@mpMinLonF = -179.75    ;183


res@gsnDraw             = False           ; don't draw
res@gsnFrame            = False           ; don't advance frame

if (r.eq.0) then
    res@gsnCenterString := "+" + pattern
else if (r.eq.1) then
    res@gsnCenterString := "-" + pattern
else
    res@gsnCenterString := ""
end if
end if


res@tiYAxisFontHeightF = 0.025
if (r.eq.0) then
    res@tiYAxisString := "Observations"
    res@tmYLLabelsOn := False
else if (r.eq.2) then
    res@tiYAxisString := "Model-HadOIBL"
    res@tmYLLabelsOn := False
else if (r.eq.4) then
    res@tiYAxisString := "Model-CMIP5,RCP8.5"
    res@tmYLLabelsOn := False
else
    res@tiYAxisString := ""
    res@tmYLLabelsOn := True
end if
end if
end if

res@lbLabelBarOn = False
res@cnLevelSelectionMode = "ExplicitLevels"

if (season.eq."DJF") then
    res@cnLevels := (/-72,-66,-60,-54,-48,-42,-36,-30,-24,-18,-12,-6,0,6,12,18,24,30,36,42,48,54,60,66,72/)
;    res@cnLevels = (/-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30/)
else
        res@cnLevels := (/-48,-44,-40,-36,-32,-28,-24,-20,-16,-12,-8,-4,0,4,8,12,16,20,24,28,32,36,40,44,48/)
;    res@cnLevels = (/-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18/)
end if

res@cnFillColors :=(/2,3,4,6,8,9,11,13,15,17,19,23,27,34,37,42,46,48,50,52,54,56,58,60,62,65/)
;res@cnFillColors =(/2,5,9,13,15,20,27,34,37,42,46,49,53,60,65/)

gsn_define_colormap(wks,"cmp_b2r")


;************** Plotting **************

;res@gsnLeftString = "REOF " + t
;res@gsnRightString = sprintf("%5.1f", ev_rot@pcvar_varimax(k)) +"%"

res@gsnDraw             = False           ; don't draw
res@gsnFrame            = False           ; don't advance frame
plot(r) = gsn_csm_contour_map(wks,pos_data(:,:),res)

end do

;************ Panel six REOF plots **************

pres = True
pres@txString       = ""+season+" "+combo_name(i)+" "+pattern+" Z500 (m) Composite or REOF"

pres@txFontHeightF = 0.016
pres@gsnPanelLabelBar = True
pres@lbOrientation = "horizontal"
pres@gsnMaximize = True
pres@lbTitleFont = 21
pres@lbPerimOn = False
pres@lbTitleFontHeightF = 0.015
;pres@pmLabelBarOrthogonalPosF = -.01           ; move whole thing down
;pres@mpPerimOn   = False
gsn_panel(wks,(/plot/),(/3,2/),pres)

delete(plot)
delete(wks)
delete(pos_data)
delete(res@gsnLeftString)
delete(res@gsnRightString)
delete(res)
delete(pres)

end do


end


