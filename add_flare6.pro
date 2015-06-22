;+
; NAME:
;    ADD_FLARE6
;PURPOSE: 
;   Add a simulated 6MK flare, scaled by arbitrary amount, to
;   an image cube of real NuSTAR data with a certain pixel size
;
;INPUTS:
;   Image cube, Frame #
;OPTIONAL:
;   scaling, pixel size, shift, energy range, livetime correction
;OUTPUTS:
;   Image cube with flare added to the desired frame

function add_flare6, imcube, frame, scale=scale, dwell=dwell,$
   pix_size=pix_size, move=move, erange=erange, livetime=livetime

common flare6, flare6

bkg_cts = total(imcube[*,*,frame])

;* Read in simulated flare fits file*;
a = where(flare6.module eq 1)   ;Events from 1 telescope (FPMA)
fa = flare6[a]
;b = where(flare6.module eq 2)   ;Events from FPMB
;fb = flare6[b]

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
SetDefaultValue, scale, 0.01  ;reasonable starting point 
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

s = imcube[*,*,frame]

if n_elements(move) ne 0 then begin
   nf = shift(nf, move)
endif

;Add flare image to the imcube image
if ((size(nf))[1] eq (size(s))[1]) && ((size(nf))[2] eq (size(s))[2]) then begin
   s = s + nf
endif else begin
   s1 = size(s,/dimensions)
   s2 = size(nf,/dimensions)
   g = fltarr(s2[0],abs(s1[1]-s2[1]))
   fc = [[nf],[g]]
   j = fltarr(abs(s1[0]-s2[0]),s1[1])
   fc = [fc,j]
   s = s + fc
endelse

fimcube = imcube
;Normalize so that number of counts in frame stays constant 
fimcube[*,*,frame] = s * ( bkg_cts / total(s) )

return, fimcube 


END
