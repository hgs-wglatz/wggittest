;change 19:26
;change 19:24
;change 19:08
;changed 18:52
;change 18:34
;change 18:32
;change 18:30
;change 18:28
;;changed 18:23 



function WidWinHandler::Init,guibase
  self.guibase=guibase
  return, 1
end

function WidWinHandler::MouseMotion, oWin, x, y, KeyMods
  guibase=self.guibase
  widget_control,guibase,GET_UVALUE=gui 
  ; Convert from screen coordinates to data coordinates.
  xy=gui.img.ConvertCoord(x, y, /DEVICE, /TO_DATA)
  ll=gui.img.MapInverse(xy[0:1])
 ; print, xy, x,y,ll
  ;vals=gui.img.GetValueAtLocation(ll[0], ll[1],/data);/DEVICE)
    vals=gui.img.GetValueAtLocation(x,y, /DEVICE)
 print, x,y   
 help, vals 
 print, vals
 print, ll
 help,xy
 print, xy
  widget_control,gui.xval,SET_VALUE=string(x,format='(i6)')
  widget_control,gui.yval,SET_VALUE=string(y,format='(i6)')
  widget_control,gui.latval,SET_VALUE=string(ll[1],format='(f6.2)')
  widget_control,gui.lonval,SET_VALUE=string(ll[0],format='(f6.2)')
  widget_control,gui.datval,SET_VALUE=string( vals[0] );string(vals[2:4],format='(3("{",f6.1, "} "))') 
  return, 1 ; Perform default event handling for entire GUI
end

pro WidWinHandler__define
  void = {WidWinHandler, inherits GraphicsEventAdapter, guibase:0}
end

function ww_make_gui,handler,params
  ; Make main application dialog interface
  compile_opt IDL2, HIDDEN
  ; Determine monitor arrangement, selecting zero for control
  widbase=0 & scrmax=lonarr(2)
  monitors=obj_new('IDLsysMonitorInfo')
  multimon=monitors->IsExtendedDesktop()
  if (multimon) then begin
    monsizes=monitors->GetRectangles()
    scrmax=monsizes[2:3,1]     ; last index is screen number, "1" always used
    scroffset=monsizes[0:1,1]  ; ditto
  endif else begin
    scrmax=monsizes[2:3,0]     ; only one screen so use it
    scroffset=monsizes[0:1,0]  ; ditto   
  endelse
  ; Adjust for windows framing
  scroffset+=5 & scrmax[0]-=10 & scrmax[1]-=50
  colheight=scrmax[1]-43  ; set maximum columns height for dialog below menus
  imagecolwid=scrmax[0]-346 ; extend 2nd (image) column to fill remainder of dialog width
  ; Determine image area maximum size and whether need to scroll or not
  imagewidth=imagecolwid & imageheight=colheight+0 ; (unix-vm=23, win=0)
  ; Create GUI
  widbase=widget_base(TLB_FRAME_ATTR=17,/ROW, $
    XOFFSET=scroffset[0],YOFFSET=scroffset[1],SCR_XSIZE=scrmax[0],SCR_YSIZE=scrmax[1], $
    SPACE=0,XPAD=0,YPAD=0)
  ctrlbase=widget_base(widbase,/ROW,SPACE=2,XPAD=3,YPAD=2)
  ; Sub-bases, left hand controls and displays
  lrbase=widget_base(ctrlbase,/COLUMN)
  but=widget_label(lrbase,VALUE='Controls:',xsize=310,/ALIGN_LEFT)
  rbase=widget_base(lrbase,/ROW)
  label=widget_label(rbase,VALUE='X:',/ALIGN_CENTER,XSIZE=40)
  xval=widget_label(rbase,VALUE='-',/SUNKEN_FRAME,XSIZE=160,/ALIGN_LEFT)
  rbase=widget_base(lrbase,/ROW)
  label=widget_label(rbase,VALUE='Y:',/ALIGN_CENTER,XSIZE=40)
  yval=widget_label(rbase,VALUE='-',/SUNKEN_FRAME,XSIZE=160,/ALIGN_LEFT)
  rbase=widget_base(lrbase,/ROW)
  label=widget_label(rbase,VALUE='Z:',/ALIGN_CENTER,XSIZE=40)
  zval=widget_label(rbase,VALUE='-',/SUNKEN_FRAME,XSIZE=160,/ALIGN_LEFT)
  rbase=widget_base(lrbase,/ROW)
  label=widget_label(rbase,VALUE='Lat:',/ALIGN_CENTER,XSIZE=40)
  latval=widget_label(rbase,VALUE='-',/SUNKEN_FRAME,XSIZE=160,/ALIGN_LEFT)
  rbase=widget_base(lrbase,/ROW)
  label=widget_label(rbase,VALUE='Lon:',/ALIGN_CENTER,XSIZE=40)
  lonval=widget_label(rbase,VALUE='-',/SUNKEN_FRAME,XSIZE=160,/ALIGN_LEFT)
  rbase=widget_base(lrbase,/ROW)
  label=widget_label(rbase,VALUE='Values:',/ALIGN_CENTER,XSIZE=40)
  datval=widget_label(rbase,VALUE='-',/SUNKEN_FRAME,XSIZE=260,/ALIGN_LEFT)
  rbase=widget_base(lrbase,/ROW)
  swap=widget_button(rbase,VALUE="Swap",XSIZE=100)
  lrbase=widget_base(ctrlbase,/COLUMN)
  draww=widget_window(lrbase,xsize=imagewidth, $
    ysize=imageheight);,graphics_level=2)
  widget_control,widbase,/REALIZE,/MAP
  widget_control,draww,GET_VALUE=win
  params={widbase:widbase,win:win,xval:xval,yval:yval,zval:zval,latval:latval,lonval:lonval,datval:datval,img:obj_new(),swap:swap}
  widget_control,widbase,SET_UVALUE=params
  handler=obj_new('WidWinHandler',widbase)
  win.EVENT_HANDLER=handler
  XMANAGER, 'map_test', widbase, EVENT_HANDLER='map_test_event',/NO_BLOCK
  obj_destroy,monitors
  return,params
end

pro map_test_event,event
  compile_opt IDL2
  widget_control,event.top,GET_UVALUE=gui
  help, event
  case event.id of
    gui.swap: begin
      end
    else:
  endcase
end

pro map_test
  ; GUI and object windows
  gui=ww_make_gui()
  gui.win.select
  gui.win.getproperty,DIMENSIONS=windowSize
  ; Get a TIFF image - data and navigation
  ;gtiffile=DIALOG_PICKFILE(/READ,PATH='F:\gsfcdata\npp\viirs\level2\',FILTER=['*.tif','*.tiff'])
  ;gtiffile='F:\gsfcdata\npp\viirs\level2\NPP_SHARPVIIRSTCOLOR_roi1.18088130048.tif'
  ;gtiffile='F:\gsfcdata\jpss1\viirs\level2\J01_VM0XO.d20180520_t1234108_e1246589.MFCOLOR.tif'
  ;gtiffile='F:\gsfcdata\terra\modis\level2\MODcrefl_TrueColorFire.18089103441.tif'
  gtiffile= "c:\temp\copernicus_test.tif"
  ok=query_tiff(gtiffile,defn) and (defn ne !NULL)
  if (ok and defn.NUM_IMAGES>0) then begin
    ; Get overall information
    ok=query_tiff(gtiffile,defn,GEOTIFF=ntags,IMAGE_INDEX=0)
    iorder=((defn.ORIENTATION lt 3) ? 1 : 0)
    matrix=read_tiff(gtiffile)
    ; Set SPAIN into buffer view
    ;limit = [35,-10,45,2.5]
  ;  matrix=reform( matrix[0:2,*,*] )
     bmatrix=bytarr( size(matrix, /DIMENSIONS) )
     for idim1=0, (bmatrix.DIM)[0]-1l do begin  ;only interleaved by pixel !!
      bmatrix[idim1,*,*]= bytscl( matrix(idim1,*,*) )
     endfor
  ; matrix=  reform( matrix[3,*,*] )reform(bmatrix[3,*,*])
    imgsat=image( bmatrix, MARGIN=0.,GEOTIFF=ntags,ORDER=iorder,DIMENSIONS=windowSize,CURRENT=gui.win)
    ;test it
    PRINT, imgsat.MAP_PROJECTION
   ; imgsat.hide=1
    ; Update current mouse motion image control
    gui.img=imgsat & widget_control,gui.widbase,SET_UVALUE=gui
    ; Reproject to mercator
    imgsat.map_projection='mercator'
    ; Draw high-res country shapefile
    mc=mapcontinents(/COUNTRIES,COLOR='red',/HIRES)
    ; Retrieve the MapGrid object and set some properties.
    mg=imgsat.mapgrid
    mg.GRID_LATITUDE=2.5 & mg.GRID_LONGITUDE=2.5
    mg.COLOR = 'blue' & mg.LINESTYLE = 3
    imgsat.hide=0
  endif 
     
end
