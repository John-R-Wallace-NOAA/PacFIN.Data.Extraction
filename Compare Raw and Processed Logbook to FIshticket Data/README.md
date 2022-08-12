Using the PacFIN.Catch.Extraction() function from the < John-R-Wallace-NOAA/PacFIN-Data-Extraction > repo and products derived from this PacFIN Logbook repo the Compare.Raw.LogB.to.Proc.Data.and.FT() function (in the R folder) compares raw and processed logbook data to PacFIN fishticket data.

    PacFIN.Login <- UID <- "wallacej"
    PacFIN.PW <- PWD <- "*********"
    
    # --- Sablefish ---
    PacFIN.SABL.Catch.List.12.Aug.2022 <- PacFIN.Catch.Extraction("('SABL')")
    load("LBData.1981.2021.RData")
    load("LB.ShortForm.with.Hake.Strat.Ves.num.Mackerel 26 May 2022.RData")
    
    Compare.Raw.LogB.to.Proc.Data.and.FT('SABL', c('W', 'O', 'C'), PacFIN.SABL.Catch.List.12.Aug.2022$PacFIN.PSMFC.Summary.Catch, LBData.1981.2021, LB.ShortForm.with.Hake.Strat.Ves.num.Mackerel)
    
    Compare.Raw.LogB.to.Proc.Data.and.FT('SABL', 'W', PacFIN.SABL.Catch.List.12.Aug.2022$PacFIN.PSMFC.Summary.Catch, LBData.1981.2021, LB.ShortForm.with.Hake.Strat.Ves.num.Mackerel)
    Compare.Raw.LogB.to.Proc.Data.and.FT('SABL', 'O', PacFIN.SABL.Catch.List.12.Aug.2022$PacFIN.PSMFC.Summary.Catch, LBData.1981.2021, LB.ShortForm.with.Hake.Strat.Ves.num.Mackerel)
    Compare.Raw.LogB.to.Proc.Data.and.FT('SABL', 'C', PacFIN.SABL.Catch.List.12.Aug.2022$PacFIN.PSMFC.Summary.Catch, LBData.1981.2021, LB.ShortForm.with.Hake.Strat.Ves.num.Mackerel)

    # --- Skates ---
     PacFIN.Longnose.Catch.List.22.Jul.2022 <- PacFIN.Catch.Extraction("('LSKT')")
     PacFIN.BigSkate.Catch.List.22.Jul.2022 <- PacFIN.Catch.Extraction("('BSKT', 'BSK1')")
     PacFIN.USKT.Catch.List.22.Jul.2022 <- PacFIN.Catch.Extraction("('USKT')")
     # PacFIN.CSKT.Catch.List.11.Aug.2022 <- PacFIN.Catch.Extraction("('CSKT')")
     # PacFIN.OSKT.Catch.List.11.Aug.2022 <- PacFIN.Catch.Extraction("('OSKT')")
     
     load("W:\\ALL_USR\\JRW\\PacFIN & RACEBASE.R\\DATA to Others\\2022\\Skate Catch Data to Vlada\\PacFIN.BigSkate.Catch.List.22.Jul.2022.RData")
     load("W:\\ALL_USR\\JRW\\PacFIN & RACEBASE.R\\DATA to Others\\2022\\Skate Catch Data to Vlada\\PacFIN.Longnose.Catch.List.22.Jul.2022.RData")
     load("W:\\ALL_USR\\JRW\\PacFIN & RACEBASE.R\\DATA to Others\\2022\\Skate Catch Data to Vlada\\PacFIN.USKT.Catch.List.22.Jul.2022.RData")
     
     PacFIN.3.skates.PacFIN.PSMFC.Summary.Catch <- rbind(PacFIN.Longnose.Catch.List.22.Jul.2022$PacFIN.PSMFC.Summary.Catch, PacFIN.BigSkate.Catch.List.22.Jul.2022$PacFIN.PSMFC.Summary.Catch, 
                                                   PacFIN.USKT.Catch.List.22.Jul.2022$PacFIN.PSMFC.Summary.Catch)
     
     Compare.Raw.LogB.to.Proc.Data.and.FT(c('LSKT', 'BSKT', 'USKT'), c('W', 'O', 'C'), PacFIN.3.skates.PacFIN.PSMFC.Summary.Catch, LBData.1981.2021, LB.ShortForm.with.Hake.Strat.Ves.num.Mackerel)
     
     Compare.Raw.LogB.to.Proc.Data.and.FT(c('LSKT', 'BSKT', 'USKT'), 'W', PacFIN.3.skates.PacFIN.PSMFC.Summary.Catch, LBData.1981.2021, LB.ShortForm.with.Hake.Strat.Ves.num.Mackerel)
     Compare.Raw.LogB.to.Proc.Data.and.FT(c('LSKT', 'BSKT', 'USKT'), 'O', PacFIN.3.skates.PacFIN.PSMFC.Summary.Catch, LBData.1981.2021, LB.ShortForm.with.Hake.Strat.Ves.num.Mackerel)
     Compare.Raw.LogB.to.Proc.Data.and.FT(c('LSKT', 'BSKT', 'USKT'), 'C', PacFIN.3.skates.PacFIN.PSMFC.Summary.Catch, LBData.1981.2021, LB.ShortForm.with.Hake.Strat.Ves.num.Mackerel)
     
