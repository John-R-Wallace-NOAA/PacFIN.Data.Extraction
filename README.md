# PacFIN-Data-Extraction

R code with embedded SQL to extract code from the PacFIN database (https://pacfin.psmfc.org/)

You will need my toolbox installed: https://github.com/John-R-Wallace/JRWToolBox

You will also need ODBC properly setup for the RODBC package in Windows or ROracle (default for non-Windows).

See the code in JRWToolBox::import.sql()

To not be prompted for your username and password first set:

     UID <- "username"
     PWD <- "myPacFIN password"
     
Thanks to my rgit package's sourceFunctionURL(), neither PacFIN.Catch.Extraction() nor the wrapper function PacFIN.Catch.Import() need my toolbox package installed (you will need internet access):


    PacFIN.Petrale.Catch.List.8.Oct.2020 <- PacFIN.Catch.Extraction("('PTRL', 'PTR1')")
    PacFIN.Petrale.Catch.List.8.Oct.2020 <- PacFIN.Catch.Extraction("('PTRL', 'PTR1')", verbose = FALSE)
    
    PacFIN.Catch.Import(returnCode = TRUE)  # View the PacFIN.Catch.Extraction() function 
    PacFIN.Catch.Extraction <- PacFIN.Catch.Import(returnCode = TRUE)  # Save the PacFIN.Catch.Extraction() function
    PacFIN.Petrale.Catch.List.8.Oct.2020 <- PacFIN.Catch.Import("('PTRL', 'PTR1')")  # Run the function()
    
    
