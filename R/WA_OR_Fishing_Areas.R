
WA_OR_Fishing_Areas <- function(INFPC = TRUE, PSFMC = TRUE, WA_State = TRUE, WA_State_Web = FALSE, OR_State_Web = FALSE, CA_State_Web = FALSE) {

    sourceFunctionURL <- function(URL) {
        " # For more functionality, see gitAFile() in the rgit package ( https://github.com/John-R-Wallace-NOAA/rgit ) which includes gitPush() and git() "
        require(httr)
        File.ASCII <- tempfile()
        on.exit(file.remove(File.ASCII))
        getTMP <- httr::GET(URL)
        write(paste(readLines(textConnection(httr::content(getTMP))), 
            collapse = "\n"), File.ASCII)
        source(File.ASCII, local = parent.env(environment()))
    }
    
    sourceFunctionURL("https://raw.githubusercontent.com/John-R-Wallace-NOAA/JRWToolBox/master/R/WA_OR_Coast.R")

    # -------------------------
    
    WA_OR_Coast()
    
    if(INFPC) {
        INFPC_Lats <- c(40.5, 43.0, 47.5, 50.5)
        abline(h = INFPC_Lats, col = 'blue')
        text(-128.0, c(mean(INFPC_Lats[1:2]), mean(INFPC_Lats[2:3]), 48.8), labels = c("Eureka", "Columbia", "Vancouver"), col = 'blue')
    }
    
    if(PSFMC) {
        PSFMC_Lats <- c(40 + 30/60, 42.0, 42 + 50/60, 44 + 18/60, 45 + 46/60, 47 + 20/60, 49)
        abline(h = PSFMC_Lats, col = 'red')
        abline(h = 48 + 26/60, col = 'red', lty = 2)
        circle.f(-123.951,  47.916, r = 0.2, border.col = 'red')
        arrows(-124.2371, 47.9834, -124.911, 48.051, length = 0.1, col = 'red')
        text(c(rep(-127.0, 5), -123.951, -128.0), c(41.75, mean(PSFMC_Lats[2:3]), mean(PSFMC_Lats[3:4]), mean(PSFMC_Lats[4:5]), mean(PSFMC_Lats[5:6]),  47.916, mean(PSFMC_Lats[6:7])), 
               labels = c("1C", "2A", "2B", "2C", "3A", "3B", "3S (U.S. portion of 3C)"), col = 'red')
    }
    
    if(WA_State) {
        WA_Lats <- c(42, 46 + 16/60, 46 + 53/60 + 18/3600, 47 + 18/60 + 16/3600)
        abline(h = WA_Lats, col = 'green4')
        lines(c(-124.72538, -126.08921), c(48.51094, 47.30987), col = 'green4')
        lines(c(-124.38863, -125.66827), c(47.68030, 47.68030), col = 'green4')
        text(-124.7, c(41.6, mean(WA_Lats[1:2]), mean(WA_Lats[2:3]), mean(WA_Lats[3:4])), labels = c("62", "61", "60A-2", "60A-1"), col = 'green4')
        text(c(-125.11264, -125.0, -126.35), c(47.605, 47.81500, 47.65785), labels = c("59A-2", "59A-1", "58B"), col = 'green4', cex = c(0.75, 1, 1))
    }
    
    if(WA_State_Web) 
       browseURL('https://wdfw.wa.gov/sites/default/files/2019-02/2015_catch_area_map.jpg')
    
    if(OR_State_Web) 
       browseURL('https://www.dfw.state.or.us/fish/commercial/docs/marine_reserves/logbook_grid_charts.asp')
       
    if(CA_State_Web) {
       browseURL('https://apps.wildlife.ca.gov/MarineLogs/Content/Cpfv/images/north_fishing_blocks.jpg')
       browseURL('https://apps.wildlife.ca.gov/MarineLogs/Content/Cpfv/images/central_fishing_blocks.jpg')
       browseURL('https://apps.wildlife.ca.gov/MarineLogs/Content/Cpfv/images/south_fishing_blocks.jpg')
    }
}
 
 
