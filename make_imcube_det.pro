function make_imcube_det, evtfile, dwell, pix_size, erange=erange

evt = mrdfits(evtfile, 1,evth)

inrange = where(evt.pi ge 0)
evt = evt[inrange]

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


bin = round( pix_size / 2.46 ) 

for t = 0,stop_t - 1 do begin
   
      thisframe = tinds[tinds[t]:tinds[t+1]-1]

      im = hist_2d( evt[thisframe].det1x, evt[thisframe].det1y, bin1=bin, bin2=bin, min1=0, max1=359, min2=0, max2 = 359 )

      if t eq 0 then imcube = im
      if t gt 0 then imcube = [ [[imcube]], [[im]] ]

   endfor

return, imcube

end
