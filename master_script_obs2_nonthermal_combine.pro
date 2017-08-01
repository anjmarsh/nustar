; Load Poisson databases if desired

;*** Run for DWELL=30,60,100s and create arrays for each ***;

flux_30s = obs2_nonthermal_combine(dwell=30., ondisk=ondisk_30s)
flux_30s_right = obs2_nonthermal_combine(dwell=30., /shift_right)

flux_60s = obs2_nonthermal_combine(dwell=60., ondisk=ondisk_60s)
flux_60s_right = obs2_nonthermal_combine(dwell=60., /shift_right)

flux_100s = obs2_nonthermal_combine(dwell=100., ondisk=ondisk_100s)
flux_100s_right = obs2_nonthermal_combine(dwell=100., /shift_right)

save, flux_30s, flux_30s_right, ondisk_30s, file='flux_arrays_30s_new_threshold_mask.sav'
save, flux_60s, flux_60s_right, ondisk_60s, file='flux_arrays_60s_new_threshold_mask.sav'
save, flux_100s, flux_100s_right, ondisk_100s, file='flux_arrays_100s_new_threshold_mask.sav'
restore, 'flux_arrays_30s_new_threshold_mask.sav'
restore, 'flux_arrays_60s_new_threshold_mask.sav'
restore, 'flux_arrays_100s_new_threshold_mask.sav'

; Combine and bin the flux arrays
;30 s
fluxcube_30s = [reform(flux_30s.fluxcube[ondisk_30s], n_elements(flux_30s.fluxcube[ondisk_30s])),$
reform(flux_30s_right.fluxcube[ondisk_30s], n_elements(flux_30s_right.fluxcube[ondisk_30s]))]

nbins = 10
hist_30s = histogram(fluxcube_30s, min=min(fluxcube_30s), max=max(fluxcube_30s), $
nbins=nbins, locations=bins_30s)

;60s
fluxcube_60s = [reform(flux_60s.fluxcube[ondisk_60s], n_elements(flux_60s.fluxcube[ondisk_60s])),$
reform(flux_60s_right.fluxcube[ondisk_60s], n_elements(flux_60s_right.fluxcube[ondisk_60s]))]

hist_60s = histogram(fluxcube_60s, min=min(fluxcube_60s), max=max(fluxcube_60s), $
nbins=nbins, locations=bins_60s)

;100s
fluxcube_100s = [reform(flux_100s.fluxcube[ondisk_100s], n_elements(flux_100s.fluxcube[ondisk_100s])),$
reform(flux_100s_right.fluxcube[ondisk_100s], n_elements(flux_100s_right.fluxcube[ondisk_100s]))]

hist_100s = histogram(fluxcube_100s, min=min(fluxcube_100s), max=max(fluxcube_100s), $
nbins=nbins, locations=bins_100s)

;Add zeros to both sides of histogram so that curve goes down to x-axis
bins_30s = [2*bins_30s[0]-bins_30s[1], bins_30s, bins_30s(n_elements(bins_30s)-1)+bins_30s[1]-bins_30s[0]]
hist_30s = [0, hist_30s, 0]
bins_60s = [2*bins_60s[0]-bins_60s[1], bins_60s, bins_60s(n_elements(bins_60s)-1)+bins_60s[1]-bins_60s[0]]
hist_60s = [0, hist_60s, 0]
bins_100s = [2*bins_100s[0]-bins_100s[1], bins_100s, bins_100s(n_elements(bins_100s)-1)+bins_100s[1]-bins_100s[0]]
hist_100s = [0, hist_100s, 0]

;Set up PS file
cgps_open, 'flux_dist_nov2014_qs_combine_shift_alldwells_micflare_avg_new_threshold_grades_mask.eps', /encaps, keywords=keywords
loadct, 2
plot, bins_30s, hist_30s, psy=10, xr=[1d-5, 1d1], $
xtitle='Photon Flux (ph/cm!U2!N/s/keV)', ytitle='Frequency', $
/xlog, xtickf='exp1', charsize=1.2, charthick=1.3,  thick=4, $
yr=[0, max(hist_30s)*1.1]

colors = [10, 100, 240, 100, 0]
oplot, bins_30s, hist_30s, psy=10, thick=6, color=colors[0]
oplot, bins_60s, hist_60s, psy=10, thick=6, color=colors[1]
oplot, bins_100s, hist_100s, psy=10, thick=6, color=colors[2]
plots, [1.4d-3, 1.4d-3], [!Y.CRange[0], !Y.CRange[1]], linestyle=2, color=colors[3]
plots, [1.17, 1.17], [!Y.CRange[0], !Y.CRange[1]], linestyle=1, color=colors[4]

al_legend, ['Dwell = 30s','Dwell = 60s','Dwell = 100s','RHESSI 60s Detection Limit','Avg. RHESSI Microflare'],$
 color=colors,linestyle=[0,0,0,2,1], charsi=1, thick=6, box=0, position=[1.5e-3, 1100]

cgps_close

$evince flux_dist_nov2014_qs_combine_shift_alldwells_micflare_avg_new_threshold_grades_mask.eps &
