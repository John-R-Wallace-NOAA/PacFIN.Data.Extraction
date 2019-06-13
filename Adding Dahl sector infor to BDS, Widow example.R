
# ---- This code snippet matches Dahl Sector information from Comprehensive_FT onto the BDS extration.  Brad Stenberg (PacFIN) says there is no better way. ----

library(JRWToolBox)

# If you have copied and updated JRWToolBox::gitEdit() with your favorite editor, then download and insert this script into your editor with:
gitEdit('Adding Dahl sector infor to BDS, Widow example.R', 'John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/')



load("WDOW.CompFT.13.Jun.2019.dmp")
load("PacFIN.WDOW.bds.13.Jun.2019.dmp")


JRWToolBox::Table(WDOW.CompFT.13.Jun.2019$DAHL_SECTOR, WDOW.CompFT.13.Jun.2019$ARID)

PacFIN.WDOW.bds.13.Jun.2019 <- JRWToolBox:match.f(PacFIN.WDOW.bds.13.Jun.2019, WDOW.CompFT.13.Jun.2019, "FTID", "FTID", "DAHL_SECTOR")
PacFIN.WDOW.bds.13.Jun.2019[1:4,]


# Percent matching
(notMissing <- JRWToolBox::Table(!is.na(PacFIN.WDOW.bds.13.Jun.2019$DAHL_SECTOR)))
100 * notMissing[2]/sum(notMissing)


JRWToolBox::Table(PacFIN.WDOW.bds.13.Jun.2019$DAHL_SECTOR, PacFIN.WDOW.bds.13.Jun.2019$SAMPLE_YEAR, PacFIN.WDOW.bds.13.Jun.2019$SAMPLE_AGENCY)


# Re-save BDS
save(PacFIN.WDOW.bds.13.Jun.2019, file="PacFIN.WDOW.bds.13.Jun.2019.dmp")

