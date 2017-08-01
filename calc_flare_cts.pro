;+
; NAME:
;    CALC_FLARE_CTS
;PURPOSE:   
;    Calculate the number of NuSTAR counts in the peak pixel for a
;    flare of given temperature and emission measure.  
;INPUTS:
;    Flare temperature (in MK)
;    Flare IDL structure (read from NuSIM .fits file) 
;OPTIONAL: 
;    Pixel size; default value is 1'
;    Dwell time; default value is 100s
;    Emission measure; option to specify value (in cm-3) instead of scaling 
;    Energy range in keV
;    Flare scaling factor (script will return counts)
;    # of Counts produced by flare (script will return EM)
;    Flag to calculate emission measure with # counts as input
;OUTPUTS:
;    # of counts, or EM if keyword is set 

FUNCTION calc_flare_cts, temp, flare, scale=scale, dwell=dwell, $
pix_size=pix_size, em=em, erange=erange, counts=counts, combine=combine

default, dwell, 100
default, pix_size, 60

dwell2 = dwell

if (temp eq 2) or (temp eq 3) then dwell2 = dwell2 / 10.  ;10s simulations

if ~keyword_set(combine) then begin
a = where(flare.module eq 1)   ;Events from 1 telescope (FPMA)
fa = flare[a]
endif else fa = flare

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

IF n_elements(em) gt 0 THEN BEGIN
   ems = [10., 1.0d-1, 1.0d-1, 1.0d-2, 1.0d-2, 1.0d-2,$
          1.0d-2, 1.0d-2, 1.0d-2, 1d-3, 1d-3]
   scale = (double(em) / 1d49) * ems[temp-2]
ENDIF

IF dwell2 eq 0 then STOP 

IF n_elements(counts) gt 0 THEN BEGIN

   bin = 0.6 / 12.3 * pix_size ;correct binning for NuSIM image 
   nf = hist_2d(det1x, det1y, min1=-20, max1=20, min2=-20, max2=20,$
bin1=bin, bin2=bin)
   m = max(nf) * dwell2
   ratio = double(counts) / double(m) 
   ems = [10., 1.0d-1, 1.0d-1, 1.0d-2, 1.0d-2, 1.0d-2,$   
          1.0d-2, 1.0d-2, 1.0d-2, 1d-3, 1d-3]
   em = ems[temp-2] * ratio
   RETURN, EM

ENDIF

bin = 0.6 / 12.3 * pix_size ;correct binning for NuSIM image 
nf = hist_2d(det1x, det1y, min1=-20, max1=20, min2=-20, max2=20,$
bin1=bin, bin2=bin)
nf2 = nf * scale * dwell2

if nf2 gt 1d44 then stop

n = round( max(nf2) )

RETURN, N 

END
