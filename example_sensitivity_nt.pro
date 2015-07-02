;Example script 
;
;How to generate an image cube and use the script sensitivity_nt to
;determine the scalings needed to reach "just detectable" levels for
;5-10 keV. 
;
;What is meant by "just detectable" ? 
;Currently defined as the scaling at which inserting a flare gives a
;max(diff_matrix) value 2 times max(diff_matrix) for the non-flaring case

restore, 'evtfiles.sav' , /ver
;Use data from Obs2, Orbit 4 Field 4 - NP quiet-Sun pointing
im_nt = make_imcube(evt4a, 10, 58, erange=[5,10])
imc_nt = im_nt.imcube

tnt = transient_search(imc_nt)
dm_nt = tnt.diff_matrix 
pmm, dm_nt

;Look at the distribution of the diff parameter (for non-flaring case)
h_nt = histogram(dm_nt, nbins=50, locations=n_nt)
plot, n_nt, h_nt, psym=10, thick=2, /ylog, yr=[1,1000],$
xtitle='Diff Value',ytitle='# of Occurrences',$
title='Diff Distribution, No Flare' 

si = 0.01
ai = add_flare_nt(imc_nt, 0, scale=si, erange=[5,10])
ti = transient_search(ai) 
dmi = ti.diff_matrix 
pmm, dmi

;Look at the distribution of the diff parameter (with flare added in)
h = histogram(dmi, nbins=50, locations=n)
plot, n, h, psym=10, thick=2, /ylog, yr=[1,1000],$
xtitle='Diff Value',ytitle='# of Occurrences',$
title='Diff Distribution, with Flare' 

sarray = sensitivity_nt(imc_nt, 0)

;Find on-disk positions in the image cube 
tod = imc_nt[*,*,0]
for i=0,n_elements(tod)-1 do begin 
   tod[i] = test_ondisk(im_nt, array_indices(tod,i))
endfor

;Print average scaling for on-disk pixels
ones = where(tod ne 0) 
print, average(sarray[ones])
