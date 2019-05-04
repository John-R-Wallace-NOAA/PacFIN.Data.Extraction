
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
gr <- import.sql("Select * from pacfin.gr", dsn="PacFIN", uid=UID, pwd=PWD)

# Area table
ar <- import.sql("Select * from pacfin.ar", dsn="PacFIN", uid=UID, pwd=PWD)
AR_COUNCIL_P <- renum(ar[ar$COUNCIL %in% 'P',])

# Only the created 'INPFC_PSMFC_AREA_GROUP %in% PSMFC' gets exculsively the more finer areas of PSMFC.
# (Old but still correct: This will now allow a mapping between ARID to INPFC_PSMFC_AREA_GROUP which could be renamed to ARID for a foo sc table)
# Last 13 rows of the AR_COUNCIL_P table
AR_COUNCIL_P$INPFC_PSMFC_AREA_GROUP <- "INPFC"
AR_COUNCIL_P$INPFC_PSMFC_AREA_GROUP[AR_COUNCIL_P$NAME %in%  c("1A", "1B", "MNTREY BAY", "1E", "1C", "2B", "2C", "2E", "2F", "2D", "3A", "3B", "3C-S")] <- "PSMFC"  

# COUNCIL_CODE = 'P'; with research catch included
SABL.CompFT.03.May.2019 <- JRWToolBox::import.sql(
        "Select COUNCIL_CODE, AGENCY_CODE, INPFC_AREA_TYPE_CODE, LANDING_YEAR, LANDING_DATE, FTID, PARTICIPATION_GROUP_CODE, PACFIN_CATCH_AREA_CODE, PORT_CODE, FLEET_CODE, VESSEL_ID, 
                             PACFIN_GEAR_CODE, IS_IFQ_LANDING, REMOVAL_TYPE_CODE, CONDITION_CODE, DISPOSITION_CODE, EXVESSEL_REVENUE, PACFIN_SPECIES_CODE, NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE, 
                             IS_SPECIES_COMP_USED, GRADE_CODE, GRADE_NAME, PACFIN_GROUP_GEAR_CODE, ROUND_WEIGHT_LBS, LANDED_WEIGHT_MTONS                         
          from pacfin_marts.Comprehensive_FT 
         where PACFIN_SPECIES_CODE = any ('PTRL', 'PTR1') 
           and COUNCIL_CODE = 'P' 
           and AGENCY_CODE in ('W','O','C')", dsn="PacFIN", uid=UID, pwd=PWD)

# Grab nameConvertVdrfdToCompFT from GitHub and convert to the old style short names
JRWToolBox::gitAFile('John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/nameConvertVdrfdToCompFT.R')
names(SABL.CompFT.03.May.2019) <- JRWToolBox::recode.simple(names(SABL.CompFT.03.May.2019), nameConvertVdrfdToCompFT)
  

# Match INPFC_PSMFC_AREA_GROUP and compare to INPFC_AREA_TYPE_CODE and ARID. 
SABL.CompFT.03.May.2019 <- match.f(SABL.CompFT.03.May.2019, AR_COUNCIL_P, "ARID", "ARID", "INPFC_PSMFC_AREA_GROUP")

Table(SABL.CompFT.03.May.2019$INPFC_AREA_TYPE_CODE, SABL.CompFT.03.May.2019$INPFC_PSMFC_AREA_GROUP)
   
      INPFC  PSMFC
  CL   1346 152241
  CP      0  14112
  EK      0  68915
  MT      0  66238
  OC    228      0
  UI  15424      0
  VN   3471  80616

 
Table(SABL.CompFT.03.May.2019$INPFC_AREA_TYPE_CODE, SABL.CompFT.03.May.2019$ARID)

        1A    1B    1C    2A    2B    2C    2E    2F    3A    3B    3S    CL    OC    TL    UP    VN
  CL     0     0     0     0 34022 20871 23642 21936 51770     0     0  1345     0     1     0     0
  CP 14112     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
  EK     0     0 46702 22213     0     0     0     0     0     0     0     0     0     0     0     0
  MT     0 66238     0     0     0     0     0     0     0     0     0     0     0     0     0     0
  OC     0     0     0     0     0     0     0     0     0     0     0     0   228     0     0     0
  UI     0     0     0     0     0     0     0     0     0     0     0     0     0     0 15424     0
  VN     0     0     0     0     0     0     0     0     0 44555 36061     0     0     0     0  3471
  
  
Table(SABL.CompFT.03.May.2019$INPFC_PSMFC_AREA_GROUP, SABL.CompFT.03.May.2019$ARID)
       
         1A    1B    1C    2A    2B    2C    2E    2F    3A    3B    3S    CL    OC    TL    UP    VN
INPFC     0     0     0     0     0     0     0     0     0     0     0  1345   228     1 15424  3471
PSMFC 14112 66238 46702 22213 34022 20871 23642 21936 51770 44555 36061     0     0     0     0     0


# Create W_O_C_Port_Groups
SABL.CompFT.03.May.2019$W_O_C_Port_Groups <- SABL.CompFT.03.May.2019$AGID
SABL.CompFT.03.May.2019$W_O_C_Port_Groups[SABL.CompFT.03.May.2019$AGID %in% 'W'] <- "AWA"
SABL.CompFT.03.May.2019$W_O_C_Port_Groups[SABL.CompFT.03.May.2019$AGID %in% 'O'] <- "AOR"
SABL.CompFT.03.May.2019$W_O_C_Port_Groups[SABL.CompFT.03.May.2019$AGID %in% 'C'] <- "ACA"

# Create PERIOD (months) from TDATE
SABL.CompFT.03.May.2019$PERIOD <- Months.POSIXt(SABL.CompFT.03.May.2019$TDATE)

# Look at the data
Table(SABL.CompFT.03.May.2019$SPID, SABL.CompFT.03.May.2019$W_O_C_Port_Groups)

Table(SABL.CompFT.03.May.2019$SPID, SABL.CompFT.03.May.2019$YEAR)

Table(SABL.CompFT.03.May.2019$SPID, SABL.CompFT.03.May.2019$YEAR, SABL.CompFT.03.May.2019$AGID)

, ,  = C

      
        1981  1982  1983  1984  1985  1986  1987  1988  1989  1990  1991  1992  1993  1994  1995  1996  1997  1998  1999  2000  2001  2002  2003  2004  2005  2006  2007  2008  2009  2010  2011  2012
  SABL  6779  8094  6290  6150  6878  7388  6825  6802  8121  9223 11008 12675  8394  7429 18781 20462 18849 11231 12728 13199 10832 10686 11235  9222 10014  9652  8628  9191 10968 10939  8575  6640
      
        2013  2014  2015  2016  2017  2018  2019
  SABL  7341  6785  7378  7463  6878  5567     0

, ,  = O

      
        1981  1982  1983  1984  1985  1986  1987  1988  1989  1990  1991  1992  1993  1994  1995  1996  1997  1998  1999  2000  2001  2002  2003  2004  2005  2006  2007  2008  2009  2010  2011  2012
  SABL  3735  7002  7844  5276  5911  5398 12140 15916 21703 24002 32499 38188 52498 35355 39661 39883 41462 29279 30364 22116 22069 15462 19903 14094 13388 16248 15519 19493 25196 11732 13426 11254
      
        2013  2014  2015  2016  2017  2018  2019
  SABL  9203  6520 10765 10605 11002  4989   268

, ,  = W

      
        1981  1982  1983  1984  1985  1986  1987  1988  1989  1990  1991  1992  1993  1994  1995  1996  1997  1998  1999  2000  2001  2002  2003  2004  2005  2006  2007  2008  2009  2010  2011  2012
  SABL  2169  3871  3563  5221  5141  5427  6747  7927  6815  7251 10671 16860 14005 12377 12539 13076 13068  8074  9225  8408  8715  6909  8504  7326  8032  6933  6082  5270  5535  4977  5265  4729
      
        2013  2014  2015  2016  2017  2018  2019
  SABL  3656  3410  3565  3865  4591  4042    21

  
  
save(SABL.CompFT.03.May.2019, file = 'SABL.CompFT.03.May.2019.dmp')


# Fleet breakdown including research and tribal catch ( Fleet type: limited entry ⇒ 'LE', open access ⇒ 'OA', tribal indian ⇒ 'TI', research ⇒ 'R', unknown ⇒ 'XX' )
   # - Tribal catch is included but not separable in a 'sc' type table.
   # - I would not assume this is all the research catch and would ask the Region what they have.

change(SABL.CompFT.03.May.2019)
r(agg.table(aggregate(list(Catch.mt = CATCH.LBS/2204.62), List(YEAR, FLEET), sum, na.rm=T), Print=F), 2)

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
1999 710.44       NA  26.35 5634.18 276.68
2000 705.70       NA  25.21 5107.31 442.93
2001 658.69       NA   5.97 4545.67 426.21
2002 436.59       NA   9.20 2953.03 399.44
2003 602.46       NA 124.29 4113.05 580.11
2004 710.08       NA  13.52 4551.73 479.96
2005 699.84       NA   4.89 4582.29 921.31
2006 669.45       NA   3.25 4720.51 805.76
2007 516.32       NA   3.09 4253.46 471.96
2008 526.48       NA   3.11 4778.29 563.08
2009 639.48       NA   0.65 5626.15 931.58
2010 582.68       NA   0.63 5280.98 967.81
2011 535.72       NA   1.56 5300.00 583.59
2012 583.51       NA  11.15 4374.96 328.66
2013 364.07       NA   7.94 3563.89 203.11
2014 437.30       NA   4.79 3621.32 289.19
2015 513.73       NA  21.15 4191.40 429.62
2016 577.39       NA  12.85 4425.84 397.77
2017 466.35       NA   2.94 4555.81 433.92
2018 434.78       NA   8.51 4338.13 360.85
2019     NA       NA     NA  109.31   6.67




# ------------------------------------------- INPFC sc table -----------------------------------------------------------------------------------------------------------------------

# Take out research catch for a summary catch (sc) like table
# change(SABL.CompFT.03.May.2019[!(SABL.CompFT.03.May.2019$REMOVAL_TYPE %in% "R") & SABL.CompFT.03.May.2019$INPFC_PSMFC_AREA_GROUP %in% 'INPFC',])  <<== !!! WRONG !!! see ARID = INPFC_ARID below

rm(SPID)  # Old in PacFIN R working directory

change(SABL.CompFT.03.May.2019[!(SABL.CompFT.03.May.2019$REMOVAL_TYPE %in% "R"), ])
PacFIN.SABL.Catch.INPFC.03.May.2019 <- aggregate(list(CATCH.KG = CATCH.LBS/2.2046), list(COUNCIL = COUNCIL, DAHL_SECTOR = DAHL_SECTOR, YEAR = YEAR, PERIOD = PERIOD, SPID = SPID, ARID = INPFC_ARID, 
                                          GRID = GRID, GRGROUP = GRGROUP, PCID = W_O_C_Port_Groups), sum, na.rm=T)
PacFIN.SABL.Catch.INPFC.03.May.2019 <- sort.f(PacFIN.SABL.Catch.INPFC.03.May.2019, c('YEAR', 'PERIOD', 'ARID', 'GRID', 'PCID'))

change(PacFIN.SABL.Catch.INPFC.03.May.2019)
SC.vdv.SABL.INPFC.agg <- agg.table(aggregate(list(Catch.mt = CATCH.KG/1000), List(YEAR, PCID), sum), Print = F)
SC.vdv.SABL.INPFC.agg[is.na(SC.vdv.SABL.INPFC.agg)] <- 0
r(SC.vdv.SABL.INPFC.agg, 3)

Table(PacFIN.SABL.Catch.INPFC.03.May.2019$ARID, PacFIN.SABL.Catch.INPFC.03.May.2019$PCID)

      ACA  AOR  AWA
  CL    0 1980 1345
  CP 2257    0    0
  EK 1779 1170   11
  MT 3066   21    0
  OC    0    0  417
  UI   66  192    2
  VN    0  521 1630


save(PacFIN.SABL.Catch.INPFC.03.May.2019, file= 'PacFIN.SABL.Catch.INPFC.03.May.2019.dmp')


# ------------------------------------------- PSMFC sc table ------------------------------------------------------------------------------------------------------------------------


change(SABL.CompFT.03.May.2019[!(SABL.CompFT.03.May.2019$REMOVAL_TYPE %in% "R") & SABL.CompFT.03.May.2019$INPFC_PSMFC_AREA_GROUP %in% 'PSMFC',])
PacFIN.SABL.Catch.PSMFC.03.May.2019 <- aggregate(list(CATCH.KG = CATCH.LBS/2.20462), list(COUNCIL = COUNCIL, DAHL_SECTOR = DAHL_SECTOR, YEAR = YEAR, PERIOD = PERIOD, SPID = SPID, ARID = ARID, 
                                          GRID = GRID, GRGROUP = GRGROUP, PCID = W_O_C_Port_Groups), sum, na.rm=T)
PacFIN.SABL.Catch.PSMFC.03.May.2019 <- sort.f(PacFIN.SABL.Catch.PSMFC.03.May.2019, c('YEAR', 'PERIOD', 'ARID', 'GRID', 'PCID'))


change(PacFIN.SABL.Catch.PSMFC.03.May.2019)
SC.vdv.SABL.PSMFC.agg <- agg.table(aggregate(list(Catch.mt = CATCH.KG/1000), List(YEAR, PCID), sum, na.rm=T), Print = F)
SC.vdv.SABL.PSMFC.agg[is.na(SC.vdv.SABL.PSMFC.agg)] <- 0
r(SC.vdv.SABL.PSMFC.agg, 3)

Table(PacFIN.SABL.Catch.PSMFC.03.May.2019$ARID, PacFIN.SABL.Catch.PSMFC.03.May.2019$PCID)

      ACA  AOR  AWA
  1A 2257    0    0
  1B 3066   21    0
  1C 1778  458    3
  2A   14 1150    7
  2B    0 1562   43
  2C    0  578  153
  2D    0    1    0
  2E    0  566    0
  2F    0 1005    0
  3A    0 1397  472
  3B    0  513  537
  3S    0  377  495

 
save(PacFIN.SABL.Catch.PSMFC.03.May.2019, file="PacFIN.SABL.Catch.PSMFC.03.May.2019.dmp")


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
1999   1975.22   2946.56   1699.05        1975.20   2946.52    277.69         0.02    0.03 1421.36          1.00     1.00     6.12
2000   1895.06   2796.76   1564.18        1895.05   2742.48    195.21         0.02   54.28 1368.97          1.00     1.02     8.01
2001   1558.05   2525.45   1547.11        1558.04   2514.93    278.44         0.01   10.53 1268.67          1.00     1.00     5.56
2002   1309.19   1405.75   1074.16        1309.18   1403.20    129.34         0.01    2.56  944.81          1.00     1.00     8.30
2003   1626.38   2049.55   1619.73        1626.37   2025.12    188.19         0.01   24.44 1431.54          1.00     1.01     8.61
2004   1422.04   2551.63   1768.15        1422.03   2411.56    195.77         0.01  140.07 1572.37          1.00     1.06     9.03
2005   1651.17   2645.11   1907.22        1651.16   2620.68    225.68         0.01   24.42 1681.53          1.00     1.01     8.45
2006   1641.00   2648.80   1905.98        1640.98   2633.86      0.00         0.01   14.94 1905.98          1.00     1.01      Inf
2007   1471.00   2427.47   1343.32        1470.99   2407.48    165.52         0.01   19.99 1177.79          1.00     1.01     8.12
2008   1591.55   2957.24   1319.11        1591.54   2945.80    156.93         0.01   11.44 1162.18          1.00     1.00     8.41
2009   2311.37   3301.16   1584.75        2311.35   3258.63    201.98         0.02   42.52 1382.77          1.00     1.01     7.85
2010   2498.23   2857.50   1475.79        2498.21   2857.48    113.83         0.02    0.03 1361.96          1.00     1.00    12.96
2011   2566.10   2302.09   1550.32        2566.08   2301.68    193.94         0.02    0.41 1356.38          1.00     1.00     7.99
2012   1781.63   2141.25   1364.29        1781.61   2139.99    130.13         0.02    1.27 1234.17          1.00     1.00    10.48
2013   1501.47   1735.84    893.80        1501.45   1734.62     76.93         0.01    1.23  816.87          1.00     1.00    11.62
2014   1801.41   1490.39   1056.05        1801.39   1489.95     75.33         0.02    0.44  980.72          1.00     1.00    14.02
2015   1845.05   2234.97   1054.78        1845.04   2228.64      2.55         0.02    6.33 1052.23          1.00     1.00   413.26
2016   1745.31   2502.33   1153.41        1745.30   2502.31      3.71         0.02    0.02 1149.70          1.00     1.00   311.07
2017   1745.90   2517.15   1193.09        1745.88   2511.86     79.90         0.02    5.29 1113.18          1.00     1.00    14.93
2018   1420.44   2567.15   1146.21        1420.43   2567.13     34.14         0.01    0.02 1112.07          1.00     1.00    33.58
2019      0.00    109.09      6.88           0.00    109.09      0.00         0.00    0.00    6.88           NaN     1.00      Inf


# ARID by YEAR by AGID from vdrfd view - shows where the differences in the INPFC and PSMFC areas are.
Table(SABL.CompFT.03.May.2019$ARID, SABL.CompFT.03.May.2019$YEAR, SABL.CompFT.03.May.2019$AGID)



#  Research catch by year and removal type - compare with FLEET removal
change(SABL.CompFT.03.May.2019)
r(agg.table(aggregate(list(Catch.mt = CATCH.LBS/2204.62), List(YEAR, REMOVAL_TYPE), sum, na.rm=T), Print = F), 3)

           C     D     P     R     E     U
1981  29.342    NA    NA    NA    NA    NA
1982  29.004    NA    NA    NA    NA    NA
1983  11.022    NA    NA    NA    NA    NA
1984   9.613    NA    NA    NA    NA    NA
1985  14.353    NA    NA    NA    NA    NA
1986  12.334    NA    NA    NA    NA    NA
1987  10.386    NA    NA    NA    NA    NA
1988  17.116    NA    NA    NA    NA    NA
1989  18.051 0.002    NA    NA    NA    NA
1990  16.919 0.021    NA    NA    NA    NA
1991  15.611 0.098    NA    NA    NA    NA
1992  23.831 0.079    NA    NA    NA    NA
1993  20.923    NA 0.003    NA    NA    NA
1994  48.229    NA 0.001    NA    NA    NA
1995  96.598    NA    NA    NA    NA    NA
1996 119.191 0.024 0.006    NA    NA    NA
1997 153.354 0.020 0.027    NA    NA    NA
1998 203.449 0.122 0.009    NA    NA    NA
1999 151.647 0.012    NA    NA    NA    NA
2000 147.423 0.198 0.138 0.090    NA    NA
2001 118.489 0.048 0.151 0.313    NA    NA
2002  95.895 0.035 0.095 0.213 0.205    NA
2003  66.340 0.307 0.116    NA    NA    NA
2004  76.444 0.053 0.150 0.717    NA    NA
2005  59.228 0.037 0.125 0.602    NA    NA
2006  50.245 0.051 0.088    NA    NA    NA
2007  47.314 0.013 0.067    NA    NA    NA
2008  47.907 0.010 0.035 0.353    NA    NA
2009  48.128 0.032 0.098    NA    NA    NA
2010  44.869 1.449 0.076    NA 0.002 0.004
2011  59.637 1.918 0.180    NA    NA    NA
2012  57.996 1.373 0.082    NA    NA 0.002
2013  47.268 1.616 0.055    NA    NA    NA
2014  46.045 0.748 0.051    NA    NA    NA
2015  50.024 1.219 0.097    NA    NA    NA
2016  44.627 1.917 0.042    NA    NA    NA
2017  51.847 0.002 0.036    NA    NA    NA
2018  50.193    NA 0.038 0.001    NA    NA
2019   2.092    NA    NA    NA    NA    NA





