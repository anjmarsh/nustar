;+
; NAME:
;    CALC_DETECT_CTS
;PURPOSE:   
;    Compute the number of counts (above background) needed to
;    claim the detection of a transient event. References
;    user-generated Poisson databases to determine this number 
;    based on the background level (determined by temporally 
;    neighboring pixels) and the probability threshold; this is
;    set to 1d-6 by default. 
;INPUTS:
;    NuSTAR Image Cube, binned in time & space
;    Array Index, in [x,y,t] format
;OPTIONAL: 
;    Livetime array (average for each time-frame) 
;    Directory containing the Poisson databases
;    Poisson Probability Threshold for a 'detection'; the default
;    value is 1d-6
;    Flag to use float or double; default is double
;    Extra arguments to pass to poisson_oneframe_dbase or
;    poisson_twoframe_dbase when making the data-bases
;    Can input data-bases directly 
;CALLS: 
;    Need Poisson databases for one and two background frames
;    Default is to use saved arrays; _extra call means create
;    To create them, calls poisson_oneframe_dbase.pro and
;    poisson_twoframe_dbase.pro 
;OUTPUTS:
;    Number of excess counts needed to claim the detection of a
;    transient event
;

FUNCTION calc_detect_cts, imcube, index, livetime=livetime, poisson_dir=poisson_dir,$
threshold=threshold, double=double, _extra=_extra, oneframedbase=oneframedbase, $
twoframedbase=twoframedbase

default, threshold, 1d-6
default, poisson_dir, '/home/andrew/poisson/'
default, double, 1 

s = size(imcube, /dimensions)
x = index[0]
y = index[1]
t = index[2]

IF n_elements(livetime) eq 0 THEN livetime = make_array(t, /float, value=1)

IF (t gt 0) and (t lt s[2]-1) THEN BEGIN
   IF keyword_set(twoframedbase) THEN $
      dbase_norm2 = twoframedbase $
   ELSE IF keyword_set(_extra) THEN $
      dbase_norm2 = poisson_twoframe_dbase(_extra=_extra, /ret) $
   ELSE IF keyword_set(double) THEN restore, poisson_dir+'poisson_twoframe_dbase_largen_dbl.sav' $
   ELSE IF ~keyword_set(double) THEN restore, poisson_dir+'poisson_twoframe_dbase.sav'

   B = 0.5 * livetime[t] * ( imcube[x, y, t-1] / livetime[t-1] + imcube[x, y, t+1] / livetime[t+1] ) 
   n = where(abs(dbase_norm2[round(B*2), *]-threshold) eq min(abs(dbase_norm2[round(B*2), *]-threshold)))
   nex = n - round(B)

ENDIF ELSE BEGIN
   IF keyword_set(oneframedbase) THEN $
      dbase_norm = oneframedbase $
   ELSE IF keyword_set(_extra) THEN $
      dbase_norm = poisson_oneframe_dbase(_extra=_extra, /ret) $
   ELSE IF keyword_set(double) THEN restore, poisson_dir+'poisson_oneframe_dbase_largen_dbl.sav' $
   ELSE IF ~keyword_set(double) THEN restore, poisson_dir+'poisson_oneframe_dbase.sav'

   IF t eq 0 THEN B = round( livetime[t] * imcube[x, y, t+1] / livetime[t+1] )
   IF t eq s[2]-1 THEN B = round( livetime[t] * imcube[x, y, t-1] / livetime[t-1] )
   n = where(abs(dbase_norm[B, *]-threshold) eq min(abs(dbase_norm[B, *]-threshold)))
   nex = n - B

ENDELSE

;IF n_elements(nex) le 2 THEN nex = nex[0]
;IF n_elements(nex) gt 2 THEN STOP

RETURN, nex[0]

END
