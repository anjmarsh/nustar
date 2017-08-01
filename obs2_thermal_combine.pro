FUNCTION obs2_thermal_combine, dwell=dwell, pix_size=pix_size, erange=erange,$
ondisk=ondisk, _extra=_extra

;Load in 2014-Nov-01 quiet-Sun event files
restore, '~/nustar/solar/20141101_data/evtfiles.sav', /v

;Set time, space, and energy parameters
default, dwell, 100.   ;s
default, pix_size, 60.   ;arcsec
default, erange, [2.5,4.]   ;keV

;Make individual & joint image cubes
im = combine_fpm_imcube(evt4a, evt4b, dwell=dwell, pix_size=pix_size, erange=erange,$
/exclude, _extra=_extra)
imcube = im.imcube
tod = imcube

;Set probability threshold 
threshold =  0.05 / n_elements(imcube) / 2. ; # of macro-pixels w/ shift at 95% confidence

;Determine which pixels to use 1 or 2 telescopes for
fpm_mask = make_fpm_mask(evt4a, evt4b, dwell=dwell, pix_size=pix_size, erange=erange)

;Which pixels have their centers on the solar disk?
FOR j=0, n_elements(tod)-1 DO tod[j] = test_ondisk(im, array_indices(tod, j))
ondisk = where(tod eq 1)

;Calculate detectable EM values
em_array_combine = calc_em_array(im, im.livetime, im.oaa_arcmin, /combine, $
                                 det_imcube=det_imcube_combine, threshold=threshold)
em_array_fpma = calc_em_array(im.evta, im.evta.livetime, im.evta.oaa_arcmin, $
                              det_imcube=det_imcube_fpma, threshold=threshold)
em_array_fpmb = calc_em_array(im.evtb, im.evtb.livetime, im.evtb.oaa_arcmin, $
                              det_imcube=det_imcube_fpmb, threshold=threshold)

;Choose pixels with telescope mask
em_array = em_array_combine 
FOR n=0, n_elements(em_array_combine[0].temp)-1 DO BEGIN
   FOR i=0, n_elements(em_array_combine[0].emcube)-1 DO BEGIN
      IF fpm_mask[i] eq 2 THEN em_array[n].emcube[i] = em_array_combine[n].emcube[i] $
      ELSE IF fpm_mask[i] eq 0 THEN em_array[n].emcube[i] = em_array_fpma[n].emcube[i] $ 
      ELSE IF fpm_mask[i] eq 1 THEN em_array[n].emcube[i] = em_array_fpmb[n].emcube[i]
   ENDFOR
ENDFOR

nbins = 10
;em_array = rem_tag(em_array, 'hist')
;em_array = rem_tag(em_array, 'bins')
em_array = add_tag(em_array, dindgen(nbins), 'hist')
em_array = add_tag(em_array, dindgen(nbins), 'bins')

FOR n=0, n_elements(em_array[0].temp)-1 DO BEGIN
   em_array[n].hist = histogram(em_array[n].emcube[ondisk], $
   min=min(em_array[n].emcube[ondisk]), max=max(em_array[n].emcube[ondisk]), $
   nbins=nbins, locations = bins)

   em_array[n].bins = bins
ENDFOR


RETURN, em_array


END
