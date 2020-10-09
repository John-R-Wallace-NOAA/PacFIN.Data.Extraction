PacFIN.Catch.Import <- function(SpeciesCodeName = "('PTRL', 'PTR1')", UID = PacFIN.Login, PWD = PacFIN.PW, verbose = TRUE, addColsWithLegacyNames = TRUE, viewCode = FALSE) {

    # -------- Import Main Function --------
    sourceFunctionURL <- function(URL) {
       ' # For more functionality, see gitAFile() in the rgit package ( https://github.com/John-R-Wallace-NOAA/rgit ) which includes gitPush() and git() '
       require(RCurl)
       File.ASCII <- tempfile()
       on.exit(file.remove(File.ASCII))
       writeLines(paste(readLines(textConnection(RCurl::getURL(URL))), collapse = "\n"), File.ASCII)
       source(File.ASCII)
    }
    
    '  # To view the PacFIN.Catch.Extraction() function: On the command line run sourceFunctionURL() above, Run the line below, Type "PacFIN.Catch.Extraction", and hit Enter.  '
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/R/PacFIN.Catch.Extraction.R")
    
    if(viewCode)
       return(PacFIN.Catch.Extraction)
    if(!viewCode)
       PacFIN.Catch.Extraction(SpeciesCodeName = SpeciesCodeName, UID = UID, PWD = PWD, verbose = verbose, addColsWithLegacyNames = addColsWithLegacyNames)
    
}   
    
