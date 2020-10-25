PacFIN.Catch.Import <- function(SpeciesCodeName = "('PTRL', 'PTR1')", UID = PacFIN.Login, PWD = PacFIN.PW, verbose = TRUE, addColsWithLegacyNames = TRUE, returnCode = FALSE) {

    # -------- Import Main Function --------
    sourceFunctionURL <- function(URL) {
       ' # For more functionality, see gitAFile() in the rgit package ( https://github.com/John-R-Wallace-NOAA/rgit ) which includes gitPush() and git() '
       require(RCurl)
       File.ASCII <- tempfile()
       on.exit(file.remove(File.ASCII))
       writeLines(paste(readLines(textConnection(RCurl::getURL(URL))), collapse = "\n"), File.ASCII)
       source(File.ASCII, local = parent.env(environment()))
    }
    
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/R/PacFIN.Catch.Extraction.R")
    
    
    if(returnCode)
       return(PacFIN.Catch.Extraction)
       
    if(!returnCode)
       PacFIN.Catch.Extraction(SpeciesCodeName = SpeciesCodeName, UID = UID, PWD = PWD, verbose = verbose, addColsWithLegacyNames = addColsWithLegacyNames)
    
}   
    
    
    

PacFIN.Catch.Import(returnCode = TRUE)  # View the PacFIN.Catch.Extraction() function 
PacFIN.Catch.Extraction <- PacFIN.Catch.Import(returnCode = TRUE)  # Save the PacFIN.Catch.Extraction() function
PacFIN.Petrale.Catch.List.8.Oct.2020 <- PacFIN.Catch.Import("('PTRL', 'PTR1')")  # Run the function()



PacFIN.Petrale.Catch.List.8.Oct.2020 <- PacFIN.Catch.Extraction("('PTRL', 'PTR1')", verbose = FALSE)






source("PacFIN.Catch.Extraction.R")

PacFIN.Login <- "wallacej"
PacFIN.PW <- "RedF*sh92"

Canary <- PacFIN.Catch.Extraction("('CNRY','CNR1')")


repoPath <- "nwfsc-assess/PacFIN.Utilities/pull"
gitEdit(PullCatch.PacFIN, "nwfsc-assess/PacFIN.Utilities/pull/R/", verbose = T)






