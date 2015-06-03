;+
; NAME:
;    SENSITIVITY_PROBE
;PURPOSE: 
;   Probe the relationship between flare scaling multiplier and the
;   max of the diff_matrix distribution. This is important b/c
;   the scaling that yields max(dm_flare) = 2*max(dm_noflare) is used
;   as the scaling parameter to calculate the Flare Flux Upper Limit
;INPUTS:
;   Image cube
;OPTIONAL:
;   Frame # for initial flare addition
;OUTPUTS:
;   Generates a text file that can be used to plot the relationship
;   between scaling and max(diff_matrix). If run completely will
;   output a full sensitivity matrix of same dimensions as image cube 
;IMPORTANT:
;   To look at the scaling for the simulated 2MK flare (instead of
;   5MK), change all instances of 'add_flare_5MK' to 'add_flare_2MK'
;   These spectra will have different relations btwn si and maxdi

function sensitivity_probe, im, frame=frame

SetDefaultValue, frame, 0

dwell_th = 100  ;temporal binning - 100s for thermal emission
pix_size = 58  ;spatial binning - NuSTAR HPD
erange = [2.5,4]  ;energy range fully thermal

ima = im.imcube
ta = transient_search(ima)
da = ta.diff_matrix 
maxa = max(da) ;diff_max for no-flare case

xlen = (size(ima))[1]
ylen = (size(ima))[2]
n_frames = (size(ima))[3]
sarray = float( ima * 0)

;figure out correct flare pixel indices
si = 1
ai = add_flare_5MK(ima, frame, scale=si, pix_size=pix_size, erange=erange)

w = where( ai[*,*,frame] eq max(ai[*,*,frame]) )
flare_peak = array_indices( ai[*,*,frame], w )

xshiftpos = xlen - flare_peak[0]
yshiftpos = ylen - flare_peak[1]

;test scaling for every pixel in every frame

;for frame=0,n_frames-1 do begin

;for xshift = -flare_peak[0], xshiftpos-1 do begin
;   for yshift = -flare_peak[1], yshiftpos-1 do begin 

      xshift = 0
      yshift = 0      
      si = 1  ;initial scaling
      ai = add_flare_5MK(ima, frame, scale=si, pix_size=pix_size, move=[xshift,yshift], erange=erange)
      ti = transient_search(ai) 
      dfi = ti.diff_matrix 
      maxdi = max(dfi) ;initial diff_max

      openw, lun, 'scaling_vs_diffmax1_5MK.txt', /get_lun
      .r
      while (maxdi GT 2*maxa) do begin ;loop until max = 2*noflare_diff_max
         printf, lun, si, '   ', maxdi
         si = si - 0.01        ;scale down in 0.01 increments
         af = add_flare_5MK(ima, frame, scale=si, pix_size=pix_size, move=[xshift,yshift], erange=erange)
         tf = transient_search(af) 
         dff = tf.diff_matrix 
         maxdi = max(dff)
         print,maxdi
      endwhile
      end
      free_lun, lun

      x = flare_peak[0] + xshift 
      y = flare_peak[1] + yshift
      sarray[x,y,frame] = si

;   endfor
;endfor
;endfor

;return, sarray

END
