
library(JRWToolBox)  # rgit package now loaded with JRWToolBox

# Use gitAFile() directly
# rgit::gitAFile('John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/R/BDS Sp Extraction with Grade & Dahl Info 24 Jul 2020.R', show = FALSE)        

# Use S() which calls gitAFile() once a 'repoPath' is set
repoPath <- "John-R-Wallace-NOAA/PacFIN-Data-Extraction"
rgit::S('BDS Sp Extraction with Grade & Dahl Info 24 Jul 2020.R', show = FALSE)

PacFIN.SBLY.bds.04.Aug.2020 <- bds.sp.extraction("'SBLY'", PacFIN.Catch.Dahl = SBLY.CompFT.04.Aug.2020)
   
save(PacFIN.SBLY.bds.04.Aug.2020, file = 'PacFIN.SBLY.bds.04.Aug.2020.RData')
   
 

Table(PacFIN.SBLY.bds.04.Aug.2020$SAMPLE_YEAR, PacFIN.SBLY.bds.04.Aug.2020$SAMPLE_AGENCY)

Table(is.finite(PacFIN.SBLY.bds.04.Aug.2020$FISH_LENGTH), PacFIN.SBLY.bds.04.Aug.2020$SAMPLE_AGENCY)  # Check for finite values!!!!!!!!
PacFIN.SBLY.bds.04.Aug.2020[!is.finite(PacFIN.SBLY.bds.04.Aug.2020$FISH_LENGTH), ]


Table(PacFIN.SBLY.bds.04.Aug.2020$SEX, PacFIN.SBLY.bds.04.Aug.2020$SAMPLE_AGENCY) # Check for too many unsexed fish !!!!!!!!

histogram(~PacFIN.SBLY.bds.04.Aug.2020$FISH_LENGTH | factor(PacFIN.SBLY.bds.04.Aug.2020$SAMPLE_AGENCY), type='count')


# Any info on condition?
Table(PacFIN.SBLY.bds.04.Aug.2020$COND, PacFIN.SBLY.bds.04.Aug.2020$SAMPLE_AGENCY)

Table(PacFIN.SBLY.bds.04.Aug.2020$COND_AGCODE, PacFIN.SBLY.bds.04.Aug.2020$SAMPLE_AGENCY)

# Table cl has the code descriptions for condition
cl <- import.sql("Select * from pacfin.cl", dsn="PacFIN", uid=UID, pwd=PWD)
renum(cl[grep("COND", cl$NAME),])


# How many re-reads?
change(PacFIN.SBLY.bds.04.Aug.2020)
table(SAMPLE_YEAR[!is.na(age1)], SAMPLE_AGENCY[!is.na(age1)])
table(SAMPLE_YEAR[!is.na(age2) & age2 > 0], SAMPLE_AGENCY[!is.na(age2) & age2 > 0])
table(SAMPLE_YEAR[!is.na(age3) & age3 > 0], SAMPLE_AGENCY[!is.na(age3) & age3 > 0])


Table(PacFIN.SBLY.bds.04.Aug.2020$SPID)

SBLY 
2809


Table(PacFIN.SBLY.bds.04.Aug.2020$AGE_METHOD, PacFIN.SBLY.bds.04.Aug.2020$SAMPLE_AGENCY)
      
         CA   OR    W
  2       0   50    0
  <NA>  838 1710  211

  
# By year
Table(PacFIN.SBLY.bds.04.Aug.2020$SAMPLE_YEAR, PacFIN.SBLY.bds.04.Aug.2020$AGE_METHOD, PacFIN.SBLY.bds.04.Aug.2020$SAMPLE_AGENCY)

# Aging method ( from age_method column description in the bds_age table at: https://pacfin.psmfc.org/pacfin_pub/table_cols.php )
WDFW (B-break and burn; L-length; N-not aged; O-optical scanner; X-sectioning)
ODWF (1-break and burn; 2-surface; 3-scales; 4-thin section; 5-optical scanner; 6-length; 9-unable)
CDFW (B-break and burn; S-surface; T-thin section)

