pro flare_sim_5MK

ev5 = 1.6 + 0.04*findgen(4096)
e5 = get_edges(/edges_2, ev5)

;T = 5.0 MK, EM = 1e46 cm-3
f5 = f_vth(e5,[1.0d-3,5.0/11.6,1])

plot, ev5, f5, /ylog, /xlog, xr=[1,30],$
yr = [1d-4, 1d7], xtitle='Energy (keV)'

save, e5, ev5, f5, filename='flare_sim_5MK.sav'

end
