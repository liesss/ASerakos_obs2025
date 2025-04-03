load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"       ; loading our libraries...
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

season = "DJF" ;"JJA" or "DJF"

num_end = 115
if (season.eq."JJA") then
;--------- LOAD IN INDEX FILES JJA-------------
year_file = addfile("/Volumes/data2/ASerakos/data/PNA_data/pna_jjaavg_1901-2016.nc","r")
pna_file = addfile("/Volumes/data2/ASerakos/data/PNA_data/pna_jjaavg_1901-2016.nc","r")
nam_file = addfile("/Volumes/data2/ASerakos/data/NAM_data/nam_jjaavg_1901-2016.nc","r")
amo_file = addfile("/Volumes/data2/ASerakos/data/AMO_data/amo_jjaavg_1901-2016.nc","r")
enso_file = addfile("/Volumes/data2/ASerakos/data/enso_data/enso_jjaavg_1901-2016.nc","r")

year = year_file->year(0:num_end)   ;0:114 --> 1901-2015
;0:113 --> 1901-2014
pna = pna_file->pna_jja(0:num_end)
nam = nam_file->nam_jja(0:num_end)
amo = amo_file->amo_jja(0:num_end)
enso = enso_file->enso_jja(0:num_end)

else

;--------- LOAD IN INDEX FILES DJF-------------
year_file = addfile("/Volumes/data2/ASerakos/data/PNA_data/pna_djfavg_1901-2017.nc","r")
pna_file = addfile("/Volumes/data2/ASerakos/data/PNA_data/pna_djfavg_1901-2017.nc","r")
nam_file = addfile("/Volumes/data2/ASerakos/data/NAM_data/nam_djfavg_1901-2017.nc","r")
amo_file = addfile("/Volumes/data2/ASerakos/data/AMO_data/amo_djfavg_1901-2017.nc","r")
enso_file = addfile("/Volumes/data2/ASerakos/data/enso_data/enso_djfavg_1901-2017.nc","r")


year = year_file->year(0:num_end)  ;0:114 --> 1901-2015
;0:113 --> 1901-2014
pna = pna_file->pna_djf(0:num_end)
nam = nam_file->nam_djf(0:num_end)
amo = amo_file->amo_djf(0:num_end)
enso = enso_file->enso_djf(0:num_end)

end if

;-------------------------------------------------

mode1 = pna
mode2 = nam
mode3 = amo
weight_name = (/"PNA","NAM","AMO"/)

b=0
do u=0,7

hn := new(num_end,float)

if (u.eq.0) then
ind1 := mode1.gt.0 ;p_pna
ind2 := mode2.gt.0
ind4 := mode3.gt.0 ;p_amo
sign1 := "+"+weight_name(0)
sign2 := "+"+weight_name(1)
sign3 := "+"+weight_name(2)
else if (u.eq.1) then
ind1 := mode1.lt.0 ;p_pna
ind2 := mode2.lt.0
ind4 := mode3.lt.0 ;p_amo
sign1 := "-"+weight_name(0)
sign2 := "-"+weight_name(1)
sign3 := "-"+weight_name(2)
else if (u.eq.2) then
ind1 := mode1.gt.0 ;p_pna
ind2 := mode2.gt.0
ind4 := mode3.lt.0 ;p_amo
sign1 := "+"+weight_name(0)
sign2 := "+"+weight_name(1)
sign3 := "-"+weight_name(2)
else if (u.eq.3) then
ind1 := mode1.gt.0 ;p_pna
ind2 := mode2.lt.0
ind4 := mode3.lt.0 ;p_amo
sign1 := "+"+weight_name(0)
sign2 := "-"+weight_name(1)
sign3 := "-"+weight_name(2)
else if (u.eq.4) then
ind1 := mode1.lt.0 ;p_pna
ind2 := mode2.gt.0
ind4 := mode3.gt.0 ;p_amo
sign1 := "-"+weight_name(0)
sign2 := "+"+weight_name(1)
sign3 := "+"+weight_name(2)
else if (u.eq.5) then
ind1 := mode1.lt.0 ;p_pna
ind2 := mode2.lt.0
ind4 := mode3.gt.0 ;p_amo
sign1 := "-"+weight_name(0)
sign2 := "-"+weight_name(1)
sign3 := "+"+weight_name(2)
else if (u.eq.6) then
ind1 := mode1.gt.0 ;p_pna
ind2 := mode2.lt.0
ind4 := mode3.gt.0 ;p_amo
sign1 := "+"+weight_name(0)
sign2 := "-"+weight_name(1)
sign3 := "+"+weight_name(2)
else if (u.eq.7) then
ind1 := mode1.lt.0 ;p_pna
ind2 := mode2.gt.0
ind4 := mode3.lt.0 ;p_amo
sign1 := "-"+weight_name(0)
sign2 := "+"+weight_name(1)
sign3 := "-"+weight_name(2)
end if
end if
end if
end if
end if
end if
end if
end if

hn := where(ind1.eq.True.and.ind2.eq.True.and.ind4.eq.True,pna,hn@_FillValue)
index_values := get1Dindex(hn,pna)
pos_ind := ind(hn)
num_val := num(hn)

;print(pos_ind)
;print(num_val)

event_years := year(pos_ind)

print(sign1+sign2+sign3+", # of Years = "+num_val+", Event Years = "+event_years)
print("--------------------")
end do



end




