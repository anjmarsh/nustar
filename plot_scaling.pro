
;Load in scaling values for simulated thermal flare spectra,
;calculated for 2.5 - 4 keV 
restore, 'sensitivity_th2_evt4a.sav'  ;2 MK spectrum
restore, 'sensitivity_th3_evt4a.sav'  ;3 MK spectrum
restore, 'sensitivity_th4_evt4a.sav'  ;4 MK spectrum
restore, 'sensitivity_th5_evt4a.sav'  ;5 MK spectrum
restore, 'sensitivity_th6_evt4a.sav'  ;6 MK spectrum
restore, 'sensitivity_th7_evt4a.sav'  ;7 MK spectrum
restore, 'sensitivity_th8_evt4a.sav'  ;8 MK spectrum
restore, 'sensitivity_th9_evt4a.sav'  ;9 MK spectrum
restore, 'sensitivity_th10_evt4a.sav'  ;10 MK spectrum
restore, 'sensitivity_evt4a_nt.sav'  ;flat spectrum 5-10 keV

;Select on-disk events
s2 = sarray2[ones]
s3 = sarray3[ones]
s4 = sarray4[ones]
s5 = sarray5[ones]
s6 = sarray6[ones]
s7 = sarray7[ones]
s8 = sarray8[ones]
s9 = sarray9[ones]
s10 = sarray10[ones]

;Histogram the scaling values appropriately 
h2 = histogram(s2, min=min(s2)-0.5*i2,max=max(s2)+0.5*i2,binsize=i2,loc=n2)
h3 = histogram(s3, min=min(s3)-0.5*i3,max=max(s3)+0.5*i3,binsize=i3,loc=n3)
h4 = histogram(s4, min=min(s4)-0.5*i4,max=max(s4)+0.5*i4,binsize=i4,loc=n4)
h5 = histogram(s5, min=min(s5)-0.5*i5,max=max(s5)+0.5*i5,binsize=i5,loc=n5)
h6 = histogram(s6, min=min(s6)-0.5*i6,max=max(s6)+0.5*i6,binsize=i6,loc=n6)
h7 = histogram(s7, min=min(s7)-0.5*i7,max=max(s7)+0.5*i7,binsize=i7,loc=n7)
h8 = histogram(s8, min=min(s8)-0.5*i8,max=max(s8)+0.5*i8,binsize=i8,loc=n8)
h9 = histogram(s9, min=min(s9)-0.5*i9,max=max(s9)+0.5*i9,binsize=i9,loc=n9)
h10 = histogram(s10, min=min(s10)-0.5*i10,max=max(s10)+0.5*i10,binsize=i10,loc=n10)

;Plot scaling distributions 
linecolors
plot, n2, h2, psym=10, xtitle='Emission Measure',$
ytitle='# of Occurrences', title='EM Distribution - Thermal Simulations',$
xr=[1d-4, 1d-2],/xlog,yr=[0,50],charsize=1.5
oplot, n2, h2, color=2, psym=10
oplot, n3, h3, color=3, psym=10
oplot, n4, h4, color=4, psym=10
oplot, n5, h5, color=5, psym=10
oplot, n6, h6, color=6, psym=10
oplot, n7, h7, color=7, psym=10
oplot, n8, h8, color=8, psym=10
oplot, n9, h9, color=9, psym=10
oplot, n10, h10, color=10, psym=10
al_legend,['2MK','3MK','4MK','5MK','6MK','7MK','8MK','9MK','10MK'],$
color=[2,3,4,5,6,7,8,9,10],thick=[2,2,2,2,2,2,2,2,2], charsize=1.3,$
linestyle=[0,0,0,0,0,0,0,0,0], /top,/right, box=0
;write_png,'scaling_thermal.png',tvrd(/true)


;Restore simulated flare spectra to calculate EM / energy
restore, 'flare_sim_thermal.sav', /v
flare_em = [10.,1d-1,1d-1,1d-2,1d-2,1d-2,1d-2,1d-2,1d-2]   ;*1.d49

;;;;;*; EMISSION MEASURE ;*;;;;;
em2 = double(sarray2[ones]) * flare_em[0]
em3 = double(sarray3[ones]) * flare_em[1]
em4 = double(sarray4[ones]) * flare_em[2]
em5 = double(sarray5[ones]) * flare_em[3]
em6 = double(sarray6[ones]) * flare_em[4]
em7 = double(sarray7[ones]) * flare_em[5]
em8 = double(sarray8[ones]) * flare_em[6]
em9 = double(sarray9[ones]) * flare_em[7]
em10 = double(sarray10[ones]) * flare_em[8]

h2 = histogram(em2, min=min(em2)-0.5*i2*flare_em[0],max=max(em2)+0.5*i2*flare_em[0],$
binsize=i2*flare_em[0],loc=n2)
h3 = histogram(em3, min=min(em3)-0.5*i3*flare_em[1],max=max(em3)+0.5*i3*flare_em[1],$
binsize=i3*flare_em[1],loc=n3)
h4 = histogram(em4, min=min(em4)-0.5*i4*flare_em[2],max=max(em4)+0.5*i4*flare_em[2],$
binsize=i4*flare_em[2],loc=n4)
h5 = histogram(em5, min=min(em5)-0.5*i5*flare_em[3],max=max(em5)+0.5*i5*flare_em[3],$
binsize=i5*flare_em[3],loc=n5)
h6 = histogram(em6, min=min(em6)-0.5*i6*flare_em[4],max=max(em6)+0.5*i6*flare_em[4],$
binsize=i6*flare_em[4],loc=n6)
h7 = histogram(em7, min=min(em7)-0.5*i7*flare_em[5],max=max(em7)+0.5*i7*flare_em[5],$
binsize=i7*flare_em[5],loc=n7)
h8 = histogram(em8, min=min(em8)-0.5*i8*flare_em[6],max=max(em8)+0.5*i8*flare_em[6],$
binsize=i8*flare_em[6],loc=n8)
h9 = histogram(em9, min=min(em9)-0.5*i9*flare_em[7],max=max(em9)+0.5*i9*flare_em[7],$
binsize=i9*flare_em[7],loc=n9)
h10 = histogram(em10, min=min(em10)-0.5*i10*flare_em[8],max=max(em10)+0.5*i10*flare_em[8],$
binsize=i10*flare_em[8],loc=n10)

linecolors
plot, n2*1d49, h2, psym=10, xtitle='Emission Measure',$
ytitle='# of Occurrences', title='EM Distribution - Thermal Simulations',$
xr=[1d42, 1d48],/xlog,yr=[0,80],charsize=1.5
axis, x, xaxis=1, xtickname='Flare energy (ergs)',/xlog
oplot, n2*1d49, h2, color=2, psym=10
oplot, n3*1d49, h3, color=3, psym=10
oplot, n4*1d49, h4, color=4, psym=10
oplot, n5*1d49, h5, color=5, psym=10
oplot, n6*1d49, h6, color=6, psym=10
oplot, n7*1d49, h7, color=7, psym=10
oplot, n8*1d49, h8, color=8, psym=10
oplot, n9*1d49, h9, color=9, psym=10
oplot, n10*1d49, h10, color=10, psym=10
al_legend,['2MK','3MK','4MK','5MK','6MK','7MK','8MK','9MK','10MK'],$
color=[2,3,4,5,6,7,8,9,10],thick=[2,2,2,2,2,2,2,2,2], charsize=1.3,$
linestyle=[0,0,0,0,0,0,0,0,0], /top,/right, box=0
;write_png,'scaling_thermal_em.png',tvrd(/true)


;;;;;*; ENERGY IN ERGS ;*;;;;;
ergs2 = n2/flare_em[0]*total(ev*f2)*100*(max(ev)-min(ev))*1.6d-9*4*!dpi*(1.5d11)^2     
ergs3 = n3/flare_em[1]*total(ev*f3)*100*(max(ev)-min(ev))*1.6d-9*4*!dpi*(1.5d11)^2
ergs4 = n4/flare_em[2]*total(ev*f4)*100*(max(ev)-min(ev))*1.6d-9*4*!dpi*(1.5d11)^2
ergs5 = n5/flare_em[3]*total(ev*f5)*100*(max(ev)-min(ev))*1.6d-9*4*!dpi*(1.5d11)^2
ergs6 = n6/flare_em[4]*total(ev*f6)*100*(max(ev)-min(ev))*1.6d-9*4*!dpi*(1.5d11)^2
ergs7 = n7/flare_em[5]*total(ev*f7)*100*(max(ev)-min(ev))*1.6d-9*4*!dpi*(1.5d11)^2
ergs8 = n8/flare_em[6]*total(ev*f8)*100*(max(ev)-min(ev))*1.6d-9*4*!dpi*(1.5d11)^2
ergs9 = n9/flare_em[7]*total(ev*f9)*100*(max(ev)-min(ev))*1.6d-9*4*!dpi*(1.5d11)^2
ergs10 = n10/flare_em[8]*total(ev*f10)*100*(max(ev)-min(ev))*1.6d-9*4*!dpi*(1.5d11)^2

plot, ergs2, h2, psym=10, xtitle='Energy (ergs)',$
ytitle='# of Occurrences', title='Energy Distributions - Thermal Simulations',$
xr=[1d21, 1d23],/xlog,yr=[0,100],charsize=1.5
oplot, ergs2, h2, color=2, psym=10
oplot, ergs3, h3, color=3, psym=10
oplot, ergs4, h4, color=4, psym=10
oplot, ergs5, h5, color=5, psym=10
oplot, ergs6, h6, color=6, psym=10
oplot, ergs7, h7, color=7, psym=10
oplot, ergs8, h8, color=8, psym=10
oplot, ergs9, h9, color=9, psym=10
oplot, ergs10, h10, color=10, psym=10
al_legend,['2MK','3MK','4MK','5MK','6MK','7MK','8MK','9MK','10MK'],$
color=[2,3,4,5,6,7,8,9,10],thick=[2,2,2,2,2,2,2,2,2], charsize=1.3,$
linestyle=[0,0,0,0,0,0,0,0,0], /top,/right, box=0
write_png,'scaling_thermal_ergs.png',tvrd(/true)

