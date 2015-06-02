function pixel_ratios2, frame, xn,  yn

r = 0.*frame
src = 1.*frame
for i=0, xn-1 do begin
  for j=0, yn-1 do begin
    src_and_bkg = 1.*frame[ max([i-1,0]):min([i+1,xn-1]) , max([j-1,0]):min([j+1,yn-1]) ]
    nbkg = n_elements(src_and_bkg) - 1.                         ;the -1 is the central position
    r[i,j] = src[i,j] / (total(src_and_bkg) - src[i,j])*nbkg    ;bkg sum included src
  endfor
endfor

return,r

end
