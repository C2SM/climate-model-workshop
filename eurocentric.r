convert.to.eurocentric <- function(raster.in) {
  rl <- crop(raster.in,
             extent(c(xmin(raster.in),xmax(raster.in)-180,ymin(raster.in),
                      ymax(raster.in))))
  
  # set extent from rr to rleft:
  rr <- (crop(raster.in,
              extent(c(xmax(raster.in)-180,xmax(raster.in),ymin(raster.in),
                       ymax(raster.in)))))
  extent(rr) <- extent(c(xmin(rr)-360,xmax(rr)-360,ymin(raster.in),
                         ymax(raster.in)))
  r.out = merge(rr,rl)
  names(r.out) = names(raster.in)
  return(r.out)
}

# zum einlesen:
# source("convert.to.eurocentric.R")

convert.to.pacificcentric <- function(raster.in) {
  rl <- crop(raster.in,
             extent(c(xmin(raster.in)+180,xmax(raster.in),ymin(raster.in),
                      ymax(raster.in))))
  
  # set extent from rr to rleft:
  rr <- (crop(raster.in,
              extent(c(xmin(raster.in),xmax(raster.in)-180,ymin(raster.in),
                       ymax(raster.in)))))
  extent(rr) <- extent(c(xmin(rr)+360,xmax(rr)+360,ymin(raster.in),
                         ymax(raster.in)))
  
  r.out = merge(rr,rl)
  names(r.out) = names(raster.in)
  
  return(r.out)
}