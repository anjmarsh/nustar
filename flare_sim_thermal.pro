pro flare_sim_thermal

ev = 1.6 + 0.04*findgen(1960)
e = get_edges(/edges_2, ev)

;T = 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 MK, EM = 1d49, 1d48, 1d47 cm3
;f0 = f_vth(e,[1.0d-1,0.5/11.6,1])
f1 = f_vth(e,[1d5,1.01/11.6,1])
f2 = f_vth(e,[10.,2.0/11.6,1])
f3 = f_vth(e,[1.0d-1,3.0/11.6,1])
f4 = f_vth(e,[1.0d-1,4.0/11.6,1])
f5 = f_vth(e,[1.0d-2,5.0/11.6,1])
f6 = f_vth(e,[1.0d-2,6.0/11.6,1])
f7 = f_vth(e,[1.0d-2,7.0/11.6,1])
f8 = f_vth(e,[1.0d-2,8.0/11.6,1])
f9 = f_vth(e,[1.0d-2,9.0/11.6,1])
f10 = f_vth(e,[1.0d-2,10.0/11.6,1])


linecolors
plot, ev, f1, /ylog, /xlog, xr=[1,30], yr = [1d-4, 1d7],$
xtitle='Energy (keV)',ytitle='Flux (ph/cm2/s/keV)',$
title='Thermal Spectra 2-10 MK, EM = 1d48', charsize=1.3
oplot, ev, f2, color=2
oplot, ev, f3, color=3
oplot, ev, f4, color=4
oplot, ev, f5, color=5
oplot, ev, f6, color=6
oplot, ev, f7, color=7
oplot, ev, f8, color=8
oplot, ev, f9, color=9
oplot, ev, f10, color=10


save, ev, e, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, filename='flare_sim_thermal.sav'

end
