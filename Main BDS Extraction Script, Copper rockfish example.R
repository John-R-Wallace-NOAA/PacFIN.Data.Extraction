
   library(JRWToolBox)  # rgit package now loaded with JRWToolBox

   # Use gitAFile() directly
   # rgit::gitAFile('John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/R/BDS Sp Extraction with Grade & Dahl Info 24 Jul 2020.R', show = FALSE)        
   
   # Use S() which calls gitAFile() 
   repoPath <- "John-R-Wallace-NOAA/PacFIN-Data-Extraction"
   rgit::S('BDS Sp Extraction with Grade & Dahl Info 24 Jul 2020.R', show = FALSE)

   PacFIN.COPP.bds.24.Jul.2020 <- bds.sp.extraction("'COPP'", PacFIN.Catch.Dahl = COPP.CompFT.24.Jul.2020)
      
   save(PacFIN.COPP.bds.24.Jul.2020, file = 'PacFIN.COPP.bds.24.Jul.2020.RData')
   
   
