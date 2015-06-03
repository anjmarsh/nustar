;+
; NAME:
;    TEST_ONDISK
;PURPOSE: 
;   Determine if any part of a given pixel in a NuSTAR sky 
;   image cube is on the solar disk.
;   
;INPUTS:
;   Image cube, pixel indices
;OPTIONAL:
;   Pixel size. Default is 58"
;OUTPUTS:
;   1 for on-disk, 0 for off-disk

function test_ondisk, im, indices, pix_size=pix_size

SetDefaultValue, pix_size, 58

sky_pix = 2.45810736       ;software pixel in arcseconds 
xcen = 1500    
ycen = 1500

xmin = im.minx 
ymin = im.miny

;calculate x/y distance from Sun center, in arcesc
xd = (xmin-xcen)*sky_pix + (indices[0]+1)*pix_size
yd = (ymin-ycen)*sky_pix + (indices[1]+1)*pix_size

r = sqrt(xd^2 + yd^2) 

if r lt 960 then begin
return, 1 
endif else begin 
return, 0 
endelse


END
