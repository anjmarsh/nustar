FUNCTION calc_em_array, im, livetime, oaa_arcmin, dwell=dwell, $
                        pix_size=pix_size, erange=erange, combine=combine, $
                        det_imcube=det_imcube, vimcube=vimcube, _extra=_extra
default, dwell, 100.
default, pix_size, 60.
default, erange, [2.5,4]
default, combine, 0

imcube = im.imcube
det_imcube = imcube & tod = imcube

;How many excess counts needed to claim a detection for every pixel in
;the given image cube?  
FOR i=0, n_elements(imcube)-1 DO BEGIN
   a = array_indices(imcube, i) 
   det_imcube[i] = calc_detect_cts(imcube, a, livetime=livetime, _extra=_extra)
ENDFOR

temp = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
em_struct = {emcube:double(imcube), temp:temp}
em_array = replicate(em_struct, n_elements(temp))

;Calculate off-axis angle correction to the sensitivity
vigncube = make_vigncube(oaa_arcmin, erange=erange)
vimcube = rebin(vigncube,(size(vigncube,/dim))[0],(size(vigncube,/dim))[1],(size(imcube,/dim))[2])

flare_dir = '/home/andrew/nusim/solar/flares/'
flare_simfiles = ['flare_sim_2MK_10s.events.fits','flare_sim_3MK_10s.events.fits',$
'flare_sim_4MK_1s.events.fits','flare_sim_5MK_1s.events.fits',$
'flare_sim_6MK_1s.events.fits','flare_sim_7MK_1s.events.fits',$
'flare_sim_8MK_1s.events.fits','flare_sim_9MK_1s.events.fits',$
'flare_sim_10MK_1s.events.fits','flare_sim_11MK_1s.events.fits',$
'flare_sim_12MK_1s.events.fits']

FOR t=temp[0], temp[n_elements(temp)-1] DO BEGIN

      flare = mrdfits(flare_dir+flare_simfiles[t-2], 1)
;  .r   
   FOR p=0, n_elements(imcube)-1 DO BEGIN

      tindex = (array_indices(imcube, p))[2]

      em_array[t-2].emcube[p] = calc_flare_cts(t, flare, dwell=dwell, $
                    pix_size=pix_size, counts=det_imcube[p]/livetime[tindex]/vimcube[p],$
                    erange=erange, combine=combine)
   ENDFOR
;   end
ENDFOR

RETURN, em_array

END
