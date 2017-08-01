PRO transient_search, dwell=dwell, pix_size=pix_size, erange=erange, $
savefig=savefig

; Load in 2014-Nov-01 quiet-Sun event files
restore, '~/nustar/solar/20141101_data/evtfiles.sav'

; Set time, space, and energy parameters
default, dwell, 100.   ;s
default, pix_size, 60.   ;arcsec
default, erange, [] ;Use the full energy range 

; Make shifted / unshifted image cubes
im = combine_fpm_imcube(evt4a, evt4b, dwell=dwell, pix_size=pix_size, $
erange=erange, /exclude)
im_shift = combine_fpm_imcube(evt4a, evt4b, dwell=dwell, pix_size=pix_size, $
erange=erange, /exclude, /shift_right)
; Get on-disk pixels. Should be same for shifted / unshifted
tod = im.imcube 
FOR j=0, n_elements(tod)-1 DO tod[j] = test_ondisk(im, array_indices(tod, j))
ondisk = where(tod eq 1)

;Determine which pixels to use 1 or 2 telescopes for
fpm_mask = make_fpm_mask(evt4a, evt4b, dwell=dwell, pix_size=pix_size)

;Calculate Poisson probabilities P(>S)_B
pcube_combine = calc_poisson_imcube(im.imcube, im.livetime)
pcube_fpma = calc_poisson_imcube(im.evta.imcube, im.evta.livetime)
pcube_fpmb = calc_poisson_imcube(im.evtb.imcube, im.evtb.livetime)
pcube_shift_combine = calc_poisson_imcube(im_shift.imcube, im_shift.livetime)
pcube_shift_fpma = calc_poisson_imcube(im_shift.evta.imcube, im_shift.evta.livetime)
pcube_shift_fpmb = calc_poisson_imcube(im_shift.evtb.imcube, im_shift.evtb.livetime)

;Find lowest probability event and determine pixel position on the Sun
pmm, pcube_combine, pcube_fpma, pcube_fpmb
pmm, pcube_shift_combine, pcube_shift_fpma, pcube_shift_fpmb
 i = where(pcube_shift_combine eq min(pcube_shift_combine))
 a = array_indices(pcube_shift_combine, i) & print, a 
solar_minx = ((im_shift.minx-1500)+a[0])*2.45 - 105
solar_miny = ((im_shift.miny-1500)+a[1])*2.45 + 65
tstart = im_shift.tstart 
tstop = tstart+dwell
tstart_ut = convert_nustar_time(tstart, /ut)
tstop_ut = convert_nustar_time(tstop, /ut) 
print, solar_minx, solar_miny, tstart_ut, tstop_ut

;Choose pixels with telescope mask
pcube = pcube_combine
pcube_shift = pcube_shift_combine

FOR i=0, n_elements(pcube)-1 DO BEGIN
   IF fpm_mask[i] eq 2 THEN pcube[i] = pcube_combine[i] $
   ELSE IF fpm_mask[i] eq 0 THEN pcube[i] = pcube_fpma[i] $ 
   ELSE IF fpm_mask[i] eq 1 THEN pcube[i] = pcube_fpmb[i]
ENDFOR
FOR i=0, n_elements(pcube_shift)-1 DO BEGIN
   IF fpm_mask[i] eq 2 THEN pcube_shift[i] = pcube_shift_combine[i] $
   ELSE IF fpm_mask[i] eq 0 THEN pcube_shift[i] = pcube_shift_fpma[i] $ 
   ELSE IF fpm_mask[i] eq 1 THEN pcube_shift[i] = pcube_shift_fpmb[i]
ENDFOR

print, 'Min unshifted probability = '+strtrim(min(pcube),2)
print, 'Min shifted probability = '+strtrim(min(pcube_shift),2)
h_shift = histogram(alog10(pcube_shift[ondisk]), min=-8.25, max=1.25, bin=0.5, locations=b_shift)
h = histogram(alog10(pcube[ondisk]), min=-8.25, max=1.25, bin=0.5, locations=b)
!p.multi=0
cgloadct, 3, /reverse
plot, b, h, thick=3, psym=10, /ylog, yr=[0.1, 1000], xr=[-8, 0], /xs, $
xtit='Log(Probability)', ytit='# of Occurrences', charsi=1.2, charthi=1.2
oplot, b_shift, h_shift, thick=5, psym=10, color=120, linest=1
al_legend, ['100 s', '100 s shift'], line=[0,1], thick=4, /top, /left, box=0, $
charsize=1.3, color=[255, 120]

if keyword_set(erange) then estring='lowe' else estring='alle'
if keyword_set(savefig) then write_png, 'phist_shift_unshift_'+estring+'.png', tvrd(/true)                                        

end
