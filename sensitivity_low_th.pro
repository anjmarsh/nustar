function sensitivity_low_th, im, frame=frame

SetDefaultValue, frame, 0

dwell_th = 100
pix_size = 58
erange = [2.5,4]

ima = im.imcube
ta = transient_search(ima)
da = ta.diff_matrix 
maxa = max(da) ;diff_max for no-flare case

xlen = (size(ima))[1]
ylen = (size(ima))[2]
n_frames = (size(ima))[3]
sarray = float( ima * 0)

;figure out correct flare pixel indices
si = 0.5
ai = add_flare_2MK(ima, frame, scale=si, pix_size=pix_size, erange=erange)

w = where( ai[*,*,frame] eq max(ai[*,*,frame]) )
flare_peak = array_indices( ai[*,*,frame], w )

xshiftpos = xlen - flare_peak[0]
yshiftpos = ylen - flare_peak[1]

;test scaling for every pixel in every frame

for frame=0,n_frames-1 do begin
for xshift = -flare_peak[0], xshiftpos-1 do begin
   for yshift = -flare_peak[1], yshiftpos-1 do begin 
      
      si = 0.5  ;initial scaling
      ai = add_flare_2MK(ima, frame, scale=si, pix_size=pix_size, move=[xshift,yshift], erange=erange)
      ti = transient_search(ai) 
      dfi = ti.diff_matrix 
      maxdi = max(dfi) ;initial diff_max

      while (maxdi GT 2*maxa) do begin  ;loop until max = 2*noflare_diff_max
         si = si - 0.01 ;scale down in 0.01 increments
         af = add_flare_2MK(ima, frame, scale=si, pix_size=pix_size, move=[xshift,yshift], erange=erange)
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
