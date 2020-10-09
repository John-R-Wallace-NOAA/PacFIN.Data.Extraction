PacFIN.Catch.Import <- function(SpeciesCodeName = "('PTRL', 'PTR1')", UID = PacFIN.Login, PWD = PacFIN.PW, verbose = TRUE, addColsWithLegacyNames = TRUE, returnCode = FALSE) {

    # -------- Import Main Function --------
    sourceFunctionURL <- function(URL) {
       ' # For more functionality, see gitAFile() in the rgit package ( https://github.com/John-R-Wallace-NOAA/rgit ) which includes gitPush() and git() '
       require(RCurl)
       File.ASCII <- tempfile()
       on.exit(file.remove(File.ASCII))
       writeLines(paste(readLines(textConnection(RCurl::getURL(URL))), collapse = "\n"), File.ASCII)
       source(File.ASCII)
    }
    
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/R/PacFIN.Catch.Extraction.R")
    
    
    if(returnCode)
       return(PacFIN.Catch.Extraction)
       
    if(!returnCode)
       PacFIN.Catch.Extraction(SpeciesCodeName = SpeciesCodeName, UID = UID, PWD = PWD, verbose = verbose, addColsWithLegacyNames = addColsWithLegacyNames)
    
}   
    

