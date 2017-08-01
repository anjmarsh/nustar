function combine_fpm_filter, evtfilea, evtfileb

evtaf = mrdfits(evtfilea, 1, ha)
evtbf = mrdfits(evtfileb, 1, hb)

;Exclude poorly calibrated events 
deta_good = where((evtaf.det1x ne -4095) and (evtaf.det1y ne -4095))
detb_good = where((evtbf.det1x ne -4095) and (evtbf.det1y ne -4095))
evtaf = evtaf[deta_good]
evtbf = evtbf[detb_good]

;Exclude events with pulse height = 0
inrange1 = where(evtaf.pi ge 0)
inrange2 = where(evtbf.pi ge 0)
evtaf = evtaf[inrange1]
evtbf = evtbf[inrange2]

;Exclude events with non-physical grades (21-24)
deta_good_grade = where(evtaf.grade lt 21 or evtaf.grade gt 24)
evtaf = evtaf[deta_good_grade]
detb_good_grade = where(evtbf.grade lt 21 or evtbf.grade gt 24)
evtbf = evtbf[detb_good_grade]

;Exclude "hot" pixels in FPMA
use = bytarr(n_elements(evtaf)) + 1
thisdet = where(evtaf.det_id eq 2)
badones = where(evtaf[thisdet].rawx eq 16 and evtaf[thisdet].rawy eq 5, nbad)
if nbad gt 0 then use[thisdet[badones]]=0
badones = where(evtaf[thisdet].rawx eq 24 and evtaf[thisdet].rawy eq 22, nbad)
if nbad gt 0 then use[thisdet[badones]]=0
thisdet = where(evtaf.det_id eq 3)
badones = where(evtaf[thisdet].rawx eq 22 and evtaf[thisdet].rawy eq 1, nbad)
if nbad gt 0 then use[thisdet[badones]]=0
badones = where(evtaf[thisdet].rawx eq 15 and evtaf[thisdet].rawy eq 3, nbad)
if nbad gt 0 then use[thisdet[badones]]=0
badones = where(evtaf[thisdet].rawx eq 0 and evtaf[thisdet].rawy eq 15, nbad)
if nbad gt 0 then use[thisdet[badones]]=0
evtaf=evtaf[where(use)]

;Get min/max x/y values for combining the telescopes
minxa = min(evtaf.x) & maxxa = max(evtaf.x)
minya = min(evtaf.y) & maxya = max(evtaf.y)
minxb = min(evtbf.x) & maxxb = max(evtbf.x)
minyb = min(evtbf.y) & maxyb = max(evtbf.y)

minx = max([minxa, minxb]) & maxx = min([maxxa, maxxb])
miny = max([minya, minyb]) & maxy = min([maxya, maxyb])

min_array = [minx, maxx, miny, maxy]

evt_str={evtaf:evtaf, evtbf:evtbf, ha:ha, hb:hb, min_array:min_array}

RETURN, evt_str

END
