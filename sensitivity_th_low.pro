;+
; NAME:
;    SENSITIVITY_TH_LOW
;PURPOSE: 
;   Calculate flare scaling matrix corresponding to an input NuSTAR
;   image cube. Simulated 2MK flare is added to input image cube, then
;   scalings are calculated to give a 'barely detectable' event. 
;
;   This is defined as the  scaling that yields 
;   max(dm_flare) = 2*max(dm_noflare)
;
;   dm is the 'diff_matrix' generated by the transient_search procedure
;   
;INPUTS:
;   Image cube
;OPTIONAL:
;   Frame # for initial flare addition
;OUTPUTS:
;   Matrix of scaling factors for every frame and every pixel in the
;   input image cube 

function sensitivity_th_low, im, frame=frame

SetDefaultValue, frame, 0

dwell_th = 100  ;temporal binning - 100s for thermal emission
pix_size = 58  ;spatial binning - NuSTAR HPD
erange = [2.5,4]  ;energy range for thermal

ima = im.imcube
ta = transient_search(ima)
da = ta.diff_matrix 
maxa = max(da) ;diff_max for no-flare case
print, 'Non-flare maximum = ' + string(fix(maxa))

xlen = (size(ima))[1]
ylen = (size(ima))[2]
n_frames = (size(ima))[3]
sarray = float( ima * 0)

;figure out correct flare pixel indices
si = 0.01
ai = add_flare2(ima, frame, scale=si, pix_size=pix_size, erange=erange)

w = where( ai[*,*,frame] eq max(ai[*,*,frame]) )
flare_peak = array_indices( ai[*,*,frame], w )

xshiftpos = xlen - flare_peak[0]
yshiftpos = ylen - flare_peak[1]

;test scaling for every pixel in every frame

for frame=0,n_frames-1 do begin
for xshift = -flare_peak[0], xshiftpos-1 do begin
   for yshift = -flare_peak[1], yshiftpos-1 do begin 
      
      si = 0.01  ;initial scaling
      ai = add_flare2(ima, frame, scale=si, pix_size=pix_size, move=[xshift,yshift], erange=erange)
      ti = transient_search(ai) 
      dfi = ti.diff_matrix 
      maxdi = max(dfi) ;initial diff_max
      print, 'Initial maximum with flare = ' + string(fix(maxdi)) 

      while (maxdi GT 2*maxa) do begin  ;loop until max = 2*noflare_diff_max
         si = si - 0.0005 ;scale down in increments
         af = add_flare2(ima, frame, scale=si, pix_size=pix_size, move=[xshift,yshift], erange=erange)
         tf = transient_search(af) 
         dff = tf.diff_matrix 
         maxdi = max(dff)
         print,maxdi
      endwhile

      x = flare_peak[0] + xshift 
      y = flare_peak[1] + yshift
      sarray[x,y,frame] = si

   endfor
endfor
endfor

return, sarray

END
