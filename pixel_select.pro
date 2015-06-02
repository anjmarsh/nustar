function pixel_select, frame, xn, yn

p = fltarr(xn, yn)

for i=0, xn-1 do begin
  for j=0, yn-1 do begin

     p[i,j] = frame[i,j]

  endfor
endfor

return, p

end
