;+
; NAME:
;    ADD_FLARE
;PURPOSE: 
;   Add a simulated flare, scaled by arbitrary amount, to
;   an image cube of real NuSTAR data with a certain pixel size
;
;INPUTS:
;   Image cube, Flare Temperature, Frame #
;OPTIONAL:
;   Simulated flare directory, scaling, pixel size, shift, 
;   energy range, livetime factor
;OUTPUTS:
;   Image cube with flare added to the desired frame

function add_flare, imcube, temp, frame, flare_dir=flare_dir, scale=scale,$
dwell=dwell, pix_size=pix_size,move=move, erange=erange, livetime=livetime

SetDefaultValue, flare_dir, '/home/andrew/nusim/solar/flares/'
SetDefaultValue, dwell, 100.
SetDefaultValue, scale, 0.01  ;reasonable starting point 
SetDefaultValue, pix_size, 58  ;NuSTAR HPD
SetDefaultValue, livetime, 0.04  ;valid for obs2 NP pointing

CASE temp OF
   2: BEGIN
        flare = mrdfits(flare_dir+'flare_sim_2MK_10s.events.fits',1,fh)
        dwell = dwell / 10.  ;10s simulation
      END
   3: BEGIN
        flare = mrdfits(flare_dir+'flare_sim_3MK_10s.events.fits',1,fh)
        dwell = dwell / 10.   ;10s simulation
      END
   4: flare = mrdfits(flare_dir+'flare_sim_4MK_1s.events.fits',1,fh)
   5: flare = mrdfits(flare_dir+'flare_sim_5MK_1s.events.fits',1,fh)
   6: flare = mrdfits(flare_dir+'flare_sim_6MK_1s.events.fits',1,fh)
   7: flare = mrdfits(flare_dir+'flare_sim_7MK_1s.events.fits',1,fh)
   8: flare = mrdfits(flare_dir+'flare_sim_8MK_1s.events.fits',1,fh)
   9: flare = mrdfits(flare_dir+'flare_sim_9MK_1s.events.fits',1,fh)
  10: flare = mrdfits(flare_dir+'flare_sim_10MK_1s.events.fits',1,fh)
ELSE: BEGIN
   print, 'Temperature must be 2, 3, 4, 5, 6, 7, 8, 9, or 10 MK'
   RETURN, 0
END
ENDCASE

bkg_cts = total(imcube[*,*,frame])

a = where(flare.module eq 1)   ;Events from 1 telescope (FPMA)
fa = flare[a]

;Select energy range
IF n_elements(erange) ne 0 THEN BEGIN
   emin = min(erange)
   emax = max(erange)
   kev = fa.e
   inrange = where((kev ge emin) and (kev le emax))
   fa = fa[inrange]
ENDIF

det1x = fa.det1x
det1y = fa.det1y

bin = 0.6 / 12.3 * pix_size ;correct binning for NuSIM image 
nf = hist_2d(det1x, det1y, min1=-20, max1=20, min2=-20, max2=20,$
bin1=bin, bin2=bin)
nf = nf * scale * dwell * livetime
;livetime & temporal (dwell) scale factors
;Counts seen from flare in dwell # seconds, reduced by LT 
;eventually change so that LT is extracted from appropriate hk file

im0 = imcube[*,*,frame]

IF n_elements(move) ne 0 THEN BEGIN
   nf = shift(nf, move)
ENDIF

;Add flare image to the imcube image
IF ((size(nf))[1] eq (size(im0))[1]) && ((size(nf))[2] eq (size(im0))[2]) THEN BEGIN
   im0 = im0 + nf
ENDIF ELSE BEGIN
   sd = size(im0,/dimensions)
   sf = size(nf,/dimensions)
   IF sd[0] gt sf[0] THEN BEGIN
      ax = fltarr(sd[0] - sf[0], sf[1])
      nf = [nf,ax]
      sf = size(nf,/dimensions)
   ENDIF
   IF sd[1] gt sf[1] THEN BEGIN
      ay = fltarr(sf[0], sd[1] - sf[1])
      nf = [[nf],[ay]]
   ENDIF
   IF sd[0] lt sf[0] THEN nf = nf[0:sd[0]-1,*]
   IF sd[1] lt sf[1] THEN nf = nf[*, 0:sd[1]-1]

   im0 = im0 + nf
   
ENDELSE

fimcube = imcube

;Normalize so that number of counts in frame stays constant 
fimcube[*,*,frame] = im0 * ( bkg_cts / total(im0) )

RETURN, fimcube 


END
