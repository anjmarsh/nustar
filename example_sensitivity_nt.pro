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
im_nt = make_imcube(evt4a, 10, 58, erange=[5,10])
imc_nt = im_nt.imcube

tnt = transient_search(imc_nt)
dm_nt = tnt.diff_matrix 
pmm, dm_nt

si = 0.01
ai = add_flare_nt(imc_nt, 0, scale=si, erange=[5,10])
ti = transient_search(ai) 
dmi = ti.diff_matrix 
pmm, dmi

sarray = sensitivity_nt(im_nt, 0)
;restore, sensitivity_evt4a_nt.sav

;Find on-disk positions in the image cube 
tod = imc_nt[*,*,0]
for i=0,n_elements(tod)-1 do begin 
   tod[i] = test_ondisk(im_nt, array_indices(tod,i))
endfor

;Print average scaling for on-disk pixels
ones = where(tod ne 0) 
print, average(sarray[ones])
