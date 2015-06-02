

h1a = histogram(s1a.diff_matrix, nbins=100, locations=nb1a)
h2a = histogram(s2a.diff_matrix, nbins=100, locations=nb2a)          
h3a = histogram(s3a.diff_matrix, nbins=100, locations=nb3a)
h4a = histogram(s4a.diff_matrix, nbins=100, locations=nb4a)
    
                         
plot,nb1a,h1a,xr=[-4,4],/ylog,yr=[0.1,1000],xtitle='Rdiff Value', ytitle='# of Occurrences', title='Rdiff Histograms FPMA - 2014-11-01',charsize=1.3,psym=10,thick=2
oplot,nb2a,h2a,color=3,psym=10,thick=2
oplot,nb3a,h3a,color=4,psym=10,thick=2
oplot,nb4a,h4a,color=5,psym=10,thick=2
 AL_Legend, ['AR1 (o4f1)', 'AR2 (o4f2)', 'QS1 (o4f3)', 'QS2 (o4f4)'], linestyle=[0,0,0,0], thick=[2,2,2,2], color=[1,3,4,5], charsize=1.5, position=[-3.7, 500]

write_png,'rdiff_hist_01nov2014_FPMA.png',tvrd(/true)


h1b = histogram(s1b.diff_matrix, nbins=100, locations=n1b)
h2b = histogram(s2b.diff_matrix, nbins=100, locations=n2b)
h3b = histogram(s3b.diff_matrix, nbins=100, locations=n3b)
h4b = histogram(s4b.diff_matrix, nbins=100, locations=n4b)

plot,n1b,h1b,xr=[-4,4],/ylog,psym=10,yr=[0.1,10000],thick=2,xtitle='Rdiff Value',ytitle='# of Occurrences',$                                  
title='Rdiff Histogram FPMA - 2014-11-01', charsize=1.3 
oplot,n2b,h2b,color=3,psym=10,thick=2
oplot,n3b,h3b,color=4,psym=10,thick=2
oplot,n4b,h4b,color=5,psym=10,thick=2
AL_Legend, ['AR1 (o4f1)', 'AR2 (o4f2)', 'QS1 (o4f3)', 'QS2 (o4f4)'], $
linestyle=[0,0,0,0], thick=[2,2,2,2], color=[1,3,4,5], $
charsize=1.5, position=[-3.7, 1500]
write_png,'rdiff_hist_01nov2014_FPMB.png',tvrd(/true)


sim1a = rdiff_weighted_mc(im1a)
sim2a = rdiff_weighted_mc(im2a)                     
sim3a = rdiff_weighted_mc(im3a)
sim4a = rdiff_weighted_mc(im4a)
dm1s = sim1a.dm
dm2s = sim2a.dm                                     
dm3s = sim3a.dm
dm4s = sim4a.dm
h1s = histogram(dm1s, nbins=1000, locations = n1s)
h2s = histogram(dm2s, nbins = 1000, locations = n2s)
h3s = histogram(dm3s, nbins = 1000, locations = n3s) 
h4s = histogram(dm4s, nbins = 1000, locations = n4s)
wset,1
plot,n1s,h1s,color=1,xr=[-4,4]                   
oplot,n2s,h2s,color=3,psym=10         
oplot,n3s,h3s,color=4,psym=10         
oplot,n4s,h4s,color=5,psym=10         
help,h1a,h2a,h3a,h4a
H1A             LONG      = Array[1000]
H2A             LONG      = Array[1000]
H3A             LONG      = Array[1000]
H4A             LONG      = Array[1000]
print,total(h1a)
      5850.00
print,total(h2a)
      5400.00
print,total(h3a)
      5400.00
print,total(h4a)
      5850.00
help,im1a
IM1A            LONG      = Array[15, 15, 26]
help,im2a
IM2A            LONG      = Array[15, 15, 24]
print,total(im1a),total(im2a),total(im3a),total(im4a)
      277459.      250273.      249559.      267318.

plot,n1s,h1s,color=1,xr=[-4,4],yr=[0,1d5],xtitle='Rdiff Value',ytitle='# of Occurrences',title='Rdiff Weighted Monte-Carlo - 2014-11-01',charsize=1.3  
   
aL_legend, ['AR1 (o4f1)', 'AR2 (o4f2)', 'QS1 (o4f3)', 'QS2 (o4f4)'], linestyle=[0,0,0,0], thick=[2,2,2,2], color=[1,3,4,5], charsize=1.5, /top, /left

oplot,n2s,h2s,color=3
oplot,n3s,h3s,color=4
oplot,n4s,h4s,color=5
$emacs make_rdiff_plots.pro &

write_png,'rdiff_sim_01nov2014.png',tvrd(/true)

;;;Run without the edge pixels. Shoud narrow the distributions

restore,'ar2192_imcube_dm_all.sav',/ver
help,im4a             
IM4A            LONG      = Array[15, 15, 26]
im4a_ne = im4a[1:13,1:13,*]
help,im3a  
IM3A            LONG      = Array[15, 15, 24]
im3a_ne = im3a[1:13,1:13,*]
help,im2a
IM2A            LONG      = Array[15, 15, 24]
im2a_ne = im2a[1:13,1:13,*]
help,im1a
IM1A            LONG      = Array[15, 15, 26]
im1a_ne = im1a[1:13,1:13,*]


t4a_ne = transient_search(im4a_ne)
t3a_ne = transient_search(im3a_ne)
t2a_ne = transient_search(im2a_ne)
t1a_ne = transient_search(im1a_ne)

dm4a_ne = t4a_ne.diff_matrix
dm3a_ne = t3a_ne.diff_matrix
dm2a_ne = t2a_ne.diff_matrix
dm1a_ne = t1a_ne.diff_matrix

h4a_ne = histogram(dm4a_ne, nbins=100, locations=ne4a)
h3a_ne = histogram(dm3a_ne, nbins=100, locations=ne3a)
h2a_ne = histogram(dm2a_ne, nbins=100, locations=ne2a)
h1a_ne = histogram(dm1a_ne, nbins=100, locations=ne1a)

window,3,retain=2
!p.multi=0
hsi_linecolors
plot,ne1a,h1a_ne,psym=10,xr=[-4,4],thick=2,/ylog,yr=[0.1,1000],$
xtitle='Rdiff Value', ytitle='# of Occurrences',$
title='Rdiff Histograms FPMA, No Edges - 2014-11-01',charsize=1.3
oplot,ne2a,h2a_ne,psym=10,thick=2,color=3
oplot,ne3a,h3a_ne,psym=10,thick=2,color=4
oplot,ne4a,h4a_ne,psym=10,thick=2,color=5
aL_legend, ['AR1 (o4f1)', 'AR2 (o4f2)', 'QS1 (o4f3)', 'QS2 (o4f4)'], linestyle=[0,0,0,0], thick=[2,2,2,2], color=[1,3,4,5], charsize=1.5, /top, /left
