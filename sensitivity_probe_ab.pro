;+
; NAME:
;    SENSITIVITY_PROBE_AB
;PURPOSE: 
;   Probe the relationship between flare scaling multiplier and the
;   max of the diff_matrix distribution. This is important b/c
;   the scaling that yields max(dm_flare) = 2*max(dm_noflare) is used
;   as the scaling parameter to calculate the Flare Flux Upper Limit
;
;   Looking at the effect of using 'rdiff_abmin' to select the lowest
;   diff value between FPMA and FPMB for each pixel. This should
;   increase the sensitivity, question is by how much? 
;INPUTS:
;   Image cube
;OPTIONAL:
;   Frame # for initial flare addition
;OUTPUTS:
;   Generates a text file that can be used to plot the relationship
;   between scaling and max(diff_matrix). If run completely will
;   output a full sensitivity matrix of same dimensions as image cube 
;IMPORTANT:
;   To look at the scaling for a different simulated flare, change the
;   name of the "add_flare" script, e.g. add_flare2 to add_flare3.
;   Different spectra will have different relations btwn si and maxdi

function sensitivity_probe_ab, ima, imb, frame=frame

SetDefaultValue, frame, 0

dwell_th = 100  ;temporal binning - 100s for thermal emission
pix_size = 58  ;spatial binning - NuSTAR HPD
erange = [2.5,4]  ;energy range for thermal

imca = ima.imcube
ta = transient_search(imca)
dma = ta.diff_matrix 
imcb = imb.imcube 
tb = transient_search(imcb)
dmb = tb.diff_matrix 
dmc = rdiff_abmin(dma, dmb)
print, 'Non-flare maximum = ' + string(fix(max(dmc)))

xlen = (size(imca))[1]
ylen = (size(imca))[2]
n_frames = (size(imca))[3]
sarray = float( imca * 0)

;figure out correct flare pixel indices
si = 1
ai = add_flare3(imca, frame, scale=si, pix_size=pix_size, erange=erange,dwell=100)

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
      si = 0.001  ;initial scaling
      ai = add_flare4(imcb, frame, scale=si, pix_size=pix_size, move=[xshift,yshift], erange=erange, dwell=100)   ;add flare w/ initial scaling
      ti = transient_search(ai) 
      dfi = ti.diff_matrix 
      maxdi = max(dfi) ;initial diff_max
      
      ;open text file to write values 
;      openw, lun, 'scaling_vs_diffmax_2MK.txt', /get_lun
      .r
      while (maxdi GT 2*max(dmc)) do begin ;loop until max = 2*noflare_diff_max
;         printf, lun, si, '   ', maxdi
         si = si - 0.00001        ;scale down in increments
         af = add_flare4(imcb, frame, scale=si, pix_size=pix_size, move=[xshift,yshift], erange=erange, dwell=100)   ;add flare w/ current si value
         tf = transient_search(af) 
         dff = tf.diff_matrix 
         maxdi = max(dff)
         print,maxdi,'   ',si
      endwhile
      end
;      free_lun, lun

;* First results using maxa and max(dmc) sequentially: 
;* print, sa2 / sc2   (using add_flare3)
;*  1.77778            
;* print, sa1 / sc1   (using add_flare4)
;*  1.76191

      x = flare_peak[0] + xshift 
      y = flare_peak[1] + yshift
      sarray[x,y,frame] = si

;   endfor
;endfor
;endfor

;return, sarray

END
