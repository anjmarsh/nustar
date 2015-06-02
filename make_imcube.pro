function make_imcube, evtfile, dwell, pix_size, erange=erange
;Generate image cube using solar-adjusted sky coordinates from '..sunpos.evt'

evt = mrdfits(evtfile, 1,evth)

;Extract pixel size and number from event file header
ttype = where(stregex(evth, "TTYPE", /boolean))
xt = where(stregex(evth[ttype], 'X', /boolean))
xpos = (strsplit( (strsplit(evth[ttype[max(xt)]], ' ', /extract))[0], 'E', /extract))[1]
npix = sxpar(evth, 'TLMAX'+xpos)
npix_size = abs(sxpar(evth,'TCDLT'+xpos))

inrange = where(evt.pi ge 0)
evt = evt[inrange]

if n_elements(erange) ne 0 then begin
   emin = min(erange)
   emax = max(erange)
   kev = 1.6 + evt.pi * 0.04
   inrange = where((kev ge emin) and (kev le emax))
   evt = evt[inrange]
endif

minx = min(evt.x)
maxx = max(evt.x)
miny = min(evt.y)
maxy = max(evt.y)

;Set up time variables
min_evt_time = min(evt.time)
thist = histogram(evt.time - min_evt_time, min = 0, binsize = dwell, reverse_indices = tinds)
nframes = n_elements(thist) 
tindex = findgen(n_elements(thist)) * dwell
stop_t = n_elements(tindex) - 1 

bin = round(pix_size / npix_size)

for t = 0,stop_t - 1 do begin
   
   thisframe = tinds[tinds[t]:tinds[t+1]-1]

   if n_elements(thisframe) gt 1 then begin 
      im = hist_2d(evt[thisframe].x, evt[thisframe].y, min1 = minx,$
      max1 = maxx, min2 = miny,  max2 = maxy, bin1 = bin, bin2 = bin)
   endif else begin
      x = [evt[thisframe].x, minx-1]
      y = [evt[thisframe].y, miny-1]
      im = hist_2d(x, y, min1 = minx,$
      max1 = maxx, min2 = miny,  max2 = maxy, bin1 = bin, bin2 = bin)
   endelse
      
   if t eq 0 then imcube = im
   if t gt 0 then imcube = [ [[imcube]], [[im]] ]

   endfor

imstruct = create_struct( 'imcube',imcube,'minx',minx,'maxx',maxx,'miny',$
                         miny,'maxy',maxy )

return, imstruct

end
