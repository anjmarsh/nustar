;+
; NAME:
;    CALC_DIFF_IMCUBE
;PURPOSE: 
;    Look at count variations for each pixel in an input NuSTAR image
;    cube; calculate "ratio of differences" statistic  that can point 
;    to transient events.    
;INPUTS:
;   Image cube
;OUTPUTS:
;     Diff_matrix - A matrix of count difference values (defined below)
;       For every frame except the first and last, we have:
;           Diff = N1 - avg(N2, N3)
;           N1 = Number of counts at time 't'
;           N2 = Number of counts at time 't+1'
;           N3 = Number of coutns at time 't-1' 
;       For the first and last frames, we define 
;           Diff = N1 - N2, and Diff = N1 - N3

function calc_diff_imcube, imcube

xn = (size(imcube))[1]
yn = (size(imcube))[2]
tn = (size(imcube))[3]

p1 = fltarr(xn,yn,tn)
p2 = fltarr(xn,yn,tn)
p3 = fltarr(xn,yn,tn)
diff = fltarr(xn,yn,tn)

for t=0,tn-1 do begin

   p1[*,*,t] = imcube[*,*,t]
         
   if t eq 0 then begin
      p2[*,*,t] = imcube[*,*,t+1]
   endif

     if (t gt 0) and (t lt tn-1) then begin
	p2[*,*,t] = imcube[*,*,t+1]
	p3[*,*,t] = imcube[*,*,t-1]
     endif
        
     if t eq tn-1 then begin
	 p2[*,*,t] = imcube[*,*,t-1]
     endif

   if total(p3[*,*,t]) ne 0 then begin
	diff[*,*,t] = p1[*,*,t] - ((p2[*,*,t] + p3[*,*,t]) / 2.)
   endif else begin
	diff[*,*,t] = p1[*,*,t] - p2[*,*,t]
     endelse

 
endfor


return, diff


END
