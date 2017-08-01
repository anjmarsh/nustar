FUNCTION CALC_OAA_ARRAY, det2array, fpm=fpm

;Get on-axis position in DET2 coordinates (FPMA & FPMB)
caldb = getenv('CALDB')
caldir = caldb+'/data/nustar/fpm/bcf/align/'
alignfile = caldir+'nuCalign20100101v007.fits'

align = mrdfits(alignfile, 4)
x_det2a = align.x_det2a
y_det2a = align.y_det2a
x_det2b = align.x_det2b
y_det2b = align.y_det2b

det2x = det2array.det2x
det2y = det2array.det2y 
oaa_arcmin = det2x

;Indicate which telescope we are using 
default, fpm, 'A'

;1 pixel = 2.45 arcsec 
;Calc distance in pixels, convert to arcsec then arcmin

FOR i=0,n_elements(oaa_arcmin)-1 DO BEGIN

   IF fpm eq 'A' THEN oaa = sqrt((det2x[i]-x_det2a)^2+(det2y[i]-y_det2a)^2)
   IF fpm eq 'B' THEN oaa = sqrt((det2x[i]-x_det2b)^2+(det2y[i]-y_det2b)^2)

   oaa_arcmin[i] = oaa * 2.45 / 60.
   
ENDFOR

RETURN, oaa_arcmin

END
