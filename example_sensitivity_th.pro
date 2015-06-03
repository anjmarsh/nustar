;Example script 
;
;How to generate an image cube and use the script sensitivity_th_low to
;determine the scalings needed to reach "just detectable" levels for
;2.5-4 keV. 
;
;This example is for a 2MK input spectrum, and uses the script
;sensitivity_low_th 
;
;What is meant by "just detectable" ? 
;Currently defined as the scaling at which inserting a flare gives a
;max(diff_matrix) value 2 times max(diff_matrix) for the non-flaring case

restore, 'evtfiles.sav' , /ver
;Use data from Obs2, Orbit 4 Field 4 - NP quiet-Sun pointing
;Other users will need to edit string to point to correct directory
print, evt4a
im_th = make_imcube(evt4a, 100, 58, erange=[2.5,4])
imc_th = im_th.imcube

tth = transient_search(imc_th)
dm_th = tth.diff_matrix 
pmm, dm_th

;Look at the distribution of the diff parameter (for non-flaring case)
h_th = histogram(dm_th, nbins=50, locations=n_th)
window,0,retain=2
plot, n_th, h_th, psym=10, thick=2, /ylog, yr=[1,1000],$
xtitle='Diff Value',ytitle='# of Occurrences',$
title='Diff Distribution, No Flare' 


;;Add one flare to image, see how distribution changes 
si = 0.1  ;set initial scaling
ai = add_flare2(imc_th, 0, scale=si, erange=[2.5,4])  ;add flare to imcube
ti = transient_search(ai) 
dmi = ti.diff_matrix 
pmm, dmi

;Look at the distribution of the diff parameter (with flare added in)
h = histogram(dmi, nbins=50, locations=n)
window,1,retain=2
plot, n, h, psym=10, thick=2, /ylog, yr=[1,1000],$ 
xtitle='Diff Value',ytitle='# of Occurrences',$
title='Diff Distribution, with Flare' 


;;Sensitivity calculation for 2MK input spectrum. Every pixel, every
;;frame (takes a long time to run)
sarray = sensitivity_th_low(im_th)

;;Sensitivity calculation for 5MK input spectrum
;;sarray = sensitivity_th_high(im_th,0)

;Find on-disk positions in the image cube 
tod = imc_th[*,*,0]
for i=0,n_elements(tod)-1 do begin 
   tod[i] = test_ondisk(im_th, array_indices(tod,i))
endfor

;Print average scaling for on-disk pixels
ones = where(tod ne 0) 
print, average(sarray[ones])
