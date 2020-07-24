
# Download into your working directory and view this script in R with:
rgit::gitAFile('John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/PacFIN Catch Extraction, Sablefish Example.R', type = "script", File = 'PacFIN Catch Extraction, Sablefish Example.R', show = TRUE)

# If you have copied and updated gitEdit() with your favorite editor, then download and insert this script into your editor with:
gitEdit('PacFIN Catch Extraction, Sablefish Example.R', 'John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/')


# -------- PacFIN login and password  --------
UID <- "wallacej"
PWD <- PacFIN.PW

#  -------- Check species info  --------

sp <- import.sql("Select * from pacfin.sp", dsn="PacFIN", uid= UID,  pwd = PWD)

sp[grep("SABLEFISH",  sp$CNAME), 1:7] # Same as below

sp[grep("SBL",  sp$SPID), 1:7]

     SPID     CNAME COMPLEX COMPLEX2 COMPLEX3 MGRP              SNAME
309 SABL SABLEFISH    ROND     ....     .... GRND ANOPLOPOMA FIMBRIA


# Example of third category from BOCACCIO+CHILIPEPPER
# 232 RCK1 BOCACCIO+CHILIPEPPER RCKFSH    ROCK     ....     NSLF GRND            SEBASTES SPP.

# The 'Agency market category listing' on the PadFIN website gives some more state information on the codes:
SABLEFISH                      SABL C    190      SABLEFISH     
SABLEFISH                      SABL O    477      SABLEFISH      
SABLEFISH                      SABL W    221      SABLEFISH                         ANOPLOPOMA FIMBRIA 
SABLEFISH                      SABL W    321      SABLEFISH (REDUCTION)             ANOPLOPOMA FIMBRIA   
SABLEFISH                      SABL W    421      SABLEFISH (ANIMAL FOOD)           ANOPLOPOMA FIMBRIA 


# -------- Data from the Comprehensive_FT table --------

# Gear table
(gr <- import.sql("Select * from pacfin.gr", dsn="PacFIN", uid=UID, pwd=PWD))

# Area table
ar <- import.sql("Select * from pacfin.ar", dsn="PacFIN", uid=UID, pwd=PWD)
AR_COUNCIL_P <- renum(ar[ar$COUNCIL %in% 'P',])

# Only the created 'INPFC_PSMFC_AREA_GROUP %in% PSMFC' gets exculsively the more finer areas of PSMFC.
# (Old but still correct: This will now allow a mapping between ARID to INPFC_PSMFC_AREA_GROUP which could be renamed to ARID for a foo sc table)
# Last 14 rows of the AR_COUNCIL_P table are PSMFC
AR_COUNCIL_P$INPFC_PSMFC_AREA_GROUP <- "INPFC"
AR_COUNCIL_P$INPFC_PSMFC_AREA_GROUP[AR_COUNCIL_P$NAME %in%  c("1A", "1B", "MNTREY BAY", "1E", "1C", "2A", "2B", "2C", "2E", "2F", "2D", "3A", "3B", "3C-S")] <- "PSMFC"  
AR_COUNCIL_P

# COUNCIL_CODE = 'P'; with research catch included
# For species with a nominal category use, e.g.:  < PACFIN_SPECIES_CODE = any ('PTRL', 'PTR1') >
SABL.CompFT.05.May.2019 <- JRWToolBox::import.sql(
        "Select COUNCIL_CODE, AGENCY_CODE, DAHL_GROUNDFISH_CODE, INPFC_AREA_TYPE_CODE, LANDING_YEAR, LANDING_DATE, FTID, PARTICIPATION_GROUP_CODE, PACFIN_CATCH_AREA_CODE, ORIG_PACFIN_CATCH_AREA_CODE, PORT_CODE, FLEET_CODE, VESSEL_ID, 
                             PACFIN_GEAR_CODE, IS_IFQ_LANDING, REMOVAL_TYPE_CODE, CONDITION_CODE, DISPOSITION_CODE, EXVESSEL_REVENUE, PACFIN_SPECIES_CODE, NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE, 
                             IS_SPECIES_COMP_USED, GRADE_CODE, GRADE_NAME, PACFIN_GROUP_GEAR_CODE, ROUND_WEIGHT_LBS, LANDED_WEIGHT_MTONS                         
          from pacfin_marts.Comprehensive_FT 
         where PACFIN_SPECIES_CODE = any ('SABL') 
           and COUNCIL_CODE = 'P' 
           and AGENCY_CODE in ('W','O','C')", dsn="PacFIN", uid=UID, pwd=PWD)

# Grab nameConvertVdrfdToCompFT from GitHub and convert to the old style short names
rgit::gitAFile('John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/nameConvertVdrfdToCompFT.R')
names(SABL.CompFT.05.May.2019) <- JRWToolBox::recode.simple(names(SABL.CompFT.05.May.2019), nameConvertVdrfdToCompFT)


# Match INPFC_PSMFC_AREA_GROUP and compare to INPFC_ARID and ARID. 
# SABL.vdv.28.Mar.2019 <- match.f(SABL.vdv.28.Mar.2019, AR_COUNCIL_P, "ARID", "ARID", c("COUNCIL", "INPFC_ARID", "INPFC_PSMFC_AREA_GROUP"))
# tmp <- match.f(SABL.CompFT.05.May.2019, AR_COUNCIL_P, "ARID", "ARID", "INPFC_ARID")
SABL.CompFT.05.May.2019 <- match.f(SABL.CompFT.05.May.2019, AR_COUNCIL_P, "ARID", "ARID", "INPFC_PSMFC_AREA_GROUP")

Table(SABL.CompFT.05.May.2019$INPFC_ARID, SABL.CompFT.05.May.2019$INPFC_PSMFC_AREA_GROUP)
   
      INPFC  PSMFC
  CL  43465 481694
  CP      0  89012
  EK  94094 128532
  MT      0 189418
  OC  10495      0
  UI  24550      0
  VN 128196 179739

 
Table(SABL.CompFT.05.May.2019$INPFC_ARID, SABL.CompFT.05.May.2019$ARID)

         1A     1B     1C     2A     2B     2C     2D     2E     2F     3A     3B     3S     CL     EK     OC     TL     UP     VN
  CL      0      0      0      0 132728  70760      1  60447  74623 143135      0      0  43455      0      0     10      0      0
  CP  89012      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
  EK      0      0 128532  94086      0      0      0      0      0      0      0      0      0      8      0      0      0      0
  MT      0 189418      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
  OC      0      0      0      0      0      0      0      0      0      0      0      0      0      0  10495      0      0      0
  UI      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0  24550      0
  VN      0      0      0      0      0      0      0      0      0      0  93263  86476      0      0      0      0      0 128196

  
  
Table(SABL.CompFT.05.May.2019$INPFC_PSMFC_AREA_GROUP, SABL.CompFT.05.May.2019$ARID)
       
            1A     1B     1C     2A     2B     2C     2D     2E     2F     3A     3B     3S     CL     EK     OC     TL     UP     VN
  INPFC      0      0      0      0      0      0      0      0      0      0      0      0  43455      8  10495     10  24560 128215
  PSMFC  89021 189442 128532  94087 132729  70760      1  60447  74623 143135  93263  86476      0      0      0      0      0      0



# Create W_O_C_Port_Groups
SABL.CompFT.05.May.2019$W_O_C_Port_Groups <- SABL.CompFT.05.May.2019$AGID
SABL.CompFT.05.May.2019$W_O_C_Port_Groups[SABL.CompFT.05.May.2019$AGID %in% 'W'] <- "AWA"
SABL.CompFT.05.May.2019$W_O_C_Port_Groups[SABL.CompFT.05.May.2019$AGID %in% 'O'] <- "AOR"
SABL.CompFT.05.May.2019$W_O_C_Port_Groups[SABL.CompFT.05.May.2019$AGID %in% 'C'] <- "ACA"

# Create PERIOD (months) from TDATE
SABL.CompFT.05.May.2019$PERIOD <- Months.POSIXt(SABL.CompFT.05.May.2019$TDATE)

# Look at the data
Table(SABL.CompFT.05.May.2019$SPID, SABL.CompFT.05.May.2019$W_O_C_Port_Groups)

Table(SABL.CompFT.05.May.2019$SPID, SABL.CompFT.05.May.2019$YEAR)

Table(SABL.CompFT.05.May.2019$SPID, SABL.CompFT.05.May.2019$YEAR, SABL.CompFT.05.May.2019$AGID)

, ,  = C

      
        1981  1982  1983  1984  1985  1986  1987  1988  1989  1990  1991  1992  1993  1994  1995  1996  1997  1998  1999  2000  2001  2002  2003  2004  2005  2006  2007  2008  2009  2010  2011  2012  2013
  SABL  6779  8094  6290  6150  6878  7388  6825  6802  8121  9223 11008 12675  8394  7429 18781 20462 18849 11231 12749 13225 10841 10707 11257  9238 10014  9652  8628  9208 10980 11008  8589  6663  7385
      
        2014  2015  2016  2017  2018  2019
  SABL  6882  7504  7456  7037  5960  1821

, ,  = O

      
        1981  1982  1983  1984  1985  1986  1987  1988  1989  1990  1991  1992  1993  1994  1995  1996  1997  1998  1999  2000  2001  2002  2003  2004  2005  2006  2007  2008  2009  2010  2011  2012  2013
  SABL  3735  7002  7844  5276  5911  5398 12140 15916 21703 24002 32499 38188 52498 35355 39661 39883 41462 29279 30364 22116 22069 15462 19903 14094 13388 16248 15519 19493 25196 11732 13426 11254  9203
      
        2014  2015  2016  2017  2018  2019
  SABL  6538 10779 10605 11002  9564   862

, ,  = W

      
        1981  1982  1983  1984  1985  1986  1987  1988  1989  1990  1991  1992  1993  1994  1995  1996  1997  1998  1999  2000  2001  2002  2003  2004  2005  2006  2007  2008  2009  2010  2011  2012  2013
  SABL  2169  3871  3563  5221  5141  5427  6747  7927  6815  7251 10671 16860 14005 12377 12539 13076 13068  8074  9225  8408  8715  6909  8504  7326  8032  6933  6082  5270  5535  4978  5265  4729  3656
      
        2014  2015  2016  2017  2018  2019
  SABL  3410  3567  3865  4694  4402   200


  
  
save(SABL.CompFT.05.May.2019, file = 'SABL.CompFT.05.May.2019.RData')


# Fleet breakdown including research and tribal catch ( Fleet type: limited entry <U+21D2> 'LE', open access <U+21D2> 'OA', tribal indian <U+21D2> 'TI', research <U+21D2> 'R', unknown <U+21D2> 'XX' )
   # - Tribal catch is included but not separable in a 'sc' type table.
   # - I would not assume this is all the research catch and would ask the Region what they have.

change(SABL.CompFT.05.May.2019)
SABL.Research.Catch.05.May.2019 <- agg.table(aggregate(list(Catch.mt = CATCH.LBS/2204.62), List(YEAR, FLEET), sum, na.rm=T), Print=F)
r(SABL.Research.Catch.05.May.2019, 2)
save(SABL.Research.Catch.05.May.2019, file = 'SABL.Research.Catch.05.May.2019.dmp')
         TI       XX      R      LE     OA
1981   0.00 11418.89     NA      NA     NA
1982     NA 18627.05     NA      NA     NA
1983   0.02 14651.72     NA      NA     NA
1984   0.09 14014.95     NA      NA     NA
1985   0.11 14132.19     NA      NA     NA
1986   0.88 13149.43     NA      NA     NA
1987   3.43 12598.01     NA      NA     NA
1988   6.65 10737.06     NA      NA     NA
1989 130.10 10154.34     NA      NA     NA
1990 215.90  8849.22   0.28      NA     NA
1991 299.16  9201.54     NA      NA     NA
1992 344.16  9016.91     NA      NA     NA
1993 321.56  7824.87     NA      NA     NA
1994 309.34       NA     NA 6606.69 662.51
1995 769.34       NA   0.14 6526.30 618.99
1996 853.53       NA     NA 6781.86 681.57
1997 805.17       NA   0.93 6604.55 532.47
1998 444.85       NA  11.16 3759.19 168.81
1999 710.44       NA  26.35 5627.82 277.89
2000 705.70       NA  25.21 5106.68 443.56
2001 658.69       NA   5.97 4545.35 426.24
2002 436.59       NA   5.29 2956.96 399.64
2003 602.46       NA 100.55 4114.99 601.89
2004 710.08       NA   2.42 4555.69 487.84
2005 699.84       NA   4.89 4582.29 921.31
2006 669.45       NA   3.25 4720.51 805.76
2007 516.32       NA   3.09 4253.46 471.96
2008 526.48       NA   2.40 4778.52 564.60
2009 639.48       NA   0.65 5626.14 932.08
2010 582.68       NA   0.63 5280.93 967.81
2011 535.72       NA   1.56 5299.98 583.58
2012 583.51       NA  11.15 4376.13 328.65
2013 364.07       NA   7.94 3563.40 204.94
2014 437.30       NA   4.79 3689.62 294.60
2015 513.73       NA  21.15 4204.51 431.61
2016 577.39       NA  12.85 4425.80 397.12
2017 508.33       NA   2.94 4561.49 468.05
2018 434.78       NA  27.24 4326.32 417.72
2019     NA       NA     NA  682.77 270.59





# ------------------------------------------- INPFC sc table -----------------------------------------------------------------------------------------------------------------------

# Take out research catch for a summary catch (sc) like table
# change(SABL.CompFT.05.May.2019[!(SABL.CompFT.05.May.2019$REMOVAL_TYPE %in% "R") & SABL.CompFT.05.May.2019$INPFC_PSMFC_AREA_GROUP %in% 'INPFC',])  <<== !!! WRONG !!! see ARID = INPFC_ARID below

rm(SPID)  # Old in PacFIN R working directory

change(SABL.CompFT.05.May.2019[!(SABL.CompFT.05.May.2019$REMOVAL_TYPE %in% "R"), ])
PacFIN.SABL.Catch.INPFC.05.May.2019 <- aggregate(list(CATCH.KG = CATCH.LBS/2.2046), list(COUNCIL = COUNCIL, DAHL_SECTOR = DAHL_SECTOR, YEAR = YEAR, PERIOD = PERIOD, SPID = SPID, ARID = INPFC_ARID, 
                                          GRID = GRID, GRGROUP = GRGROUP, PCID = W_O_C_Port_Groups), sum, na.rm=T)
PacFIN.SABL.Catch.INPFC.05.May.2019 <- sort.f(PacFIN.SABL.Catch.INPFC.05.May.2019, c('YEAR', 'PERIOD', 'ARID', 'GRID', 'PCID'))

change(PacFIN.SABL.Catch.INPFC.05.May.2019)
SC.vdv.SABL.INPFC.agg <- agg.table(aggregate(list(Catch.mt = CATCH.KG/1000), List(YEAR, PCID), sum), Print = F)
SC.vdv.SABL.INPFC.agg[is.na(SC.vdv.SABL.INPFC.agg)] <- 0
r(SC.vdv.SABL.INPFC.agg, 3)

Table(PacFIN.SABL.Catch.INPFC.05.May.2019$ARID, PacFIN.SABL.Catch.INPFC.05.May.2019$PCID)
 
      ACA  AOR  AWA
  CL    0 2835 1856
  CP 3280    0    0
  EK 2357 1627   11
  MT 4189   22    0
  OC    0    0  624
  UI   70  196    2
  VN    0  589 2281


save(PacFIN.SABL.Catch.INPFC.05.May.2019, file= 'PacFIN.SABL.Catch.INPFC.05.May.2019.dmp')


# ------------------------------------------- PSMFC sc table ------------------------------------------------------------------------------------------------------------------------


change(SABL.CompFT.05.May.2019[!(SABL.CompFT.05.May.2019$REMOVAL_TYPE %in% "R") & SABL.CompFT.05.May.2019$INPFC_PSMFC_AREA_GROUP %in% 'PSMFC',])
PacFIN.SABL.Catch.PSMFC.05.May.2019 <- aggregate(list(CATCH.KG = CATCH.LBS/2.20462), list(COUNCIL = COUNCIL, DAHL_SECTOR = DAHL_SECTOR, YEAR = YEAR, PERIOD = PERIOD, SPID = SPID, ARID = ARID, 
                                          GRID = GRID, GRGROUP = GRGROUP, PCID = W_O_C_Port_Groups), sum, na.rm=T)
PacFIN.SABL.Catch.PSMFC.05.May.2019 <- sort.f(PacFIN.SABL.Catch.PSMFC.05.May.2019, c('YEAR', 'PERIOD', 'ARID', 'GRID', 'PCID'))


change(PacFIN.SABL.Catch.PSMFC.05.May.2019)
SC.vdv.SABL.PSMFC.agg <- agg.table(aggregate(list(Catch.mt = CATCH.KG/1000), List(YEAR, PCID), sum, na.rm=T), Print = F)
SC.vdv.SABL.PSMFC.agg[is.na(SC.vdv.SABL.PSMFC.agg)] <- 0
r(SC.vdv.SABL.PSMFC.agg, 3)

Table(PacFIN.SABL.Catch.PSMFC.05.May.2019$ARID, PacFIN.SABL.Catch.PSMFC.05.May.2019$PCID)

      ACA  AOR  AWA
  1A 3280    0    0
  1B 4189   22    0
  1C 2356  496    3
  2A   14 1607    7
  2B    0 2068   46
  2C    0  605  162
  2D    0    1    0
  2E    0  657    0
  2F    0 1467    0
  3A    0 1807  525
  3B    0  583  634
  3S    0  423  591

  
save(PacFIN.SABL.Catch.PSMFC.05.May.2019, file="PacFIN.SABL.Catch.PSMFC.05.May.2019.dmp")



#----------------- Comparison of PSMFC sc table to INPFC sc table -----------------------------


names(SC.vdv.SABL.INPFC.agg) <- paste0(names(SC.vdv.SABL.INPFC.agg), ".INPFC")
(SC.vdv.SABL.INPFC.agg <- SC.vdv.SABL.INPFC.agg[,order(names(SC.vdv.SABL.INPFC.agg))])  # Make sure the ordering is correct

names(SC.vdv.SABL.PSMFC.agg) <- paste0(names(SC.vdv.SABL.PSMFC.agg), ".PSMFC")
(SC.vdv.SABL.PSMFC.agg <- SC.vdv.SABL.PSMFC.agg[,order(names(SC.vdv.SABL.PSMFC.agg))])

# Need to take off last year to match below
# SC.vdv.SABL.PSMFC.agg <- SC.vdv.SABL.PSMFC.agg[-nrow(SC.vdv.SABL.PSMFC.agg), ]

N <- nrow(SC.vdv.SABL.INPFC.agg)
Diff.and.Ratio <- cbind(SC.vdv.SABL.INPFC.agg, " " = rep("    ", N), SC.vdv.SABL.PSMFC.agg, " " = rep("    ", N), 
                       SC.vdv.SABL.INPFC.agg - SC.vdv.SABL.PSMFC.agg, " " = rep("    ", N), SC.vdv.SABL.INPFC.agg/SC.vdv.SABL.PSMFC.agg)

names(Diff.and.Ratio) <- c(names(SC.vdv.SABL.INPFC.agg), " ", names(SC.vdv.SABL.PSMFC.agg), "  ", "CA.diff" , "OR.diff", "WA.diff", " ", "CA.ratio" , "OR.ratio", "WA.ratio")
Tmp.Diff <- Diff.and.Ratio[, 1:11]
# Tmp.Diff[is.na(Tmp.Diff )] <- 0
Diff.and.Ratio <- cbind(Tmp.Diff, Diff.and.Ratio[,12:15]) #  unsupported matrix index in replacement, so need temp file

r(Diff.and.Ratio, 2)

     ACA.INPFC AOR.INPFC AWA.INPFC      ACA.PSMFC AOR.PSMFC AWA.PSMFC      CA.diff OR.diff WA.diff      CA.ratio OR.ratio WA.ratio
1981   6718.47   2343.43   2357.10        6716.28   1039.48    559.34         2.19 1303.95 1797.75          1.00     2.25     4.21
1982   9656.05   5089.73   3881.44        9655.97   2138.87   1708.13         0.09 2950.85 2173.31          1.00     2.38     2.27
1983   6694.87   4642.46   3314.55        6694.67   1891.62   1290.63         0.20 2750.84 2023.91          1.00     2.45     2.57
1984   4826.82   4838.08   4350.27        4826.64   2063.28   2224.78         0.18 2774.79 2125.49          1.00     2.34     1.96
1985   5174.07   5272.77   3685.59        5173.90   2431.86    739.99         0.17 2840.91 2945.61          1.00     2.17     4.98
1986   6220.31   4654.72   2275.40        6220.10   2530.73    547.94         0.21 2123.99 1727.46          1.00     1.84     4.15
1987   4414.62   5238.15   2948.79        4377.32   5234.91    827.37        37.29    3.24 2121.42          1.01     1.00     3.56
1988   3856.73   4082.12   2804.95        3856.70   4081.44    664.32         0.03    0.68 2140.63          1.00     1.00     4.22
1989   4075.16   3948.48   2260.89        4075.00   3948.44    469.33         0.17    0.04 1791.56          1.00     1.00     4.82
1990   3750.67   3704.99   1609.54        3737.60   3704.91    345.91        13.07    0.08 1263.63          1.00     1.00     4.65
1991   3358.30   3905.98   2236.51        3357.48   3905.94    324.99         0.81    0.04 1911.52          1.00     1.00     6.88
1992   3715.22   3856.12   1789.82        3714.08   3853.04    361.26         1.13    3.08 1428.57          1.00     1.00     4.95
1993   2598.15   3835.48   1712.87        2597.46   3835.16    425.15         0.68    0.32 1287.73          1.00     1.00     4.03
1994   2185.81   4004.84   1387.95        2185.79   4000.94    384.71         0.02    3.90 1003.24          1.00     1.00     3.61
1995   2818.97   3134.68   1961.05        2818.95   3133.11    315.87         0.03    1.58 1645.18          1.00     1.00     6.21
1996   3195.90   3174.86   1946.28        3195.87   3174.76    312.24         0.03    0.10 1634.03          1.00     1.00     6.23
1997   2968.12   2924.25   2049.90        2967.86   2921.48    345.59         0.25    2.76 1704.31          1.00     1.00     5.93
1998   1448.50   1744.21   1180.18        1448.49   1742.82    184.66         0.01    1.39  995.51          1.00     1.00     6.39
1999   1970.07   2946.56   1699.05        1970.05   2946.52    277.69         0.02    0.03 1421.36          1.00     1.00     6.12
2000   1895.06   2796.76   1564.18        1895.04   2742.48    195.21         0.02   54.28 1368.97          1.00     1.02     8.01
2001   1557.76   2525.45   1547.11        1557.74   2514.93    278.44         0.01   10.53 1268.67          1.00     1.00     5.56
2002   1313.31   1405.75   1074.16        1313.30   1403.20    129.34         0.01    2.56  944.81          1.00     1.00     8.30
2003   1650.11   2049.55   1619.73        1650.09   2025.12    188.19         0.01   24.44 1431.54          1.00     1.01     8.61
2004   1433.88   2551.63   1768.15        1433.87   2411.56    195.77         0.01  140.07 1572.37          1.00     1.06     9.03
2005   1651.17   2645.11   1907.22        1651.16   2620.68    225.68         0.01   24.42 1681.53          1.00     1.01     8.45
2006   1641.00   2648.80   1905.98        1640.98   2633.86      0.00         0.01   14.94 1905.98          1.00     1.01      Inf
2007   1471.00   2427.47   1343.32        1470.99   2407.48    165.52         0.01   19.99 1177.79          1.00     1.01     8.12
2008   1593.30   2957.24   1319.11        1593.29   2945.80    156.93         0.01   11.44 1162.18          1.00     1.00     8.41
2009   2311.87   3301.16   1584.75        2311.33   3258.63    201.98         0.54   42.52 1382.77          1.00     1.01     7.85
2010   2498.19   2857.50   1475.80        2498.16   2857.48    113.83         0.02    0.03 1361.96          1.00     1.00    12.96
2011   2566.08   2302.09   1550.32        2566.05   2301.68    193.94         0.02    0.41 1356.38          1.00     1.00     7.99
2012   1782.80   2141.25   1364.29        1782.79   2139.99    130.13         0.02    1.27 1234.17          1.00     1.00    10.48
2013   1502.80   1735.84    893.80        1502.79   1734.62     76.93         0.01    1.23  816.87          1.00     1.00    11.62
2014   1874.69   1490.82   1056.05        1874.67   1490.38     75.33         0.02    0.44  980.72          1.00     1.00    14.02
2015   1847.53   2247.41   1054.96        1847.51   2241.08      2.73         0.02    6.33 1052.23          1.00     1.00   386.22
2016   1744.62   2502.33   1153.41        1744.61   2502.31      3.71         0.02    0.02 1149.70          1.00     1.00   311.07
2017   1784.27   2517.15   1236.51        1784.26   2511.86     79.90         0.02    5.29 1156.60          1.00     1.00    15.47
2018   1483.91   2548.42   1146.54        1483.61   2539.83     69.65         0.30    8.59 1076.88          1.00     1.00    16.46
2019    399.27    472.86     81.24         398.73    470.32      0.00         0.54    2.53   81.24          1.00     1.01      Inf



# ARID by YEAR by AGID from vdrfd view - shows where the differences in the INPFC and PSMFC areas are.
Table(SABL.CompFT.05.May.2019$ARID, SABL.CompFT.05.May.2019$YEAR, SABL.CompFT.05.May.2019$AGID)



#  Research catch by year and removal type - compare with FLEET removal
change(SABL.CompFT.05.May.2019)
r(agg.table(aggregate(list(Catch.mt = CATCH.LBS/2204.62), List(YEAR, REMOVAL_TYPE), sum, na.rm=T), Print = F), 3)

             C      O     P      D       R     U      E
1981 11418.893     NA    NA     NA      NA    NA     NA
1982 18627.051     NA    NA     NA      NA    NA     NA
1983 14651.436  0.303    NA     NA      NA    NA     NA
1984 14015.020  0.024    NA     NA      NA    NA     NA
1985 14094.399 37.891 0.009     NA      NA    NA     NA
1986 13129.724 20.584    NA     NA      NA    NA     NA
1987 12590.189 10.871    NA  0.386      NA    NA     NA
1988 10743.709     NA    NA     NA      NA    NA     NA
1989 10280.754     NA 0.039  3.646      NA    NA     NA
1990  9065.119     NA    NA     NA   0.279    NA     NA
1991  9497.216     NA 0.020  3.469      NA    NA     NA
1992  9360.157     NA 0.065  0.852      NA    NA     NA
1993  8146.361  0.054 0.015     NA      NA    NA     NA
1994  7578.301     NA 0.102  0.139      NA    NA     NA
1995  7908.746     NA 1.741  4.147   0.139    NA     NA
1996  8316.638     NA 0.176  0.140      NA    NA     NA
1997  7938.843     NA 0.268  3.082   0.927    NA     NA
1998  4372.722     NA 0.017  0.109  11.165    NA     NA
1999  6614.879     NA 0.595  0.113  26.888 0.035     NA
2000  6254.972     NA 0.900  0.067  25.214    NA     NA
2001  5588.369     NA 1.963  2.852   5.970    NA 37.088
2002  3773.798     NA 1.557  0.796   5.285    NA 17.034
2003  5255.628     NA 1.887  4.617 100.551    NA 57.214
2004  5671.034  4.140 2.631  6.026   2.418    NA 69.779
2005  6174.845     NA 5.084  0.432   4.886 0.660 22.417
2006  6176.711     NA 5.631  2.322   3.245    NA 11.058
2007  5207.592     NA 3.960 18.759   3.095 2.395  9.038
2008  5858.866     NA 4.506  5.861   2.405 0.100  0.269
2009  7160.791     NA 4.994 10.220   0.650    NA 21.700
2010  6798.593  2.306 3.832  8.521   0.629 0.027 18.144
2011  6369.150     NA 6.879  0.474   2.406 0.685 41.241
2012  5233.499     NA 7.522  0.147  11.151    NA 47.132
2013  4118.979     NA 7.429  0.135   7.941 0.613  5.250
2014  4411.635     NA 4.961     NA   4.790    NA  4.925
2015  5137.022     NA 5.898  0.023  21.154    NA  6.911
2016  5390.066     NA 3.967  0.123  12.854    NA  6.096
2017  5488.273     NA 5.223  0.064   2.940    NA 44.316
2018  5126.120     NA 4.202  0.008  27.243 0.268 48.218
2019   953.076     NA 0.253  0.012      NA    NA  0.015







