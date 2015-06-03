function add_flare_nt, imcube, frame, scale=scale, pix_size=pix_size,$
move=move, erange=erange

;;Function to add a "flare" with flat spectrum, scaled by arbitrary amount, to
;an image cube of real NuSTAR data with a certain pixel size

bkg_cts = total(imcube[*,*,frame])

;* Simulation ran for 10s *;
f = mrdfits('/home/andrew/nusim/Solar/flat_5-10keV_norm100.events.fits',1,fh)
a = where(f.module eq 1)
fa = f[a]

if n_elements(erange) ne 0 then begin
   emin = min(erange)
   emax = max(erange)
   kev = fa.e
   inrange = where((kev ge emin) and (kev le emax))
   fa = fa[inrange]
endif

SetDefaultValue, scale, 0.01  ;reasonable starting point
SetDefaultValue, pix_size, 58  ;NuSTAR HPD

det1x = fa.det1x
det1y = fa.det1y

bin = 0.6 / 12.3 * pix_size ;correct binning for NuSIM image 
nf = hist_2d(det1x, det1y, bin1=bin, bin2=bin)
nf = nf * scale * 0.04
;include livetime factor = 0.04
;eventually change this to calculate LT from hk file

s = imcube[*,*,frame]

if n_elements(move) ne 0 then begin
   nf = shift(nf, move)
endif

;Add flare image to the imcube image
if (size(nf))[1] eq (size(s))[1] && (size(nf))[2] eq (size(s))[2] then begin
   s = s + nf
endif else begin
   s1 = size(s,/dimensions)
   s2 = size(nf,/dimensions)
   g = fltarr(s2[0],s1[1]-s2[1])
   fc = [[nf],[g]]
   j = fltarr(s1[0]-s2[0],s1[1])
   fc = [fc,j]
   s = s + fc
endelse

fimcube = imcube
;Normalize so that number of counts in frame stays constant 
fimcube[*,*,frame] = s * ( bkg_cts / total(s) )

return, fimcube 



END
