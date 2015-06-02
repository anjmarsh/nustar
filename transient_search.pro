function transient_search, imcube

;;Execute a search for transient brightenings

xn = (size(imcube))[1]
yn = (size(imcube))[2]
tn = (size(imcube))[3]

r1 = fltarr(xn,yn,tn)
p1 = r1
r2 = fltarr(xn,yn,tn)
p2 = r2
r3 = fltarr(xn,yn,tn)
p3 = r3
rdiff = fltarr(xn,yn,tn)
diff = rdiff
ediff = fltarr(xn,yn,tn)

cmin = fltarr(tn)
cmax = fltarr(tn)
rmin = fltarr(tn)
rmax = fltarr(tn)
h = fltarr(tn)

for t=0,tn-1 do begin

   ii = where( imcube[*,*,t] gt 0 )
   aa = array_indices( imcube[*,*,t], ii )
   cmin[t] = min( aa[0,*] )
   cmax[t] = max( aa[0,*] )
   rmin[t] = min( aa[1,*] )
   rmax[t] = max( aa[1,*] )

   r1[*,*,t] = pixel_ratios2( imcube[*,*,t], xn, yn )
   p1[*,*,t] = pixel_select( imcube[*,*,t], xn, yn )
         
   if t eq 0 then begin
      r2[*,*,t] = pixel_ratios2( imcube[*,*,t+1], xn, yn )
      p2[*,*,t] = pixel_select( imcube[*,*,t+1], xn, yn )
   endif

     if (t gt 0) and (t lt tn-1) then begin
        r2[*,*,t] = pixel_ratios2( imcube[*,*,t+1], xn, yn )
        r3[*,*,t] = pixel_ratios2( imcube[*,*,t-1], xn, yn )
	p2[*,*,t] = pixel_select( imcube[*,*,t+1], xn, yn )
	p3[*,*,t] = pixel_select( imcube[*,*,t-1], xn, yn )
     endif
        
     if t eq tn-1 then begin
         r2[*,*,t] = pixel_ratios2( imcube[*,*,t-1], xn, yn )
	 p2[*,*,t] = pixel_select( imcube[*,*,t-1], xn, yn ) 
     endif

   if total(r3[*,*,t]) ne 0 then begin
      rdiff[*,*,t] = r1[*,*,t] - ((r2[*,*,t] + r3[*,*,t]) / 2.)
   endif else begin
      rdiff[*,*,t] = r1[*,*,t] - r2[*,*,t]
   endelse

   if total(p3[*,*,t]) ne 0 then begin
	diff[*,*,t] = p1[*,*,t] - ((p2[*,*,t] + p3[*,*,t]) / 2.)
   endif else begin
	diff[*,*,t] = p1[*,*,t] - p2[*,*,t]
     endelse

   rmom = rdiff[*,*,t]
   n1 = where( finite(rmom) eq 0 )
   if isarray(n1) gt 0 then begin 
      for n=0,n_elements(n1)-1 do begin
         rmom(n1) = 0 
      endfor
   endif

   pmom = diff[*,*,t]
   m1 = where( finite(pmom) eq 0 ) 
   if isarray(m1) gt 0 then begin
	for m=0,n_elements(m1)-1 do begin
	   pmom(m1) = 0
	endfor
   endif


   rdiff[*,*,t] = rmom
   diff[*,*,t] = pmom

 
endfor

rstruct = create_struct( 'rdiff_matrix',rdiff, 'diff_matrix',diff,$
                         'r1',r1,'r2',r2,'r3',r3,$
                         'p1',p1,'p2',p2,'p3',p3,$
                         'cmin',cmin,'cmax',cmax,$
                         'rmin',rmin,'rmax',rmax )

return, rstruct

end



