;+
; NAME:
;    MAKE_DET2ARRAY
;PURPOSE: 
;   Generate an array of average DET2X/Y coordinates for a particular
;   image cube setup in make_imcube
;INPUTS:
;   Event indices, min & max X/Y coordinate values, bin size (arcsec)
;OUTPUTS:
;   Array of average DET2X(Y) values for each macropixel binned by
;   make_imcube

function make_det2array, evt, xrange, yrange, bin

nx = (max(xrange)-min(xrange))/bin + 1
ny = (max(yrange)-min(yrange))/bin + 1 

det2x_array = fltarr(nx, ny)
det2y_array = fltarr(nx, ny)

FOR xindex=0, nx-1 DO BEGIN
   FOR yindex=0, ny-1 DO BEGIN
      
      ix = where(( -evt.x ge (min(xrange)+xindex*bin) ) and $
                 ( -evt.x lt (min(xrange)+(xindex+1)*bin) ))
      det2x = average(evt[ix].det2x)
      
      iy = where(( evt.y ge (min(yrange)+yindex*bin) ) and $
                 ( evt.y lt (min(yrange)+(yindex+1)*bin) ))
      det2y = average(evt[iy].det2y)

      det2x_array[xindex, yindex] = det2x
      det2y_array[xindex, yindex] = det2y
      
   ENDFOR
ENDFOR

det2array = {det2x:det2x_array, det2y:det2y_array}

RETURN, det2array

END
