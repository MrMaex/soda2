FUNCTION soda2_findsize, img, pop, pmisc
   ;Returns the diameter of a binary image based on the size of a pixel in each dir (xres and yres)
   ;Aaron Bansemer, NCAR, 2009
   ;Copyright © 2016 University Corporation for Atmospheric Research (UCAR). All rights reserved.

      
   xres=float((*pop).res)
   yres=float((*pmisc).yres) 
              
   ;IF xres ne yres THEN print,'Square pixels required for fastcircle sizing, using x-resolution only.'
   area_original=total(img) * (yres/xres) ;area of particle
   s=size(img)
   
   ;xsize
   IF s[2] gt 1 THEN w=where(total(img,2) gt 0) ELSE w=where(img gt 0)
   xsize=(max(w)-min(w)+1)*xres

   ;ysize
   IF s[2] gt 1 THEN w=where(total(img,1) gt 0) ELSE w=0
   ysize=(max(w)-min(w)+1)*yres
       
   ;Fastcircle is used within aspect_ratio routine, so don't repeat here
   aspr=aspect_ratio(img, circle=circle, tas_adjust=yres/xres, orientation=orientation, makeplot=0)
   diam=(circle.diam+1)*xres  ;plus 1 is due to the fact we're looking a pixels with 0.5 shading threshold, not points

   r=diam/xres/2.0
   x=circle.center[0]
   centerin=1b
   IF (x eq 0) or (x eq s[1]-1) THEN centerin=0b
   theta=acos((x/r) <1)           ;angle
   phi=acos(((s[1]-1-x)/r) <1)
   ; find area:       triangles(left)   triangles(right)         (remaining wedges)
   circle_area_imaged=x*r*sin(theta) + (s[1]-1-x)*r*sin(phi) + !pi*r^2*((!pi-phi-theta)/!pi)
   ar=(area_original/circle_area_imaged) < 1.0

   ;Change diam to area equivalent diameter if needed   
   area_adjusted=area_original*((!pi*r^2)/circle_area_imaged)
   IF (*pop).smethod eq 'areasize' THEN diam=sqrt(4.0/!pi*area_adjusted) * xres
   
   ;if (phi+theta) gt 0 then allin=0 else allin=1
   IF  (total(img[0,*])+total(img[s[1]-1,*]) ne 0) THEN allin=0b ELSE allin=1b
   return, {diam:diam, xsize:xsize, ysize:ysize, ar:ar, aspr:aspr, allin:allin, c:circle.center, centerin:centerin, $
            orientation:orientation, perimeterarea:circle.area}  
END
