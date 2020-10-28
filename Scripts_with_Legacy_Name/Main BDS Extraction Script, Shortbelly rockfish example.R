
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

          NAME YEAR LENGTH CODE                           DESCRIPTION
1    CONDITION    0      1    D                      dressed, head on
2    CONDITION    0      1    E                       fish eggs (roe)
3    CONDITION    0      1    F                                fillet
4    CONDITION    0      1    H                     dressed, head off
5    CONDITION    0      1    L                            liver only
6    CONDITION    0      1    O                other known conditions
7    CONDITION    0      1    Q                            heads only
8    CONDITION    0      1    R                                 round
9    CONDITION    0      1    S                   shucked (shellfish)
10   CONDITION    0      1    T            dressed, head and tail off
11   CONDITION    0      1    U                           unspecified
12   CONDITION    0      1    V flakes (contact CDFG for description)
13   CONDITION    0      1    W                            wings only
14   CONDITION    0      1    X              frozen dressed, head off
15   CONDITION    0      1    Y                          frozen round
16   CONDITION    0      1    Z               frozen dressed, head on
17   CONDITION    0      1    C                claws and/or legs only
18   CONDITION    0      1    A                                 alive
19   CONDITION    0      1    M                                surimi
20   CONDITION    0      1    G        dressed, general, non-specific
21   CONDITION    0      1    J     most probably landed in the round
22 SAMPLE-COND    0      1    D                                  DEAD
23 SAMPLE-COND    0      1    L                                  LIVE
24 SAMPLE-COND    0      1    9                All Landing Conditions
25   CONDITION    0      1    I         dressed, head off eastern cut
26   CONDITION    0      1    K         dressed, head off western cut


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

