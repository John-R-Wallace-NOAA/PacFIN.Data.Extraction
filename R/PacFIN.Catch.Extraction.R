
PacFIN.Catch.Extraction <- function(SpeciesCodeName = "('PTRL', 'PTR1')", UID = "wallacej", PWD = PacFIN.PW, verbose = TRUE) {

    # -------- Import utility Functions --------
    sourceFunctionURL <- function(URL) {
       ' # For more functionality, see gitAFile() in the rgit package ( https://github.com/John-R-Wallace-NOAA/rgit ) which includes gitPush() and git() '
       require(RCurl)
       File.ASCII <- tempfile()
       on.exit(file.remove(File.ASCII))
       writeLines(paste(readLines(textConnection(RCurl::getURL(URL))), collapse = "\n"), File.ASCII)
       source(File.ASCII)
    }
    
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/JRWToolBox/master/R/import.sql.R")
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/JRWToolBox/master/R/scanIn.R")
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/JRWToolBox/master/R/recode.simple.R")
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/JRWToolBox/master/R/agg.table.R")
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/JRWToolBox/master/R/r.R")
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/JRWToolBox/master/R/match.f.R")
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/JRWToolBox/master/R/Table.R")
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/JRWToolBox/master/R/sort.f.R")
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/JRWToolBox/master/R/recode.simple.R")
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/R/nameConvertVdrfdToCompFT.R")
 
 
   #  -------- Check species info  --------
   if(verbose) {
      sp <- import.sql("Select * from pacfin.sp", dsn="PacFIN", uid= UID,  pwd = PWD)
      print(sp[grep(SpeciesCodeName,  sp$CNAME), 1:7])
   }
   
   # -------- Data from the Comprehensive_FT table --------
   
   # Gear table
   # gr <- import.sql("Select * from pacfin.gr", dsn="PacFIN", uid=UID, pwd=PWD)
   
   
   # COUNCIL_CODE = 'P'; with research catch included
   # For species with a nominal category use, e.g.:  < PACFIN_SPECIES_CODE = any "('PTRL', 'PTR1')" >, otherwise use: "'SABL'"
   CompFT <- import.sql(
           "Select COUNCIL_CODE, AGENCY_CODE, DAHL_GROUNDFISH_CODE, INPFC_AREA_TYPE_CODE, LANDING_LANDING_YEAR, LANDING_MONTH, LANDING_DATE, FTID, PARTICIPATION_GROUP_CODE, PACFIN_CATCH_AREA_CODE, 
                   ORIG_PACFIN_CATCH_AREA_CODE, PACFIN_PORT_CODE, FLEET_CODE_CODE, VESSEL_ID, PACFIN_GEAR_CODE, IS_IFQ_LANDING, REMOVAL_TYPE_CODE_CODE, CONDITION_CODE, DISPOSITION_CODE, 
                   EXVESSEL_REVENUE, PACFIN_SPECIES_CODE, NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE, IS_SPECIES_COMP_USED, GRADE_CODE, GRADE_NAME, PACFIN_GROUP_GEAR_CODE, ROUND_WEIGHT_MTONS, LANDED_WEIGHT_MTONS                         
             from pacfin_marts.Comprehensive_FT 
            where PACFIN_SPECIES_CODE = any &sp 
              and COUNCIL_CODE = 'P' 
              and AGENCY_CODE in ('W','O','C')", "&sp", SpeciesCodeName, dsn="PacFIN", uid=UID, pwd=PWD)
   
   # Convert to the old style short names
   # names(CompFT) <- recode.simple(names(CompFT), nameConvertVdrfdToCompFT)
   
   
   # Create W_O_C_Port_Groups
   CompFT$W_O_C_Port_Groups <- CompFT$AGENCY_CODE
   CompFT$W_O_C_Port_Groups[CompFT$AGENCY_CODE %in% 'W'] <- "AWA"
   CompFT$W_O_C_Port_Groups[CompFT$AGENCY_CODE %in% 'O'] <- "AOR"
   CompFT$W_O_C_Port_Groups[CompFT$AGENCY_CODE %in% 'C'] <- "ACA"
   
   # Research and tribal data frame
   Catch.mt.by.Agency.Year.Fleet <- aggregate(CompFT$ROUND_WEIGHT_MTONS, CompFT[ ,c('FLEET_CODE', 'LANDING_YEAR', 'AGENCY_CODE')], sum, na.rm = TRUE)
     
   # Tribal catch by gear ID
   Tribal.Summary.Catch <- CompFT[CompFT$FLEET_CODE %in% 'TI', ]
   Tribal.Catch.mt.by.Year.Gear <- aggregate(Tribal.Summary.Catch$ROUND_WEIGHT_MTONS, Tribal.Summary.Catch[ ,c('PACFIN_GEAR_CODE', 'LANDING_YEAR')], sum, na.rm = TRUE)   
     
   if(verbose) {
   
     print(Table(CompFT$INPFC_AREA_TYPE_CODE, CompFT$PACFIN_CATCH_AREA_CODE))
      
     print(Table(CompFT$INPFC_PSMFC_AREA_GROUP, CompFT$PACFIN_CATCH_AREA_CODE))
  
     print(Table(CompFT$PACFIN_SPECIES_CODE, CompFT$W_O_C_Port_Groups))
   
     print(Table(CompFT$PACFIN_SPECIES_CODE, CompFT$LANDING_YEAR))
   
     print(Table(CompFT$PACFIN_SPECIES_CODE, CompFT$LANDING_YEAR, CompFT$AGENCY_CODE))
     
     print(r(Catch.mt.by.Year.Fleet.Agency, 2))
     
     print(r(Tribal.Catch.mt.by.Year.Gear, 2))
     
     # PACFIN_CATCH_AREA_CODE by LANDING_YEAR by AGENCY_CODE - shows where the differences in the INPFC and PSMFC areas are.
     print(Table(CompFT$PACFIN_CATCH_AREA_CODE, CompFT$LANDING_YEAR, CompFT$AGENCY_CODE))
   
     # Research catch by year and removal type - compare with FLEET removal
     print(r(agg.table(aggregate(CompFT$ROUND_WEIGHT_MTONS, CompFT[, c('LANDING_YEAR', 'REMOVAL_TYPE_CODE')], sum, na.rm = TRUE), Print = FALSE), 3))
     
     # Here is how 'Fleet' compares to 'Removal type' 
       # Fleet type: limited entry 'LE', open access 'OA', tribal indian 'TI', research 'R', unknown 'XX' 
       # Removal type: Commercial (Non-EFP) 'C', Commercial(Direct Sales) 'D', Exempted fishing permit(EFP) 'E', Other 'O', Personal use 'P', Research 'R', Unknown 'U'
    
     cat('FLEET_CODE vs REMOVAL_TYPE_CODE')
     print(Table(CompFT$FLEET_CODE, CompFT$REMOVAL_TYPE_CODE))
  
  }   
   
   # Fleet breakdown including research and tribal catch
      # - Tribal catch is included but not separable in a 'sc' type table.
      # - I would not assume this is all the research catch and would ask the Region what they have.
   
   # ------------------------------------------- INPFC sc table ----------------------------------------------------------------
   
   # Take out research catch for a summary catch (sc) like table
   # change(CompFT[!(CompFT$REMOVAL_TYPE_CODE %in% "R") & CompFT$INPFC_PSMFC_AREA_GROUP %in% 'INPFC',])  <<== !!! WRONG !!! see PACFIN_CATCH_AREA_CODE = INPFC_AREA_TYPE_CODE below
     
   CompFT.INPFC <- CompFT[!(CompFT$REMOVAL_TYPE_CODE %in% "R"), ]
   # Can not use grep() below since ORIG_PACFIN_CATCH_AREA_CODE is matched also
   # ***** This change in names is for the comparison below ****
   names(CompFT.INPFC)[(1:length(names(CompFT.INPFC)))[names(CompFT.INPFC) == "PACFIN_CATCH_AREA_CODE"]] <- 'INPFC_AREA_TYPE_CODE'
   CompFT.INPFC$PACFIN_PORT_CODE <-  W_O_C_Port_Groups
   PacFIN.INPFC.Summary.Catch <- aggregate(CompFT.INPFC$ROUND_WEIGHT_MTONS, CompFT.INPFC[, c('COUNCIL_CODE', 'DAHL_GROUNDFISH_CODE', 'LANDING_YEAR', 'LANDING_MONTH', 'PACFIN_SPECIES_CODE', 'PACFIN_CATCH_AREA_CODE', 'PACFIN_GEAR_CODE', 'PACFIN_GROUP_GEAR_CODE', 'PACFIN_PORT_CODE')], sum, na.rm = TRUE)
                                             
   PacFIN.INPFC.Summary.Catch <- sort.f(PacFIN.INPFC.Summary.Catch, c('LANDING_YEAR', 'LANDING_MONTH', 'PACFIN_CATCH_AREA_CODE', 'PACFIN_GEAR_CODE', 'PACFIN_PORT_CODE'))
   
   SC.INPFC.agg <- agg.table(aggregate(list(Catch.mt = PacFIN.INPFC.Summary.Catch$ROUND_WEIGHT_MTONS), list(LANDING_YEAR = PacFIN.INPFC.Summary.Catch$LANDING_YEAR, PACFIN_PORT_CODE = PacFIN.INPFC.Summary.Catch$PACFIN_PORT_CODE), sum, na.rm = TRUE), Print = FALSE)
   SC.INPFC.agg[is.na(SC.INPFC.agg)] <- 0
  
   # ------------------------------------------- PSMFC Summary Catch Table ---------------------------------------------------------------- 
      
   CompFT.PSMFC <- CompFT[!(CompFT$REMOVAL_TYPE_CODE %in% "R") & CompFT$PACFIN_CATCH_AREA_CODE %in% c("UP","1A", "1B", "MNTREY BAY", "1E", "1C", "2A", "2B", "2C", "2E", "2F", "2D", "3A", "3B", "3C-S"), ]
   CompFT.PSMFC$PACFIN_PORT_CODE <-  W_O_C_Port_Groups
   PacFIN.PSMFC.Summary.Catch <- aggregate(list(CATCH.KG = CompFT.PSMFC$ROUND_WEIGHT_MTONS * 1000), 
             CompFT.PSMFC[, c('COUNCIL_CODE', 'DAHL_GROUNDFISH_CODE', 'LANDING_YEAR', 'LANDING_MONTH', 'PACFIN_SPECIES_CODE', 'PACFIN_CATCH_AREA_CODE', 'PACFIN_GEAR_CODE', 'PACFIN_GROUP_GEAR_CODE', 'PACFIN_PORT_CODE')], sum, na.rm = TRUE)
   PacFIN.PSMFC.Summary.Catch <- sort.f(PacFIN.PSMFC.Summary.Catch, c('LANDING_YEAR', 'LANDING_MONTH', 'PACFIN_CATCH_AREA_CODE', 'PACFIN_GEAR_CODE', 'PACFIN_PORT_CODE'))
   
   SC.PSMFC.agg <- agg.table(aggregate(list(Catch.mt = PacFIN.PSMFC.Summary.Catch$ROUND_WEIGHT_MTONS), list(LANDING_YEAR = PacFIN.PSMFC.Summary.Catch$LANDING_YEAR, PACFIN_PORT_CODE = PacFIN.PSMFC.Summary.Catch$PACFIN_PORT_CODE), sum, na.rm = TRUE), Print = FALSE)
   SC.PSMFC.agg[is.na(SC.PSMFC.agg)] <- 0
   
   
   if(verbose) {
   
      print(r(SC.INPFC.agg, 3))
      print(Table(PacFIN.INPFC.Summary.Catch$PACFIN_CATCH_AREA_CODE, PacFIN.INPFC.Summary.Catch$PACFIN_PORT_CODE))
      
      print(r(SC.PSMFC.agg, 3))
      print(Table(PacFIN.PSMFC.Summary.Catch$PACFIN_CATCH_AREA_CODE, PacFIN.PSMFC.Summary.Catch$PACFIN_PORT_CODE))
   } 
      
   # ----------------- Comparison of PSMFC sc table to INPFC sc table ----------------------------- 
   
   names(SC.INPFC.agg) <- paste0(names(SC.INPFC.agg), ".INPFC")
   (SC.INPFC.agg <- SC.INPFC.agg[,order(names(SC.INPFC.agg))])  # Make sure the ordering is correct
   
   names(SC.PSMFC.agg) <- paste0(names(SC.PSMFC.agg), ".PSMFC")
   (SC.PSMFC.agg <- SC.PSMFC.agg[,order(names(SC.PSMFC.agg))])
   
   # The last of year of data may currently have only one of the area types
   if(nrow(SC.PSMFC.agg) !=  nrow(SC.INPFC.agg)) {
      commonYears <- sort(intersect(SC.PSMFC.agg$LANDING_YEAR, SC.INPFC.agg$LANDING_YEAR))
      SC.PSMFC.agg <- SC.PSMFC.agg[SC.PSMFC.agg$LANDING_YEAR %in% commonYears, ]
      SC.INPFC.agg <- SC.INPFC.agg[SC.INPFC.agg$LANDING_YEAR %in% commonYears, ]   
   }
   
   N <- nrow(SC.INPFC.agg)
   Diff.and.Ratio <- cbind(SC.INPFC.agg, " " = rep("    ", N), SC.PSMFC.agg, " " = rep("    ", N), 
                           SC.INPFC.agg - SC.PSMFC.agg, " " = rep("    ", N), SC.INPFC.agg/SC.PSMFC.agg)
   
   names(Diff.and.Ratio) <- c(names(SC.INPFC.agg), " ", names(SC.PSMFC.agg), "  ", "CA.diff" , "OR.diff", "WA.diff", " ", "CA.ratio" , "OR.ratio", "WA.ratio")
   Tmp.Diff <- Diff.and.Ratio[, 1:11]
   # Tmp.Diff[is.na(Tmp.Diff )] <- 0
   Diff.and.Ratio <- cbind(Tmp.Diff, Diff.and.Ratio[,12:15]) # unsupported matrix index in replacement, so need temp file
   
   print(r(Diff.and.Ratio, 2))
   
   
  invisible(list(CompFT = CompFT, PacFIN.INPFC.Summary.Catch = PacFIN.INPFC.Summary.Catch, PacFIN.PSMFC.Summary.Catch = PacFIN.PSMFC.Summary.Catch, 
                   Catch.mt.by.Agency.Year.Fleet = Catch.mt.by.Agency.Year.Fleet, Tribal.Catch.mt.by.Year.Gear = Tribal.Catch.mt.by.Year.Gear))
}
