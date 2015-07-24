;+
; NAME:
;    ADD_FLARE10
;PURPOSE: 
;   Add a simulated 10MK flare, scaled by arbitrary amount, to
;   an image cube of real NuSTAR data with a certain pixel size
;
;INPUTS:
;   Image cube, Frame #
;OPTIONAL:
;   scaling, pixel size, shift, energy range, livetime correction
;OUTPUTS:
;   Image cube with flare added to the desired frame

function add_flare10, imcube, frame, scale=scale, dwell=dwell,$
    pix_size=pix_size, move=move, erange=erange, livetime=livetime

common flare10, flare_dir, flare10

if n_elements(flare10) eq 0 then begin
flare_dir = '/home/andrew/nusim/Solar/'
flare10 = mrdfits(flare_dir+'flare_sim_10MK_1s.events.fits',1,fh)
endif

bkg_cts = total(imcube[*,*,frame])

;* Read in simulated flare fits file*;
a = where(flare10.module eq 1)   ;Events from 1 telescope (FPMA)
fa = flare10[a]
;b = where(flare10.module eq 2)   ;Events from FPMB
;fb = flare10[b]

;Select energy range
if n_elements(erange) ne 0 then begin
   emin = min(erange)
   emax = max(erange)
   kev = fa.e
   inrange = where((kev ge emin) and (kev le emax))
   fa = fa[inrange]
endif

SetDefaultValue, dwell, 100.
SetDefaultValue, livetime, 0.04
SetDefaultValue, scale, 0.01    ;reasonable starting point 
SetDefaultValue, pix_size, 58  ;NuSTAR HPD

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

if n_elements(move) ne 0 then begin
   nf = shift(nf, move)
endif

;Add flare image to the imcube image
if ((size(nf))[1] eq (size(im0))[1]) && ((size(nf))[2] eq (size(im0))[2]) then begin
   im0 = im0 + nf
endif else begin
   sd = size(im0,/dimensions)
   sf = size(nf,/dimensions)
   if sd[0] gt sf[0] then begin
      ax = fltarr(sd[0] - sf[0], sf[1])
      nf = [nf,ax]
      sf = size(nf,/dimensions)
   endif
   if sd[1] gt sf[1] then begin
      ay = fltarr(sf[0], sd[1] - sf[1])
      nf = [[nf],[ay]]
   endif
   if sd[0] lt sf[0] then nf = nf[0:sd[0]-1,*]
   if sd[1] lt sf[1] then nf = nf[*, 0:sd[1]-1]

   im0 = im0 + nf
   
endelse

fimcube = imcube
;Normalize so that number of counts in frame stays constant 
fimcube[*,*,frame] = im0 * ( bkg_cts / total(im0) )

return, fimcube 


END
