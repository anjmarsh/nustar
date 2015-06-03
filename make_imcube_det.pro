;+
; NAME:
;    MAKE_IMCUBE_DET
;PURPOSE: 
;   Generate a NuSTAR image-cube, in DETECTOR coordinates
;INPUTS:
;   Event file name, dwell (integration time per frame, in sec), pixel size
;   (in arcseconds)
;OPTIONAL:
;   Energy range (in keV)
;OUTPUTS:
;   Image Cube 

function make_imcube_det, evtfile, dwell, pix_size, erange=erange

;Read in event file
evt = mrdfits(evtfile, 1,evth)

;Exclude events with pulse height = 0
inrange = where(evt.pi ge 0)
evt = evt[inrange]

;Select energy range
if n_elements(erange) ne 0 then begin
   emin = min(erange)
   emax = max(erange)
   kev = 1.6 + evt.pi * 0.04
   inrange = where(kev ge emin && kev le emax)
   evt = evt[inrange]
endif

;Set up time variables
min_evt_time = min(evt.time)
thist = histogram(evt.time - min_evt_time, min = 0, binsize = dwell, reverse_indices = tinds)
nframes = n_elements(thist) 
tindex = findgen(n_elements(thist)) * dwell
stop_t = n_elements(tindex) - 1 

;Appropriate binning; software pixel size is 2.46" (1/5
;physical pixel size)
bin = round( pix_size / 2.46 ) 

;Generate image cube
for t = 0,stop_t - 1 do begin
   
      thisframe = tinds[tinds[t]:tinds[t+1]-1]
      
      if n_elements(thisframe) gt 1 then begin
      im = hist_2d( evt[thisframe].det1x, evt[thisframe].det1y, bin1=bin, bin2=bin, min1=0, max1=359, min2=0, max2 = 359 )
;   endif else begin
;      x = [evt[thisframe].det1x, minx-1]
;      y = [evt[thisframe].det1y, miny-1]
;      im = hist_2d(x, y, min1 = 0,$
;      max1 = 359, min2 = 0,  max2 = 359, bin1 = bin, bin2 = bin)
;   endelse
   endif

      if t eq 0 then imcube = im
      if t gt 0 then imcube = [ [[imcube]], [[im]] ]

   endfor

return, imcube

end
