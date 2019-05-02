 
library(JRWToolBox)
  
# This file can be downloaded to your working directory and viewed in R with: 
 JRWToolBox::gitAFile('John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/Comprehensive_FT column name conversion to old style.R', type = "script", File = 'Comprehensive_FT column name conversion to old style.R')

# See the Prologue in the README for the JRWToolBox package for more information on gitAFile()

 
# Conversion table

# Same column name (so no need to convert): FTID 
# 'RWT_LBS' historically converted to 'CATCH.LBS' in the SQL code, so here 'ROUND_WEIGHT_LBS' is converted to 'CATCH.LBS'
# It appears that 'PRODUCT_FROM' in vdrfd was meant to be 'PRODUCT_FORM'
# vdrfd PRMTLST (One or more NWR/LE permits under which the vessel fished) doesn't appear to have a cooresponding column in the Comprehensive_FT table

nameConvertVdrfdToCompFT <- JRWToolBox::scanIn("

                      Comp_FT                               vdrfd
                   AGENCY_CODE                              AGID
                   LANDING_YEAR                             YEAR
                   LANDING_DATE                             TDATE
                   PACFIN_SPECIES_CODE                      SPID
                   PARTICIPATION_GROUP_CODE                 PARGRP
                   PACFIN_PORT_CODE                         PCID
                   PACFIN_CATCH_AREA_CODE                   ARID
                   PORT_CODE                                PORT
                   FLEET_CODE                               FLEET
                   VESSEL_NUM                               DRVID
                   PACFIN_GEAR_CODE                         GRID
                   IS_IFQ_LANDING                           IFQ_LANDING
                   REMOVAL_TYPE_CODE                        REMOVAL_TYPE
                   CONDITION_CODE                           COND
                   DISPOSITION_CODE                         DISP
                   EXVESSEL_REVENUE                         REV
                   GRADE_CODE                               GRADE                 
                   ROUND_WEIGHT_LBS                         CATCH.LBS
                   LANDED_WEIGHT_LBS                        LWT_LBS
                   ADJUSTED_GEAR_CODE                       ADJ_GRID
                   DAHL_GROUNDFISH_CODE                     DAHL_SECTOR
                   IS_REMOVAL_LEGAL                         LEGAL_REMOVAL
                   IS_OVERAGE                               OVERAGE
                   PRODUCT_FORM_CODE                        PRODUCT_FROM
                   PRODUCT_USE_CODE                         PRODUCT_USE
                   ORIG_PACFIN_CATCH_AREA_CODE              FTL_ARID
                   ORIG_PACFIN_SPECIES_CODE                 FTL_SPID
                   DEALER_NUM                               PROC
                  
")

# Here is the conversion table's use with a Petrale sole catch example:

# COUNCIL_CODE = 'P'; with research catch included
PTRL_Comprehensive_FT <- import.sql(
        "Select COUNCIL_CODE, AGENCY_CODE, INPFC_AREA_TYPE_CODE, LANDING_YEAR, LANDING_DATE, FTID, PARTICIPATION_GROUP_CODE, PACFIN_CATCH_AREA_CODE, PORT_CODE, FLEET_CODE, VESSEL_ID, 
                             PACFIN_GEAR_CODE, IS_IFQ_LANDING, REMOVAL_TYPE_CODE, CONDITION_CODE, DISPOSITION_CODE, EXVESSEL_REVENUE, PACFIN_SPECIES_CODE, NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE, 
                             IS_SPECIES_COMP_USED, GRADE_CODE, GRADE_NAME, PACFIN_GROUP_GEAR_CODE, ROUND_WEIGHT_LBS, LANDED_WEIGHT_MTONS                         
          from pacfin_marts.Comprehensive_FT 
         where PACFIN_SPECIES_CODE = any ('PTRL', 'PTR1') 
           and COUNCIL_CODE = 'P' 
           and AGENCY_CODE in ('W','O','C')", dsn="PacFIN", uid="wallacej", pwd=PacFIN.PW)

PTRL_Comprehensive_FT[1:2,]
# #   COUNCIL_CODE AGENCY_CODE INPFC_AREA_TYPE_CODE LANDING_YEAR LANDING_DATE    FTID PARTICIPATION_GROUP_CODE PACFIN_CATCH_AREA_CODE PORT_CODE FLEET_CODE VESSEL_ID
# # 1            P           C                   EK         1981   1981-11-04 T057232                        C                     1C       201         XX  21217728
# # 2            P           C                   EK         1981   1981-11-08 T057243                        C                     1C       201         XX  21217728
# #   PACFIN_GEAR_CODE IS_IFQ_LANDING REMOVAL_TYPE_CODE CONDITION_CODE DISPOSITION_CODE EXVESSEL_REVENUE PACFIN_SPECIES_CODE NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE
# # 1              GFT          FALSE                 C              R                H            14.75                PTR1                                  PTRL
# # 2              GFT          FALSE                 C              R                H           171.10                PTR1                                  PTRL
# #   IS_SPECIES_COMP_USED GRADE_CODE GRADE_NAME PACFIN_GROUP_GEAR_CODE ROUND_WEIGHT_LBS LANDED_WEIGHT_MTONS
# # 1                FALSE          L      LARGE                    TWL               25          0.01133981
# # 2                FALSE          L      LARGE                    TWL              290          0.13154179

  
# Convert the names using nameConvertVdrfdToCompFT
names(PTRL_Comprehensive_FT) <- JRWToolBox::recode.simple(names(PTRL_Comprehensive_FT), nameConvertVdrfdToCompFT)


PTRL_Comprehensive_FT[1:2,]
# #   COUNCIL_CODE AGID INPFC_AREA_TYPE_CODE YEAR      TDATE    FTID PARGRP ARID PORT FLEET VESSEL_ID GRID IFQ_LANDING REMOVAL_TYPE COND DISP    REV SPID
# # 1            P    C                   EK 1981 1981-11-04 T057232      C   1C  201    XX  21217728  GFT       FALSE            C    R    H  14.75 PTR1
# # 2            P    C                   EK 1981 1981-11-08 T057243      C   1C  201    XX  21217728  GFT       FALSE            C    R    H 171.10 PTR1
# #   NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE IS_SPECIES_COMP_USED GRADE GRADE_NAME PACFIN_GROUP_GEAR_CODE CATCH.LBS LANDED_WEIGHT_MTONS
# # 1                                  PTRL                FALSE     L      LARGE                    TWL        25          0.01133981
# # 2                                  PTRL                FALSE     L      LARGE                    TWL       290          0.13154179
# # 


# FYI, research (R) catch is seen both under FLEET and REMOVAL_TYPE (JRWToolBox::Table shows the NA's)

JRWToolBox::Table(PTRL_Comprehensive_FT$FLEET, PTRL_Comprehensive_FT$AGID)
    
          C      O      W
  LE  47223 150193  20723
  OA   4201   3363    634
  R      44   1393      4
  TI      0      0   3264
  XX  67353  75597  28572
  

JRWToolBox::Table(PTRL_Comprehensive_FT$REMOVAL_TYPE, PTRL_Comprehensive_FT$AGID)
      
            C      O      W
  C    117548 228750  51743
  D         0    156      0
  E         2    247    737
  O         0      0      7
  P      1214      0    706
  R        44   1393      4
  U         4      0      0
  <NA>      9      0      0
  
