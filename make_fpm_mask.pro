FUNCTION make_fpm_mask, evtfilea, evtfileb, dwell=dwell, pix_size=pix_size, $
                         _extra=_extra, stop=stop

;Set time, space, and energy parameters
if ~keyword_set(dwell) then $
    dwell = 100.               ;s
if ~keyword_set(pix_size) then $
    pix_size = 60.            ;arcsec

evt_str = combine_fpm_filter(evtfilea, evtfileb)
evtaf = evt_str.evtaf  &  ha = evt_str.ha
evtbf = evt_str.evtbf  &  hb = evt_str.hb
min_array = evt_str.min_array

;Get min/max x/y values for combining the telescopes
minx = min_array[0]  &  maxx = min_array[1]
miny = min_array[2]  &  maxy = min_array[3]

ima = make_imcube(evtfilea, dwell, pix_size, evt=evtaf, head=ha, filter=0, $
                   minx=minx, maxx=maxx, miny=miny, maxy=maxy, _extra=_extra)
imb = make_imcube(evtfileb, dwell, pix_size, evt=evtbf, head=hb, filter=0, $
                   minx=minx, maxx=maxx, miny=miny, maxy=maxy, _extra=_extra) 
imca = ima.imcube
imcb = imb.imcube
lta = ima.livetime
ltb = imb.livetime

m = (n_elements(imca) lt n_elements(imcb)) ? imca : imcb 
for i=0, n_elements(m)-1 do m[i] = max([imca[i]/imcb[i],imcb[i]/imca[i]])

if keyword_set(stop) then stop

fpm_mask = m 
FOR i=0, n_elements(fpm_mask)-1 DO BEGIN
   IF (imca[i]+imcb[i] gt 10) && (m[i] gt 3) THEN BEGIN
      IF imca[i] le imcb[i] THEN   $
      fpm_mask[i] = 0  ELSE fpm_mask[i] = 1
   ENDIF ELSE fpm_mask[i] = 2
ENDFOR

RETURN, fpm_mask

END

   
