PRO Newmap_reproject
  ;HARRIS, Tech Support, MZ & WG, 0718


  file = DIALOG_PICKFILE( filter="*.tif")
  ok=QUERY_TIFF(file, defn,GEOTIFF=ntags)
  IF ~ok THEN MESSAGE,"No geoTiff"

  matrix=READ_TIFF(file)

  ;display with GeoTiff-mapprojection but map boundaries given by geo-coord:
  limit = [52,4,54,6] ;;lower left, upper right -> use e.g. your spanish boundbary
  imgsat=Image( matrix, MARGIN=0.,GEOTIFF=ntags, $
    limit = limit, $
    order=1)

  ;;tip: if you know the boundaries in geo.coord. of your image you can specifiy
  ; IMAGE_LOCATION=[lonMin,latMin], $  ;lower left corner of image
  ; IMAGE_DIMENSIONS=[lonMax-lonMin, latMax-latMin]) ;

  ;test it
  PRINT, imgsat.MAP_PROJECTION

  ;;overlay some of IDL's shape files
  c1=Mapcontinents(/CONTINENTS, /hires)
  c1.color="green"
  c1.thick=4
  c2=Mapcontinents(/COUNTRIES, /hires)
  c2.color="red"
  c2.linestyle="-"
  ;;access map object: e.g. used to access grid properties --> here white grid
  omap = imgsat.MAPPROJECTION
  omap.mapgrid.color='white'

  ;;GetData, projection given by GeoTiff
  data1a = imgsat.window.Copywindow() ;set resolution, width /height ....
  ;just show it again for testing purposes
  i1=Image(data1a, title = omap.MAP_PROJECTION)


  ;;reproject very easy: just set another mapprojection
  imgsat.MAP_PROJECTION="ortho"

  c1.hide=1;don't show vectors...
  c2.hide=1
  omap.mapgrid.hide=1

  data2a = imgsat.window.Copywindow()
  ;just show it again for testing purposes -> compare
  i2=Image(data2a, title = omap.MAP_PROJECTION)



  ;;GetData, projection "ortho"

  ;or ....
  ;IDL> imgsat.MAP_PROJECTION="stereo"
  ;IDL> imgsat.MAP_PROJECTION="mercator"


END




