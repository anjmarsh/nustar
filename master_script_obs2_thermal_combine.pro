; Calculate detectable EM arrays for the combination of NuSTAR
; telescopes (FPMA & FPMB). Generate paper figures 

; Combined EM array with no shift, no exclusion
em_array = obs2_thermal_combine(ondisk=ondisk, xshift=105, yshift=65)
save, em_array, ondisk, file='em_array_new_threshold_12MK_grades_mask.sav'

; Combined EM array with right shift 
em_array_right = obs2_thermal_combine(/shift_right, xshift=105, yshift=65)
save, em_array_right, file='em_array_right_new_threshold_12MK_grades_mask.sav'

; Combine and bin the EM arrays
nbins = 10
.r
FOR n=0, n_elements(em_array)-1 DO BEGIN
   emcube = [reform(em_array[n].emcube[ondisk], n_elements(em_array[n].emcube[ondisk])),$
   reform(em_array_right[n].emcube[ondisk], n_elements(em_array_right[n].emcube[ondisk]))]

   hist = histogram(emcube, min=min(emcube), max=max(emcube), $
   nbins=nbins, locations=bins)

   IF n eq 0 THEN BEGIN
      em_struct = {emcube:emcube, hist:hist, bins:bins}
      em_struct = replicate(em_struct,n_elements(em_array))
   ENDIF ELSE BEGIN
      em_struct[n].emcube = emcube 
      em_struct[n].hist = hist
      em_struct[n].bins = bins
   ENDELSE
ENDFOR
end

em_struct_new = add_tag(em_struct, fltarr(n_elements(bins)+2), 'newbins')
em_struct_new = add_tag(em_struct_new, fltarr(n_elements(hist)+2), 'newhist')

;Add zeros to both sides of histogram so that curve goes down to x-axis
.r
FOR i=0, n_elements(em_struct)-1 DO BEGIN
   em_struct_new[i].newbins = [2*em_struct[i].bins[0]-em_struct[i].bins[1], em_struct[i].bins, $
                        em_struct[i].bins(n_elements(em_struct[i].bins)-1)+em_struct[i].bins[1]-em_struct[i].bins[0]]
   em_struct_new[i].newhist = [0, em_struct[i].hist, 0]
ENDFOR
end

;Plot the EM distributions using shifted AND unshifted data
cgps_open, 'em_dist_nov2014_ondisk_combine_shift_new_threshold_12MK_zeroed_grades_mask.eps', $
/encaps, ysize=5.2
linecolors
plot, alog10(1d49 * em_struct_new[0].newbins), em_struct_new[0].newhist, psy=10, xr=[42, 50], $
xtitle='Log!D10!N(Emission Measure)', charsize=1.3, charthick=1.3, thick=4, $
ytitle='Frequency', yr=[0,1.3*max(hist)]
.r
FOR n=0, n_elements(em_array)-1 DO BEGIN
   oplot, alog10(1d49 * em_struct_new[n].newbins), em_struct_new[n].newhist, psy=10, thick=4, color=n+2
ENDFOR
end
al_legend, ['2MK', '3MK', '4MK', '5MK', '6MK', '7MK', '8MK', '9MK', '10MK','11MK','12MK'], $
box=0, linestyle=0, thick=4, position=[48.,350.], charsi=1.1, linsize=0.6, $
color=[2,3,4,5,6,7,8,9,10,11,12]
cgps_close

;Plot sensitivity curve using EM distribution peaks
cgps_open, 'nustar_plus_sensitivity_nov2014_ondisk_combine_shift_new_threshold_12MK_grades_mask.eps',$
/encaps, ysize=5.2
peak_em = double(em_array[0].temp)

FOR n=0, n_elements(peak_em)-1 DO $
   peak_em[n] = em_array[n].bins(where(em_array[n].hist eq max(em_array[n].hist)))*1d49

plot, em_array[0].temp, alog10(peak_em), yr=[40, 48], xr=[0,13], psym=4,thick=3, $
  xtitle='Temperature (MK)',ytitle='Log!D10!N(Emission Measure)',/xs,charsize=1.3

;Add in T/EM range from Sam's 1997 network flares paper
cgpolygon, [1.1, 1.6, 1.6, 1.1, 1.1], [alog10(4d44), alog10(4d44), alog10(8d45),$
   alog10(8d45), alog10(4d44)], color='red'
cgcolorfill, [1.1, 1.6, 1.6, 1.1, 1.1], [alog10(4d44), alog10(4d44), alog10(8d45),$
   alog10(8d45), alog10(4d44)], color='red', /line_fill

;Add in T/EM upper limits from Sam's 2001 draft paper 
plotsym, 1, 3, thick=4
linecolors
oplot, [3,5], [alog10(8d45 / 180.), alog10(8d45 / 320.)], psym=8, color=1
oplot, [2.7, 3.3], [alog10(8d45 / 180.), alog10(8d45 / 180.)], color=1
oplot, [4.7, 5.3], [alog10(8d45 / 320.), alog10(8d45 / 320.)], color=1

;Add in Iain's 10 cts/s/det contour from Fig. 13 of Iain's microflare
;paper. 
 cnt=100.
 cnem=100.
 tr=5+20*findgen(cnt)/(cnt-1.)
 emr=10^(-5+4*findgen(cnem)/(cnem-1.))
 ct=tr
 cem=emr*1d49
 restgen,file='~/nustar/solar/20141101_data/fl_48',fl_ct
 contour,fl_ct/10.,ct,alog10(cem),levels=[10],c_labels=[1], /over, color=3

al_legend, ['NuSTAR (FPMA+FPMB)','RHESSI (Hannah et al. 2008)', 'Yohkoh Network Flares (Krucker et al. 1997)', $
  'Yohkoh Upper Limits'], /bottom, /left, box=0, charsize=1.0, linsize=0.5, $
   linestyle=0, color=[0,3,2,1], thick=4, psym=[4, 0, 6, 8]

;Add in horizontal line on top of legend arrow
oplot, [0.6, 1.2], [40.58, 40.58], color=1

cgps_close
