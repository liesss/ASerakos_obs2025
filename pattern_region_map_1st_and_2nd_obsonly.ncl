load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"       ; loading our libraries...
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

reg_file = (/"us_regions_files/reusregionshapefiles/Alaska_us","us_regions_files/reusregionshapefiles/NE_us","us_regions_files/reusregionshapefiles/SE_us","us_regions_files/reusregionshapefiles/MW_us","us_regions_files/reusregionshapefiles/GP_us","us_regions_files/reusregionshapefiles/NW_us","us_regions_files/reusregionshapefiles/SW_us","Canada_shapefiles/canadashapefiles/Canada_bc","Canada_shapefiles/canadashapefiles3/Canada_prarie","Canada_shapefiles/canadashapefiles4/Canada_central","Canada_shapefiles/canadashapefiles/Canada_atl","Canada_shapefiles/canadashapefiles2/Canada_north","Mexico_shapefiles/mexicoshapefiles/Mexico_north","Mexico_shapefiles/mexicoshapefiles/Mexico_south"/)
;colori = (/"seagreen","cyan","orange","cyan","seagreen","seagreen","seagreen","seagreen","seagreen","cyan","royalblue","seagreen","pink","orange"/)
;opacity = (/0.7,0.8,0.2,1.0,0.6,0.8,0.3,0.9,1.0,0.9,1.0,0.4,1.0,0.3/)

name_var = (/"1st Dominant","2nd Dominant","","","","","",""/)
nameYaxis = (/"Obs +anomalies","","Model +anomalies","","Obs -anomalies","","Model -anomalies",""/)

poly_array = new(14,graphic)

monandseas = "JJA" ; "DJF", "JJA"

wks_type = "png"
wks_type@wkWidth = 2500
wks_type@wkHeight = 2500
wks = gsn_open_wks(wks_type, ""+monandseas+"_1st_2nd_obs_only_2024edits")

;do i=0,13

;--- LOAD SHAPEFILES ---

shp_fname1 = "/Volumes/data2/ASerakos/data/USA_shapefiles/us_regions_files/reusregionshapefiles/Alaska_us.shp"

mask_file = addfile("/Volumes/data2/ASerakos/scripts/cesm_model_scripts/line_plots/Alaska_mask.nc","r")
usa_mask = mask_file->USA_mask
print("1")
;---Read in precip data
a = addfile("/Volumes/data2/ASerakos/data/cesm/output/control/cam/model_data/variables/tot_precip/control_06142016.cam.tot_precip.0010-90.nc","r")
tot_precip1 = a->tot_precip(0,:,:)                                ; read month one total precip
tot_precip = lonFlip(tot_precip1)

minlon = -180
maxlon =  -40
minlat =   0
maxlat =   85

;---Create a new mask using a shapefile of USA
udims = dimsizes(tot_precip)
opt             = True
opt@return_mask = True
;    opt@debug       = True
opt@minlon      = minlon     ; Makes the shapefile masking
opt@maxlon      = maxlon     ; go faster.
opt@minlat      = minlat
opt@maxlat      = maxlat
;usa_mask        = shapefile_mask_data(tot_precip,shp_fname1,opt)

res                       = True     ; plot mods desired
res@gsnMaximize           = True
res@gsnDraw               = False
res@gsnFrame              = False

res@mpOutlineOn           = True
res@cnFillOn              = True     ; turn on color fill
res@cnLinesOn             = False    ; turn off contour lines
res@cnLineLabelsOn        = False    ; turn off contour line labels
res@lbLabelBarOn          = False    ; will turn on in panel

res@mpMaxLatF                   = 85           ; choose a different subregion
res@mpMinLatF                   = 10
res@mpMaxLonF                   = 315
res@mpMinLonF                   = 180


res@gsnDraw             = False           ; don't draw
res@gsnFrame            = False           ; don't advance frame

;txres               =  True
;txres@txFontHeightF =  0.012         ;-- default size is HUGE!
;pgres                        =  True
;pgres@gsFillColor            := "orangered"      ;-- fill color
;pgres@gsFillOpacityF         =  0.3         ;-- set opacity of polygon
;xndc := 0.05
;yndc := 0.15
;txres@txJust        = "TopRight"
;txres@txFontColor   = "black"
;gsn_text_ndc(wks,"+PNA", xndc, yndc, txres)
;gsn_polygon_ndc(wks,(/xndc,xndc-0.1,xndc-0.1,xndc,xndc/),\
;(/yndc-0.04,yndc-0.04,yndc-0.08,yndc-0.08,yndc-0.04/),\
;pgres)

;pgres@gsFillColor            := "darkorange"      ;-- fill color
;xndc := 0.05
;yndc := 0.15
;gsn_text_ndc(wks,"+NAM", xndc+0.2, yndc+0.2, txres)
;gsn_polygon_ndc(wks,(/xndc,xndc-0.1,xndc-0.1,xndc-0.5,xndc-0.5/),\
;(/yndc-0.04,yndc-0.04,yndc-0.08,yndc-0.08,yndc-0.04/),\
;pgres)

lnres  = True

;---Be sure to use same levels for both plots
mnmxint = nice_mnmxintvl( min(tot_precip), max(tot_precip), 25, False)
res@cnLevelSelectionMode        = "ManualLevels"
res@cnMinLevelValF              = mnmxint(0)
res@cnMaxLevelValF              = mnmxint(1)
res@cnLevelSpacingF             = mnmxint(2)

;res@gsnLeftString = ""+reg_name(i)+""
res@gsnStringFontHeightF = 0.02

plot = new(8,graphic)
do t=0,7

;reg_file = (/"Alaska_us","NE_us","SE_us","MW_us","GP_us","NW_us","SW_us","Canada_bc","Canada_prarie","Canada_central","Canada_atl","Canada_north","Mexico_north","Mexico_south"/)


if (t.eq.0) then
    if (monandseas.eq."DJF") then
        colori := (/"orangered","dodgerblue4","dodgerblue4","white","orangered","orangered","orangered","orangered","orangered","goldenrod1","darkslategray","orangered","darkgreen","dodgerblue4"/) ; -- DJF +temp obs 1st
        patterni := (/17,17,17,0,17,17,17,17,17,17,17,17,17,17/)
        color2i :=(/"black","black","black","goldenrod1","black","black","black","black","black","black","black","black","black","black"/)
    end if
    if (monandseas.eq."JJA") then
        colori = (/"goldenrod1","firebrick","firebrick","firebrick","firebrick","orangered","white","white","darkorange","firebrick","firebrick","firebrick","firebrick","firebrick"/) ;-- JJA +temp obs 1st
        patterni :=(/17,17,17,17,17,17,0,0,17,17,17,17,17,17/)
        color2i := (/"black","black","black","black","black","black","darkorange","firebrick","black","black","black","black","black","black"/)
    end if

else if (t.eq.1) then
    if (monandseas.eq."DJF") then
        colori := (/"goldenrod1","white","darkorange","firebrick","white","goldenrod1","white","goldenrod1","goldenrod1","orangered","goldenrod1","goldenrod1","dodgerblue4","white"/) ; -- DJF +temp obs 2nd
        patterni :=(/17,0,17,17,0,17,0,17,17,17,17,17,17,0/)
        color2i := (/"black","darkorange","black","black","goldenrod1","black","darkslategray","black","black","black","black","black","black","darkorange"/)
    end if
    if (monandseas.eq."JJA") then
        colori := (/"white","dodgerblue4","dodgerblue4","white","dodgerblue4","white","white","white","firebrick","dodgerblue4","white","white","white","dodgerblue4"/) ; -- JJA +temp obs 2nd
        patterni :=(/0,17,17,0,17,0,0,0,17,17,0,0,0,17/)
        color2i := (/"darkslategray","black","black","dodgerblue4","black","firebrick","orangered","goldenrod1","black","black","darkgreen","darkslategray","dodgerblue4","black"/)
    end if

else if (t.eq.2) then
    if (monandseas.eq."DJF") then
        colori := (/"dodgerblue4","darkslategray","orangered","darkslategray","dodgerblue4","dodgerblue4","dodgerblue4","dodgerblue4","dodgerblue4","cyan4","cyan4","dodgerblue4","goldenrod1","goldenrod1"/) ; -- DJF -temp obs 1st
        patterni :=(/17,17,17,17,17,17,17,17,17,17,17,17,17,17/)
        color2i := (/"black","black","black","black","black","black","black","black","black","black","black","black","black","black"/)
    end if
    if (monandseas.eq."JJA") then
        colori = (/"darkgreen","cyan4","cyan4","darkslategray","darkslategray","dodgerblue4","cyan4","cyan4","cyan4","cyan4","cyan4","cyan4","cyan4","cyan4"/) ; -- JJA -temp obs 1st
        patterni :=(/17,17,17,17,17,17,17,17,17,17,17,17,17,17/)
        color2i := (/"black","black","black","black","black","black","black","black","black","black","black","black","black","black"/)
    end if

else if (t.eq.3) then
    if (monandseas.eq."DJF") then
        colori := (/"darkgreen","white","darkslategray","white","darkslategray","white","white","white","white","white","darkorange","cyan4","white","orangered"/) ; -- DJF -temp obs 2nd
        patterni :=(/17,0,17,0,17,0,0,0,0,0,17,17,0,17/)
        color2i := (/"black","cyan4","black","cyan4","black","darkslategray","darkslategray","cyan4","cyan4","dodgerblue4","black","black","cyan4","black"/)
    end if
    if (monandseas.eq."JJA") then
        colori := (/"white","white","white","cyan4","cyan4","white","white","darkgreen","darkslategray","white","white","white","orangered","white"/) ; -- JJA temp obs 2nd
        patterni :=(/0,0,0,17,17,0,0,17,17,0,0,0,17,0/)
        color2i := (/"cyan4","orangered","darkgreen","black","black","darkslategray","orangered","black","black","darkslategray","goldenrod1","darkgreen","black","orangered"/)
    end if

else if (t.eq.4) then
    if (monandseas.eq."DJF") then
        colori := (/"dodgerblue4","white","dodgerblue4","dodgerblue4","goldenrod1","white","white","dodgerblue4","dodgerblue4","darkgreen","white","white","goldenrod1","goldenrod1"/) ; -- DJF +precip obs 1st
        patterni :=(/17,0,17,17,17,0,0,17,17,17,17,0,17,17/)
        color2i := (/"black","dodgerblue4","black","black","black","darkgreen","dodgerblue4","black","black","black","black","dodgerblue4","black","black"/)
    end if
    if (monandseas.eq."JJA") then
        colori = (/"dodgerblue4","darkslategray","white","darkslategray","goldenrod1","white","white","white","dodgerblue4","dodgerblue4","white","dodgerblue4","darkgreen","firebrick"/) ; -- JJA +precip obs
        patterni :=(/17,17,0,17,17,0,0,0,17,17,0,17,17,17/)
        color2i := (/"black","black","orangered","black","black","orangered","orangered","dodgerblue4","black","black","dodgerblue4","black","black","black"/)
    end if

else if (t.eq.5) then
    if (monandseas.eq."DJF") then
        colori := (/"darkorange","white","white","white","white","white","goldenrod1","white","darkgreen","white","white","white","orangered","orangered"/) ; -- DJF +precip obs 2nd
        patterni :=(/17,0,0,0,0,0,17,0,17,0,0,0,17,17/)
        color2i := (/"black","darkorange","darkorange","darkorange","darkorange","firebrick","black","firebrick","black","dodgerblue4","darkgreen","darkslategray","black","black"/)
    end if
    if (monandseas.eq."JJA") then
        colori := (/"firebrick","white","white","goldenrod1","darkslategray","white","white","white","white","white","white","white","white","darkgreen"/) ; -- JJA +precip obs 2nd
        patterni :=(/17,0,0,17,17,0,0,0,0,0,0,0,0,17/)
        color2i := (/"black","firebrick","darkorange","black","black","firebrick","cyan4","firebrick","firebrick","darkslategray","darkorange","darkslategray","orangered","black"/)
    end if

else if (t.eq.6) then
    if (monandseas.eq."DJF") then
        colori := (/"orangered","white","white","orangered","darkgreen","white","white","orangered","goldenrod1","goldenrod1","darkorange","white","darkgreen","darkgreen"/) ; -- DJF -precip obs 1st
        patterni :=(/17,0,0,17,17,0,0,17,17,17,17,0,17,17/)
        color2i := (/"black","goldenrod1","darkgreen","black","black","cyan4","cyan4","black","black","black","black","dodgerblue4","black","black"/)
    end if
    if (monandseas.eq."JJA") then
        colori = (/"cyan4","white","white","orangered","dodgerblue4","white","dodgerblue4","orangered","white","orangered","white","white","white","goldenrod1"/) ; -- JJA -precip obs 1st
        patterni :=(/17,0,0,17,17,0,17,17,0,17,0,0,0,17/)
        color2i := (/"black","orangered","dodgerblue4","black","black","firebrick","black","black","orangered","black","darkgreen","cyan4","dodgerblue4","black"/)
    end if

else
    if (monandseas.eq."DJF") then
        colori := (/"goldenrod1","white","white","darkslategray","white","white","white","darkslategray","cyan4","white","white","white","white","white"/) ; -- DJF -precip obs 2nd
        patterni :=(/17,0,0,17,0,0,0,17,17,0,0,0,0,0/)
        color2i := (/"black","orangered","orangered","black","cyan4","darkorange","darkgreen","black","black","orangered","firebrick","darkgreen","cyan4","firebrick"/)
    end if
    if (monandseas.eq."JJA") then
        colori := (/"orangered","white","white","darkorange","darkgreen","white","white","white","white","white","white","white","white","white"/) ; -- JJA -precip obs 2nd
        patterni :=(/17,0,0,17,17,0,0,0,0,0,0,0,0,0/)
        color2i := (/"black","cyan4","goldenrod1","black","black","orangered","darkorange","darkorange","darkorange","darkorange","firebrick","darkslategray","firebrick","orangered"/)
    end if

end if
end if
end if
end if
end if
end if
end if

opacity = 0.6

res@gsnCenterString := ""+name_var(t)+""
res@gsnCenterStringFontHeightF := 0.025

;res@tiYAxisString := nameYaxis(t)
;res@tiYAxisFontHeightF := 0.025

;---Create (but don't draw) both plots
plot(t)= gsn_csm_contour_map(wks,usa_mask,res)

ptres = True
;ptres@MonoFillPattern := False

do u=0,13
    shp_fname = "/Volumes/data2/ASerakos/data/USA_shapefiles/"+reg_file(u)+".shp"
    lnres@gsFillColor := colori(u)
    lnres@gsFillOpacityF := opacity
    lnres@gsFillIndex := 0
    ptres@gsFillColor := color2i(u)
    ptres@gsFillOpacityF := opacity
    ptres@gsFillIndex := patterni(u)
    ptres@gsFillScaleF := 0.6

    poly_orig = gsn_add_shapefile_polygons(wks,plot(t),shp_fname,lnres)
    overlay(plot(t),poly_orig)

    poly_orig2 = gsn_add_shapefile_polygons(wks,plot(t),shp_fname,ptres)
    overlay(plot(t),poly_orig2)
    
    poly_orig1 = gsn_add_shapefile_polylines(wks,plot(t),shp_fname,lnres)
    overlay(plot(t),poly_orig1)
    print("8")
end do

print("okay")

;n=n+1
delete(poly_orig)
delete(poly_orig1)
delete(poly_orig2)
delete(colori)
;delete(patterni)

;delete(usa_mask)
;delete(mask_fname)
;delete(shp_fname)
end do

;---Draw both plot in a panel.
pres                  = True
pres@txFontHeightF = 0.016
if (monandseas.eq."DJF") then
    pres@txString = "DJF, 1st and 2nd Dominant Observational ~C~ Temperature (95%) and Precipitation (90%) Response by Region"
else if (monandseas.eq."JJA") then
    pres@txString = "JJA, 1st and 2nd Dominant Observational ~C~ Temperature (95%) and Precipitation (90%) Response by Region"
end if
end if

pres@gsnMaximize      = True
pres@gsnPanelLabelBar = False


gsn_panel(wks,plot,(/4,2/),pres)

;delete(plot)




end






