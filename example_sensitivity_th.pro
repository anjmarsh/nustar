;*;*;*;*;*
;
;How to generate an image cube and use the script sensitivity_th_low to
;determine the scalings needed to reach "just detectable" levels for
;2.5-4 keV. 
;
;
;"Just detectable" defined as the scaling at which inserting a flare gives a
;max(diff_matrix) value 2 times max(diff_matrix) for the non-flaring case


restore, 'evtfiles.sav' , /ver
;Use data from Obs2, Orbit 4, Field 4; QS pointing
;Other users will need to Edit evt4a to point to Correct Directory
print, evt4a
print, strmid(evt4a, 31)   ;NuSTAR event directory

;Make image cube of event file, dwell=100s, pixel=58", E=2.5-4 keV
im_th = make_imcube(evt4a, 100, 58, erange=[2.5,4])
imc_th = im_th.imcube

tth = transient_search(imc_th)  ;run transient search
dm_th = tth.diff_matrix   ;diff parameter
pmm, dm_th

;Plot distribution of the diff parameter (for non-flaring case)
h_th = histogram(dm_th, nbins=50, locations=n_th)
window,0,retain=2
plot, n_th, h_th, psym=10, thick=2, /ylog, yr=[1,1000],$
xtitle='Diff Value',ytitle='# of Occurrences',$
title='Diff Distribution, No Flare' 


;;Add flare to original image cube, see how diff distribution changes 
si = 0.1  ;set initial scaling
ai = add_flare2(imc_th, 0, scale=si, erange=[2.5,4])  ;add flare to imcube
ti = transient_search(ai)   ;run transient search
dmi = ti.diff_matrix    ;diff parameter
pmm, dmi

;Plot distribution of the diff parameter (with flare added)
h = histogram(dmi, nbins=50, locations=n)
window,1,retain=2
plot, n, h, psym=10, thick=2, /ylog, yr=[1,1000],$ 
xtitle='Diff Value',ytitle='# of Occurrences',$
title='Diff Distribution, with Flare' 



;;Sensitivity calculation for 2MK input spectrum. Every pixel, every
;;frame (takes a long time to run)
sarray2 = sensitivity_th2(imc_th)
;sarray3 = sensitivity_th3(imc_th)  ;3MK spectrum
;sarray4 = sensitivity_th4(imc_th)  ;4MK spectrum
;sarray5 = sensitivity_th5(imc_th)  ;5MK spectrum
;sarray6 = sensitivity_th6(imc_th)  ;6MK spectrum
;sarray7 = sensitivity_th7(imc_th)  ;7MK spectrum
;sarray8 = sensitivity_th8(imc_th)  ;8MK spectrum
;sarray9 = sensitivity_th9(imc_th)  ;9MK spectrum
;sarray10 = sensitivity_th10(imc_th)  ;10MK spectrum

;Find on-disk positions in the image cube 
tod = imc_th[*,*,0]
for i=0,n_elements(tod)-1 do tod[i] = test_ondisk(im_th, array_indices(tod,i))

;Print average scaling for on-disk pixels
ones = where(tod ne 0) 
print, average(sarray2[ones])

;If you want to go straight to looking at the results, you can use
;this handy .sav file that I already made! As mentioned,
;sensitivity_th2 will take awhile to run and you may not want to wait 

restore,'sensitivity_th2_evt4a.sav',/v   ;restore scaling array

restore,'flare_sim_thermal.sav',/v   ;restore simulated flare spectra

plot, ev, f2, /ylog, yr=[0.01, 1d6], xr=[1,10],$
xtitle='Energy (keV)',ytitle='Photon Flux',title='2MK Thermal Spectrum'

ergs2 = double(sarray2[ones])*total(ev*f2)*100*(max(ev)-min(ev))*1.6d-9*4*!dpi*(1.5d11)^2   ;Energy in ergs 
e2 = i2*100*(max(ev)-min(ev))*1.6d-9*4*!dpi*(1.5d11)^2   ;discrete increments
h2 = histogram(ergs2, min=min(ergs2)-0.5*e2,max=max(ergs2)+0.5*e2,$
binsize=e2,loc=n2)  ;histogram with e2 binning

plot, n2, h2, /xlog, xr=[1d21, 1d23], yr=[0,80], psym=10,xtitle='Energy (ergs)',$
ytitle='# of Occurrences',title='Energy Distribution - Thermal Simulations',$
charsize=1.5

;for full set of plots look at PLOT_SCALING.PRO
