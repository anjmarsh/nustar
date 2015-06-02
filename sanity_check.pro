;+
; NAME:
;    SANITY_CHECK
; PURPOSE:
;    ROM estimate of NuSTAR limiting microflarem
; CATEGORY:
; CALLING SEQUENCE:
;    main program
; INPUTS:
;    needs the right .evt and .hk files in the working directory:
;      nu20012004002A_fpm.hk
;      nu20012004002A06_cl_sunpos.evt
; OPTIONAL (KEYWORD) INPUT PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; MODIFICATION HISTORY:
; IDL Version 7.0, Mac OS X (darwin i386 m32)
; Journal File for hughhudson@Macintosh-00254bc9f6e8-2.local
; Working directory: /Users/hughhudson/Desktop/projects/2015/nustar
; Date: Sun Apr 12 20:17:15 2015
;       23-Apr-15, added the NFU calculation
;-

thick = 1 & xthick = 1 & ythick = 1 & charthick = 1
if !d.name eq 'PS' then !p.font = 0 else !p.font = -1
if !D.name eq 'PS' then begin
  thick=5 & xthick=5 & ythick=5 & charthick = 3
  device,/encapsulate,bits=8,file='sanity.eps'
  device,/color
endif
 
infil = file_search('*sunpos.evt')
a = mrdfits(infil[0],1,h1)
d1=where(a.det_id eq 1)
tt = anytim(a.time)+anytim('1-jan-10')
fmt_timer,tt,t1,t2 
timer = [t1,'1-nov-14 22:28']
ee = 1.62+0.04*a.pi
infhk = file_search('*fpm.hk')
hk = mrdfits(infhk[0],1,hkh1)
hk = hk[0:796]
tthk = anytim(hk.time)+anytim('1-jan-10')

flux = histogram(tt)/hk.livetime
mom = moment(flux[60:119])
print, mom[0], sqrt(mom[1])
plot_io,findgen(796),flux,psym=1,xr=[60,119],yr=[10,1e5],$
  xtit = 'Time, seconds', ytit='Rate, counts/s',$
  tit = '1-November_2014 22:14:52 UT',$
  thick=thick, xthick=xthick, ythick=ythick, charthick=charthick
for i = 0, 795 do oplot,fix([i,i]),[0.95,1.05]*flux[i]
ss3 = where(ee gt 3. and ee lt 5.)
flux3 = histogram(tt[ss3])/hk.livetime
mom3 = moment(flux3[60:119])
print,mom3[0],sqrt(mom3[1])
oplot,findgen(796),flux3,psym=2,thick=thick
ss5 = where(ee gt 5.)
flux5 = histogram(tt[ss5])/hk.livetime
mom5 = moment(flux5[60:119])
print,mom5[0],sqrt(mom5[1])
oplot,findgen(796),flux5,psym=4, thick=thick
al_legend,['Total','3-5 keV','>5 keV'],psym=[-1,-2,-4]

if !D.name eq 'PS' then device,/close 

area = 150.
print,'area',area,' cm^2'
livetime = mean(hk[60:119].livetime)
print,'livetime',livetime,' s'
hpbw_factor = 1. / 144.
print,'hpbw_factor',hpbw_factor
erg_factor = 1.6d-9 * 3 * 2.8d27
print,'erg_factor',erg_factor,' erg cm^2'
lbollx_factor = 150
print,'lbollx_factor',lbollx_factor
print,' '

dt = [1.,10.,100.,1000.]
format = '(f8.0,3e10.2,2e13.2)'
print,'Delta T   Counts/s   Error     X-ray ergs    GOES'
for i = 0, 3 do begin
  counts = mom[0] * hpbw_factor * livetime * dt[i]     ; background counts
  ecounts = sqrt(counts) / dt[i] / area / livetime   ; error flux 
  eergs = 10 * ecounts * dt[i] * erg_factor   ; 10 sigma ergs at Sun 
  goes = eergs / dt[i] / 2 / !pi /(1.5d11)^2 * 1d-7 ; W/m^2
  print,dt[i],counts,ecounts,eergs,goes,format=format
endfor
print,' '
print,'GOES A1 is 1e-8 W/m^2'
end
