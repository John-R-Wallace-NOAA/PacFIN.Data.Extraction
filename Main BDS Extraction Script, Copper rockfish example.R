
   library(JRWToolBox)

   rgit::gitAFile('John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/BDS Sp Extraction with Grade & Dahl Info 24 Jul 2020.R', show = FALSE)
        
   PacFIN.COPP.bds.24.Jul.2020 <- bds.sp.extraction("'COPP'", PacFIN.Catch.Dahl = COPP.CompFT.24.Jul.2020)
      
   save(PacFIN.COPP.bds.24.Jul.2020, file = 'PacFIN.COPP.bds.24.Jul.2020.RData')
   
   
