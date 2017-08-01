;+
; NAME:
;    GET_NUSTAR_LIVETIME
;PURPOSE: 
;   Obtain NuSTAR livetime for a given event file (and time range)
;
;INPUTS:
;   Event File (full path)
;OPTIONAL:
;   Start & Stop Times (in NuSTAR clock units)
;OUTPUTS:
;   Structure with Time, UT, and Livetime for desired interval

function get_nustar_livetime, evtfile, tstart=tstart, tstop=tstop

evtdir = strmid(evtfile, 0, strlen(evtfile)-strlen(file_basename(evtfile)))
sp = strsplit(evtdir, '/', /extract)
hkdir = strmid(evtdir, 0, strlen(evtdir)-(strlen(sp[n_elements(sp)-1])+1))+'hk/'
hkfiles = file_search(hkdir+'*fpm.hk')

hka = mrdfits(hkfiles[0],1)
t = hka.time   ;time array should be same for FPM A/B
SetDefaultValue, tstart, min(t)
SetDefaultValue, tstop, max(t)
tstart = tstart[0]   ;ensure double, not 1-element array
tstop = tstop[0]    ;ensure double, not 1-element array
t = t[where((t ge tstart) and (t le tstop))]
ut = convert_nustar_time(t, /ut)

fpm = strpos((strsplit(evtfile, '/', /extract))[n_elements(sp)], 'A')   
;test if event file from telescope A

if fpm ne -1 then begin      ;FPMA
   lta = hka.livetime
   livet = lta[where((t ge tstart) and (t le tstop))]

endif else begin            ;FPMB
   hkb = mrdfits(hkfiles[1],1)
   ltb = hkb.livetime
   livet = ltb[where((t ge tstart) and (t le tstop))]
endelse

lt_struct = create_struct( 'time', t, 'ut', ut, 'livetime', livet )

return, lt_struct

end 
