;+
; NAME:
;    COMBINE_FPM_IMCUBE
;PURPOSE: 
;   Generate a joint NuSTAR image-cube that combines counts from FPMA
;   and FPMB. Uses only overlapping sky (heliocentric) coordinates
;INPUTS:
;   FPMA event file, FPMB event file 
;OPTIONAL:
;   Dwell (integration time per frame, in sec), pixel size (in
;   arcseconds), any arguments taken by make_imcube
;CALLS: 
;   combine_fpm_filter.pro, make_imcube.pro
;OUTPUTS:
;   Structure that includes joint image cube, individual telescope
;   data (including imcubes, livetime, and off-axis angle), range of
;   x/y positions used to generate imcube arrays 

function combine_fpm_imcube, evtfilea, evtfileb, dwell=dwell, pix_size=pix_size, $
_extra=_extra

default, dwell, 100.
default, pix_size, 60. 

evt_str = combine_fpm_filter(evtfilea, evtfileb)
evtaf = evt_str.evtaf  &  ha = evt_str.ha
evtbf = evt_str.evtbf  &  hb = evt_str.hb
min_array = evt_str.min_array

;Get min/max x/y values for combining the telescopes
minx1 = min_array[0]  &  maxx1 = min_array[1]
miny1 = min_array[2]  &  maxy1 = min_array[3]

; Pass min/max by value or they will be changed!
evta = make_imcube(evtfilea, dwell, pix_size, evt=evtaf, head=ha, filter=0, $
                   minx=long(minx1), maxx=long(maxx1), miny=long(miny1), $
                   maxy=long(maxy1), _extra=_extra)
; Pass min/max by reference because now I want them to change
evtb = make_imcube(evtfileb, dwell, pix_size, evt=evtbf, head=hb, filter=0, $
                   minx=minx1, maxx=maxx1, miny=miny1, maxy=maxy1, $
                   _extra=_extra) 

imcube = evta.imcube + evtb.imcube 
livetime = [evta.livetime + evtb.livetime]/2
oaa_arcmin = [evta.oaa_arcmin + evtb.oaa_arcmin]/2

imstruct = {imcube:imcube, livetime:livetime, oaa_arcmin:oaa_arcmin, $
            evta:evta, evtb:evtb, minx:minx1, maxx:maxx1, miny:miny1, maxy:maxy1, $
            tstart:min([evta.tstart, evtb.tstart]), tstop:max([evta.tstop, evtb.tstop])}

RETURN, imstruct 

END

