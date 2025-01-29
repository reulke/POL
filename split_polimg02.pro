pro split_PolImg02

; Test images in
LW = 'D:\_X\'
path = LW + '2023-09-27_13-18-56_Zoo-Zuerich-Aras\0\2023-09-27_13-18-56_aras16Bit_cam-21320767\'
opath_int = LW + '2023-09-27_13-18-56_Zoo-Zuerich-Aras\0\2023-09-27_13-18-56_aras16Bit_cam-21320768\'
opath_dop = LW + '2023-09-27_13-18-56_Zoo-Zuerich-Aras\0\2023-09-27_13-18-56_aras16Bit_cam-21320769\'
opath_aop = LW + '2023-09-27_13-18-56_Zoo-Zuerich-Aras\0\2023-09-27_13-18-56_aras16Bit_cam-21320770\'
opath_jpg = LW + '2023-09-27_13-18-56_Zoo-Zuerich-Aras\0\2023-09-27_13-18-56_aras16Bit_cam-21320771\'

date = '250128'
LW = 'D:\_Z\4Cam\'+date+'\'
path = LW + '767_POL\'
opath_int = LW + '767_INT\
opath_dop = LW + '767_DOP\
opath_aop = LW + '767_AOP\
opath_jpg = LW + '767_JPG\

cv2 = Python.Import('cv2')
np = Python.Import('numpy')
pa = Python.Import('polanalyser')

angles = np.deg2rad([0, 45, 90, 135])

files = FILE_SEARCH(path, count = nn, '*.tiff')
ok = QUERY_TIFF(files(0), s)
IF (ok) THEN BEGIN
  xm=s.DIMENSIONS(0) & ym = s.DIMENSIONS(1)
  ENDIF ELSE stop
;  files = FILE_SEARCH(path, count = nn, '*.bmp')
;  name = files(0)
;  aa = read_bmp(name, /RGB)
;  ss = size(aa, /DIM)
;  xm=ss(0) & ym = ss(1)
; Read image and demosaicing
for ii = 0, nn-1 do begin
  iname = files(ii)
  kl=strsplit(iname,'\') & ij=n_elements(kl)
  oname = strmid(iname, kl(ij-1))
  img_raw = read_tiff(iname)
  img_raw = double(img_raw)
  img = pa.demosaicing(img_raw, pa.COLOR_PolarMono)
;  img = pa.demosaicing(img_raw, pa.COLOR_PolarRGB)
  ; Calculate the Stokes vector per-pixel
  img_stokes = pa.calcStokes(img, angles)
  ; Convert the Stokes vector to Intensity, DoLP and AoLP
  img_intensity = pa.cvtStokesToIntensity(img_stokes)
  img_dolp = 1d2*pa.cvtStokesToDoLP(img_stokes)
  img_aolp = 180d0-!RADEG*pa.cvtStokesToAoLP(img_stokes)
  write_tiff, opath_int+oname, img_intensity, /DOUBLE
  write_tiff, opath_dop+oname, img_dolp, /DOUBLE
  write_tiff, opath_aop+oname, img_aolp, /DOUBLE
  
  bb = bytarr(3, xm, ym)
  bb(0,*,*) = bytscl(img_intensity)
  bb(1,*,*) = bytscl(img_dolp, max=100)
  bb(0,*,*) = bytscl(img_aolp, max=180)
  jname =strmid(oname, 0, strlen(oname)-5)+'.jpg'
  write_jpeg, opath_jpg+jname, bb, TRUE=1, /ORDER
;  stop
endfor






stop
end