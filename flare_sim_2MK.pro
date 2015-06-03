pro flare_sim_2MK

ev2 = 1.6 + 0.04*findgen(4096)
e2 = get_edges(/edges_2, ev2)

;T = 2.0 MK, EM = 1e48 cm-3
f2 = f_vth(e2,[1.0d-1,2.0/11.6,1])

plot, ev2, f2, /ylog, /xlog, xr=[1,30],$
yr = [1d-4, 1d7], xtitle='Energy (keV)'

save, e2, ev2, f2, filename='flare_sim_2MK.sav'

end
