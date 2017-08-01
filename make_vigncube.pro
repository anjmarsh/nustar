;+
; NAME:
;    MAKE_VIGNCUBE
;PURPOSE:   
;    Calculates the average correction factor due to vignetting for
;    every macropixel in a NuSTAR image cube
;INPUTS:
;    Array of average off-axis angles in arcmin; generated with
;    make_imcube calls to make_det2array and calc_oaa_array
;OPTIONAL: 
;    Energy Range (in keV)
;CALLS: 
;    NuSTAR CALDB must be installed and set as environment variable
;OUTPUTS:
;    Vignetting Correction Array 

FUNCTION make_vigncube, oaa_arcmin, erange=erange

SetDefaultValue, erange, [2.5,4]
;Start with oaa_arcmin; average off-axis distance for every macropixel 
vigncube = oaa_arcmin

;Pull out the vignetting curves
caldb = getenv('CALDB')
default, module, 'A'
vigncaldbfile=caldb+'/data/nustar/fpm/bcf/vign/nu'+module+'vign20100101v006.fits'
vign=mrdfits(vigncaldbfile,1,hh,/silent)
vign = vign[0]   ;extra dimensions are degenerate
energ_lo = vign.energ_lo
energ_hi = vign.energ_hi

FOR i=0, n_elements(oaa_arcmin)-1 DO BEGIN

   theta = where( abs(oaa_arcmin[i] - vign.theta) eq min(abs(oaa_arcmin[i] - vign.theta)) )
   vignet = vign.vignet[*, theta]

   vigncube[i] = average( vignet[where((energ_lo ge min(erange)) and (energ_hi le max(erange)))] )

ENDFOR

RETURN, vigncube 

END
