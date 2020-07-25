

# In SQL, one cannot match in  COUNCIL from the 'ar' table since the correct way is to bring it in by matching ARID with PSMFC_ARID, 
#              but a lot of WA BDS is missing PSMFC_ARID (empty character string: "") and hence gets dropped.
# Time to move to comprehensive_bds_comm for 2021!

if(F) {

   # Download into R with:
   rgit::gitAFile('John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/BDS Sp Extraction with Grade Info 15 Apr 2019.R', show = FALSE)

   
   # If you have copied and updated gitEdit() with your favorite editor, then download and insert this entire script (comments plus function) into your editor with:
   rgit::gitEdit('BDS Sp Extraction with Grade Info 15 Apr 2019.R', 'John-R-Wallace-NOAA/PacFIN-Data-Extraction/master/')

      
   UID <- "wallacej"
   PWD <- PacFIN.PW
   
   # Test PacFIN connection
   JRWToolBox::import.sql("Select * from pacfin.bds_sp where rownum < 11", File=F, dsn="PacFIN", uid=UID, pwd=PWD)
   
   
   # ******************* Using the new SQL code with 'ANY' changes the calls used: ******************
   PacFIN.WDOW.bds.05.Jun.2015 <- bds.sp.extraction("'WDOW'")
   PacFIN.WDOW.bds.05.Jun.2015 <- bds.sp.extraction("('WDOW', 'WDW1')")  # No nominal species in BDS that I have seen
	
   save(PacFIN.WDOW.bds.05.Jun.2015, file = 'PacFIN.WDOW.bds.05.Jun.2015.RData')
}


# =================================================

bds.sp.extraction <- function(SPID = "'PTRL'", write.to.file = F, file.out = paste("bds_", SPID, ".csv", sep=""), 
	minYr = 1900, maxYr = 2100, stringsAsCharacter = TRUE, dsn="PacFIN") {
  
  # This extraction uses the RODBC package via JRWToolBox::import.sql()
  # Example using SQL without an external file:
  #    import.sql("Select * from pacfin.bds_sp where rownum < 11", dsn="PacFIN", uid=UID, pwd=PWD)  
    
  ask <- function (msg = "Press <RETURN> to continue: ") 
  {
      cat(msg)
      flush.console()
      readLines(con = stdin(), n = 1)
  }

  require(JRWToolBox)
# ------------------------------------------------------

 # Ask for User ID and password

  if(!exists('UID'))
     UID <- ask("User ID: ")
 
  if(!exists('PWD')) {
     PWD <- ask("Password: ")
     catf("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
  }  

 # Get data from the bds_age table

   BDS_Age.sql <- 
    "select a.spid, a.sample_year, a.source_agid, a.sample_no, a.cluster_no, a.fish_no, 
            age_struct_agcode, age_method, TO_NUMBER(age_no) as agenum, age_years,
            age_readability, aged_by, date_aged, data_type, depth_avg, depth_min, depth_max, 
            inpfc_area, psmfc_area, psmfc_arid, sample_agid, drvid, gear, grid, 
            sample_month, sample_day, sample_method, sample_type, pcid, port, ftid
       from pacfin.bds_age a, pacfin.bds_sample s
      where spid = any &sp
        and s.sample_no = a.sample_no(+)
        and s.sample_year = a.sample_year(+) 
        and s.sample_year between &beginyr and &endyr
      order by sample_year, source_agid, sample_no, cluster_no, fish_no, age_no"

    catf("\nGet bds_age:", date(), "\n\n")
   
    age_temp <- import.sql(BDS_Age.sql, c("&sp", "&beginyr", "&endyr"), c(SPID, minYr, maxYr), uid = UID, pwd = PWD, dsn = dsn, View.Parsed.Only = FALSE)
 
     if(nrow(age_temp) > 0)  {

       printf(age_temp[1:3, ])
       catf("\n\nMake sure there are no more than 3 agers.\n")
       printf(Table(age_temp$AGENUM))
       if(length(Table(age_temp$AGENUM)) > 3)
           stop("More than three agers!")
       catf("\nGot bds_age at", date(), "\n\n")
      
       # Line up any multiple ages into columns so that one line = one fish

    
       # Sort age_temp including with AGENUM to insure that AGED_BY and DATE_AGED are associated with the first age (age1).
       age_temp <- age_temp[do.call(order, age_temp[,c("SAMPLE_YEAR", "SOURCE_AGID", "SAMPLE_NO", "CLUSTER_NO", "FISH_NO", "AGENUM")]), ]
  
       age_temp$KEY <- paste(age_temp$SAMPLE_YEAR, age_temp$SOURCE_AGID, age_temp$SAMPLE_NO, age_temp$CLUSTER_NO, age_temp$FISH_NO)

       bds_age <- age_temp[!duplicated(age_temp$KEY), ]
       bds_age$AGE_YEARS <- NULL

       age_temp$AGE_YEARS[is.na(age_temp$AGE_YEARS) & !is.na(age_temp$AGENUM)] <- -99

       for(i in unique(age_temp$AGENUM)) {
            bds_age <- match.f(bds_age, age_temp[age_temp$AGENUM %in% i,],  "KEY", "KEY", "AGE_YEARS")
            dimnames(bds_age)[[2]][ncol(bds_age)] <- paste("age", i, sep="")
       }

       if(is.null(bds_age$age2)) bds_age$age2 <- NA
       if(is.null(bds_age$age3)) bds_age$age3 <- NA

       bds_age$age1[is.na(bds_age$age1)] <- 0
       bds_age$age2[is.na(bds_age$age2)] <- 0
       bds_age$age3[is.na(bds_age$age3)] <- 0

       bds_age$age1[bds_age$age1 %in% -99] <- 0
       bds_age$age2[bds_age$age2 %in% -99] <- NA
       bds_age$age2[bds_age$age2 %in% -99] <- NA
 } else 
       catf("\n******* No ages found. *******\n\n")


 # Get data from the bds_fish table; info on the sampled fish

 # ftl.2008 <- import.sql("Select * from ftl where year = 2008 and rownum < 1001", dsn="PacFIN", uid = UID, pwd=PWD)


 # ************ pacfin.bds_sample_odfw's unk.wt is called unk.wgt in PacFIN's metadata on the internet! ***********
   BDS_Fish.sql <- 
    "select f.spid, f.sample_no, f.sample_year, f.source_agid, s.sample_agency, f.cluster_no, f.fish_age_years_final, f.fish_age_code_final,
            f.fish_no, f.freq, f.fish_length, f.fish_length_type, f.fork_length_estimated, 
            f.fork_length, f.maturity, f.maturity_agcode,f.fish_weight, f.sex,
            data_type, depth_avg, depth_min, depth_max, s.drvid, s.gear, s.grid, s.market_category, s.grade, s.grade_agcode,
            inpfc_area, psmfc_area, psmfc_arid, sample_agid,
            sample_month, sample_day, sample_method, sample_type, males_wgt, 
            males_num, females_num, females_wgt, o.unk_num, o.unk_wt, o.sample_quality, total_wgt, rwt_lbs, lwt_lbs, o.exp_wt, s.pcid, s.port, s.ftid, s.cond, s.cond_agcode, s.grade, s.grade_agcode, s.wgtmax, s.wgtmin
      from (select v.ftid, v.agid, sum(v.rwt_lbs) as rwt_lbs, sum(v.lwt_lbs) as lwt_lbs
            from pacfin.vdrfd v 
            where v.spid = any &sp
            group by v.ftid, v.agid) v2, pacfin.bds_fish f, pacfin.bds_sample s, pacfin.bds_sample_odfw o
      where f.spid = any &sp
        and s.sample_no = f.sample_no(+)
        and s.sample_no = o.sample_no(+)
        and s.sample_year = f.sample_year(+)
        and s.sample_year between &beginyr and &endyr
        and s.sample_year = o.sample_year(+)
        and s.ftid = v2.ftid(+)
        and s.sample_agid = v2.agid(+)
      order by sample_year, source_agid, sample_no, fish_no, cluster_no"
 

    catf("\nGet bds_fish:", date(), "\n\n")
    
    bds_fish <- import.sql(BDS_Fish.sql, c("&sp", "&beginyr", "&endyr"), c(SPID, minYr, maxYr), uid = UID, pwd = PWD, dsn = dsn)

    printf(ifelse(is.data.frame(bds_fish), bds_fish[1:3,], bds_fish))

    catf("\nGot bds_fish:\n\n")
    
  
    bds_fish$KEY <- paste(bds_fish$SAMPLE_YEAR, bds_fish$SOURCE_AGID, bds_fish$SAMPLE_NO, bds_fish$CLUSTER_NO, bds_fish$FISH_NO)

    
 # If there are ages, combine BDS_FISH and BDS_AGE

    if(nrow(age_temp) > 0)  {

     bds_fish <- match.f(bds_fish, bds_age, "KEY", "KEY", c("AGE_STRUCT_AGCODE", "AGE_METHOD", "AGE_READABILITY", "AGED_BY",
	 "DATE_AGED", dimnames(bds_age)[[2]][grep("age", dimnames(bds_age)[[2]])]))
   }
  
 # BDS_CLUSTER for this particular sp

    catf("\nGet bds_cluster for", SPID, ":", date(), "\n\n")
    
  BDS_Cluster_Sp.sql <- 
    "select spid, sample_year, source_agid, sample_no, cluster_no, species_wgt,
            cluster_wgt, frame_clwt, adj_clwt 
       from pacfin.bds_cluster
      where spid = any &sp
        and sample_year between &beginyr and &endyr"


    bds_clust_sp <- import.sql(BDS_Cluster_Sp.sql, c("&sp", "&beginyr", "&endyr"), c(SPID, minYr, maxYr), uid = UID, pwd = PWD, dsn = dsn)

    printf(bds_clust_sp[1:3, ])
    catf("\nGot bds_cluster for", SPID, ":\n\n")
    
 # Take out dups
    bds_clust_sp <- bds_clust_sp[!duplicated(paste(bds_clust_sp$SAMPLE_NO, bds_clust_sp$CLUSTER_NO)),]


 # BDS_CLUSTER for all sp

    #  ** The code below selects all clusters in a sample (regardless of species) and then sums the cluster weight. **
    #  ** This is necessary only when there is a chance of clusters that did not contain the target species.        **
    #  ** The problem only seems to occur in CA where the total weight of all clusters is not reported.             **


  BDS_Cluster_All.sql <- 
    "select sample_no, cluster_wgt, cluster_no 
       from pacfin.bds_cluster
      where sample_year between &beginyr and &endyr"


    catf("\nGet bds_cluster for all species:", date(), "\n\n")
     

    bds_clust_all <- import.sql(BDS_Cluster_All.sql, c("&beginyr", "&endyr"), c(minYr, maxYr), uid = UID, pwd = PWD, dsn = dsn)
   
    printf(bds_clust_all[1:3, ])
    catf("\nGot bds_cluster for all species:\n\n")
    
  # Take out dups
    bds_clust_all <- bds_clust_all[!duplicated(paste(bds_clust_all$SAMPLE_NO, bds_clust_all$CLUSTER_NO)),]

    bds_clust_all.agg <- aggregate(list(all_cluster_sum = bds_clust_all$CLUSTER_WGT), list(SAMPLE_NO = bds_clust_all$SAMPLE_NO), sum)
    bds_clust_sp <- match.f(bds_clust_sp, bds_clust_all.agg, "SAMPLE_NO", "SAMPLE_NO", "all_cluster_sum")

    
 # Combine BDS_CLUSTER with BDS_FISH (which already has BDS_AGE, with perhaps all NA's)

    bds_fish <- match.f(bds_fish, bds_clust_sp, c("SAMPLE_NO", "CLUSTER_NO", "SAMPLE_YEAR", "SOURCE_AGID"), c("SAMPLE_NO",
	 "CLUSTER_NO", "SAMPLE_YEAR", "SOURCE_AGID"), c("all_cluster_sum", "SPECIES_WGT", "CLUSTER_WGT", "FRAME_CLWT", "ADJ_CLWT"))


 # Duplicate all the records with frequency > 1 from Oregon

    bds_fish <- bds_fish[rep(1:nrow(bds_fish), bds_fish$FREQ),]
 
 # Cleanup
   
    bds_fish$KEY <- NULL
    bds_fish$i <- NA
    
    if(stringsAsCharacter) 
         bds_fish <- data.frame(lapply(bds_fish, function(x) if(is.factor(x)) as.character(x) else x), stringsAsFactors = FALSE)

    bds_fish <- data.frame(lapply(bds_fish, function(x) if(is.character(x)) {x[is.na(x)] <- ""; x}  else x), 
	 stringsAsFactors = !stringsAsCharacter)

 # Return result

  if(write.to.file) {

         write.csv(bds_fish, file = file.out, row.names = FALSE)
         invisible(bds_fish)

   } else 

    bds_fish

}




