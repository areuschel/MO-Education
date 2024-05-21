#### The Dataset
'''
I am working primarily off of the 2023 Supporting Building Report data from
the Missouri Ed Data Portal: https://apps.dese.mo.gov/MCDS/home.aspx
- adding cols from:
  * free and reduced lunch, 2023
* per pupil expenditures, 2023
'''

#Load Packages

library(tidyverse)
library(factoextra)
library(broom)
library(janitor)
library(MVN)
library(ggcorrplot)


#### Data Cleaning

# load datasets

# performance metrics
building <- read.csv("/your_path_here")
# building costs and total enrollment 
pupil <- read.csv("/your_path_here")
# % of students on Free and Reduced lunches
lunch <- read.csv("/your_path_here")

# keep only necessary columns's from building
building <- building %>% select(COUNTY_DISTRICT_CODE, DISTRICT_NAME, SCHOOL_CODE,
                                SCHOOL_NAME, BEG_GRADE, END_GRADE, ELA_ALL_STATUS_MPI,
                                MATH_ALL_STATUS_MPI, SCIENCE_ALL_STATUS_MPI,
                                SOC_STUD_ALL_STATUS_MPI, ELA_SG_STATUS_MPI, MATH_SG_STATUS_MPI,
                                SCIENCE_SG_STATUS_MPI, SOC_STUD_SG_STATUS_MPI,
                                ELA_ALL_GROWTH_POINTS_EARNED_PCT, MATH_ALL_GROWTH_POINTS_EARNED_PCT,
                                SCIENCE_ALL_GROWTH_POINTS_EARNED_PCT,
                                SOC_STUD_ALL_GROWTH_POINTS_EARNED_PCT, ELA_SG_GROWTH_POINTS_EARNED_PCT,
                                MATH_SG_GROWTH_POINTS_EARNED_PCT, SCIENCE_SG_GROWTH_POINTS_EARNED_PCT,
                                SOC_STUD_SG_GROWTH_POINTS_EARNED_PCT, ATTENDANCE_POINTS_EARNED_PCT,
                                GRADUATION_POINTS_EARNED_PCT, ELA_ALL_STATUS_ACCOUNTABLE,
                                MATH_ALL_STATUS_ACCOUNTABLE, SCIENCE_ALL_STATUS_ACCOUNTABLE,
                                SOC_STUD_ALL_STATUS_ACCOUNTABLE, PERFORMANCE_POINTS_EARNED_PCT,
                                CONTINUOUS_IMPROVEMENT_POINTS_EARNED_PCT, TOTAL_POINTS_EARNED_PCT
                                
)
#head(building)

# keep only necessary columns from pupil
pupil <- pupil %>% select(SCHOOL_NAME, DISTRICT_NAME,
                          Total.September.Membership, Total.Building)

# keep only necessary columns from lunch df
# delete rows 1-8... unnecessary text
lunch <- lunch %>% slice(9:n())

# rename columns
col_names <- lunch[1,]
lunch <- lunch[-1,] # deletes row 1 after copying col_names
lunch <- setNames(lunch, col_names)

fr_lunch <- lunch %>% select(`Building Name`, `District Name`, 
                             `2023 F&RL Percentage`)
#head(fr_lunch)
fr_lunch <- rename(fr_lunch, "SCHOOL_NAME" = "Building Name")
fr_lunch <- rename(fr_lunch, "DISTRICT_NAME" = "District Name")


# combining building, pupil, fr_lunch
merge_bp <- merge(building, pupil, by = c("SCHOOL_NAME", "DISTRICT_NAME"), all.x = FALSE) 
# false to aid in cleaning

mo_edu <- merge(merge_bp, fr_lunch, by = c("SCHOOL_NAME", "DISTRICT_NAME"), all.x = FALSE)
#head(mo_edu)



# get only high schools with same 4-yr length
mo_hs <- mo_edu %>% filter(
  BEG_GRADE == 9 & END_GRADE == 12
)
#head(mo_hs)

'''
Notes:
  - some schools with 100% free/reduced lunch
https://dese.mo.gov/financial-admin-services/food-nutrition-services/community-eligibility-provisiocep
- this means that 100% qualify... some schools qualify for 100% if certain portion are direct certified
'''

# count null values for each col and report
nulls <- sapply(mo_hs, function(x) sum(x == "NULL"))
null_df <- data.frame(col_names = names(nulls), null_count = nulls)
null_df

# count null values for each row and report... maybe a school is too small or didn't report.. etc
row_nulls <- rowSums(mo_hs == "NULL" | mo_hs == "*")
threshold <- 1
prob_rows <- which(row_nulls >= threshold)
#prob_rows # 197 rows have at least one null

# changing threshold.. looking for schools that have many missing values
threshold2 <- 4
prob2_rows <- which(row_nulls >= threshold2) # brought this down to 42

# looking closer at these schools
prob_df <- mo_hs[prob2_rows, ]
prob_df

'''
Columns with null values (ASC)
- math all growth pct... 3
- ELA all growth pct  .. 5
- science all growth ... 22
- soc all growth pct ... 103 this is 1/3 .... remove this column

- ELA sg growth pct .... 30
- Math sg growth pct ... 40
- science sg growth .... 62
- soc sg growth pct .... 188 this is more than half... remove this column
'''


# changing threshold.. looking for schools that have many missing values
threshold3 <- 8
prob3_rows <- which(row_nulls >= threshold3) # now only 7

# looking closer at these schools
prob_df2 <- mo_hs[prob3_rows, ]
#prob_df2

'''
Individual rows to be removed:
  
  1.
District : SPECL. SCH. DST. ST. LOUIS CO
- special education schools, so dont report same things
NORTHVIEW
SOUTHVIEW HIGH
HIRAM NEUWOEHNER

2.
TUSCUMBIA HIGH - low enrollment.. small (less than 100)
LOCKWOOD HIGH - 
HIGBEE HIGH - 
CABOOL HIGH - low enrollment ... small (less than 200)
'''


# remove cols/rows identified as huge problem
# removed social studies (sg and all) growth points earned pct
mo_hs2 <- mo_hs %>% select(COUNTY_DISTRICT_CODE, DISTRICT_NAME, SCHOOL_CODE,
                                SCHOOL_NAME, BEG_GRADE, END_GRADE, ELA_ALL_STATUS_MPI,
                                MATH_ALL_STATUS_MPI, SCIENCE_ALL_STATUS_MPI,
                                SOC_STUD_ALL_STATUS_MPI, ELA_SG_STATUS_MPI, MATH_SG_STATUS_MPI,
                                SCIENCE_SG_STATUS_MPI, SOC_STUD_SG_STATUS_MPI,
                                ELA_ALL_GROWTH_POINTS_EARNED_PCT, MATH_ALL_GROWTH_POINTS_EARNED_PCT,
                                SCIENCE_ALL_GROWTH_POINTS_EARNED_PCT,
                                ELA_SG_GROWTH_POINTS_EARNED_PCT,
                                MATH_SG_GROWTH_POINTS_EARNED_PCT, SCIENCE_SG_GROWTH_POINTS_EARNED_PCT,
                                ATTENDANCE_POINTS_EARNED_PCT,
                                GRADUATION_POINTS_EARNED_PCT, ELA_ALL_STATUS_ACCOUNTABLE,
                                MATH_ALL_STATUS_ACCOUNTABLE, SCIENCE_ALL_STATUS_ACCOUNTABLE,
                                SOC_STUD_ALL_STATUS_ACCOUNTABLE, PERFORMANCE_POINTS_EARNED_PCT,
                                CONTINUOUS_IMPROVEMENT_POINTS_EARNED_PCT, TOTAL_POINTS_EARNED_PCT, Total.Building, Total.September.Membership, `2023 F&RL Percentage`
  ) 

# removed 7 schools with 8 or more "NULL" values... named prob3_rows
mo_hs2 <- mo_hs2[-prob3_rows, ]
#mo_hs2




# Checking status of null values after the removal of bad col's and row's 
nulls2 <- sapply(mo_hs2, function(x) sum(x == "NULL"))
null_df2 <- data.frame(col_names = names(nulls2), null_count = nulls2)
null_df2

'''
Notes:
- only 2 nulls in ELA_ALL_GROWTH_POINTS_EARNED_PCT... otherwise all other subjects are good
  - search for these two schools... remove?
  METRO HIGH
  Hawthorn High School

  
Columns with null values (ASC)
- math all growth pct... 0
- ELA all growth pct  .. 2 
- science all growth ... 18

- ELA sg growth pct .... 24
- Math sg growth pct ... 33
- science sg growth .... 55



Caveats
------------------------------------------------------------------------------------------------------------
- social studies/history reporting is all around spotty... these subjects will not be accounted for in the same capacity as math, science, and ELA
- this is due to government every other year, and other adjustments based on school capacity
- some smaller high schools will not be fully accounted for because they dont have high enough enrollment for some reporting standards... skews data towards schools with more enrollment... not a huge issue bc there are still plenty small schools that meet state criterion

'''

#### Two Datasets: No SG growth or smaller sample size

'''
1. DELETE SG Growth PCT COls
PROS: keeps sample size high 
CONS: reduce dimensionality by 3 , excludes interesting point of analysis
'''

# Dataset deleting growth pct sg cols
school_opt1 <- mo_hs2 %>% select(COUNTY_DISTRICT_CODE, DISTRICT_NAME, SCHOOL_CODE,
                                 SCHOOL_NAME, BEG_GRADE, END_GRADE, ELA_ALL_STATUS_MPI,
                                 MATH_ALL_STATUS_MPI, SCIENCE_ALL_STATUS_MPI,
                                 SOC_STUD_ALL_STATUS_MPI, ELA_SG_STATUS_MPI, MATH_SG_STATUS_MPI,
                                 SCIENCE_SG_STATUS_MPI, SOC_STUD_SG_STATUS_MPI,
                                 ELA_ALL_GROWTH_POINTS_EARNED_PCT, MATH_ALL_GROWTH_POINTS_EARNED_PCT,
                                 SCIENCE_ALL_GROWTH_POINTS_EARNED_PCT,
                                 ATTENDANCE_POINTS_EARNED_PCT,
                                 GRADUATION_POINTS_EARNED_PCT, ELA_ALL_STATUS_ACCOUNTABLE,
                                 MATH_ALL_STATUS_ACCOUNTABLE, SCIENCE_ALL_STATUS_ACCOUNTABLE,
                                 SOC_STUD_ALL_STATUS_ACCOUNTABLE, PERFORMANCE_POINTS_EARNED_PCT,
                                 CONTINUOUS_IMPROVEMENT_POINTS_EARNED_PCT, TOTAL_POINTS_EARNED_PCT,
                                 Total.Building, Total.September.Membership, `2023 F&RL Percentage`
)
# remove last of na's
clean_opt1 <- school_opt1[!apply(school_opt1, 1, function(row) any(grepl("NULL|\\*", row))), ]
# this removed 30 schools and 3 columns

'''
DF: 277 schools by 29 variables



2. DELETE REMAINING ROWS WITH NULL VALUES
PROS: keeps dimensionality high, able to interpret growth for student groups
CONS: reduces sample size
'''


# Dataset deleting schools with null values
clean_opt2 <- mo_hs2[!apply(mo_hs2, 1, function(row) any(grepl("NULL|\\*", row))), ]
# this removed about 60 schools and no columns
'''
DF: 239 schools by 32 variables


My choice: 
  I am going to use the second dataset that includes student group growth pct. I would rather keep the student group columns and sacrifice some of our sample size because I think this is a really important piece of information for schools to look at. Schools often look toward programs where esl, low-income, and minority students perform well. I still have n = 239 high schools with 32 total columns in my df. The high number of dimensions is suitable for PCA techniques.
'''

#### MANOVA Analysis


# renaming data to use for the rest of the project
missouri <- clean_opt2

# chr to num
missouri$ELA_ALL_STATUS_MPI <- as.numeric(missouri$ELA_ALL_STATUS_MPI) # all mpi
missouri$MATH_ALL_STATUS_MPI <- as.numeric(missouri$MATH_ALL_STATUS_MPI)
missouri$SCIENCE_ALL_STATUS_MPI <- as.numeric(missouri$SCIENCE_ALL_STATUS_MPI)
missouri$SOC_STUD_ALL_STATUS_MPI <- as.numeric(missouri$SOC_STUD_ALL_STATUS_MPI)

missouri$ELA_SG_STATUS_MPI <- as.numeric(missouri$ELA_SG_STATUS_MPI) # sg mpi
missouri$MATH_SG_STATUS_MPI <- as.numeric(missouri$MATH_SG_STATUS_MPI)
missouri$SCIENCE_SG_STATUS_MPI <- as.numeric(missouri$SCIENCE_SG_STATUS_MPI)
missouri$SOC_STUD_SG_STATUS_MPI <- as.numeric(missouri$SOC_STUD_SG_STATUS_MPI)
# GROWTH PCT ALL
missouri$ELA_ALL_GROWTH_POINTS_EARNED_PCT <- as.numeric(missouri$ELA_ALL_GROWTH_POINTS_EARNED_PCT) 
missouri$MATH_ALL_GROWTH_POINTS_EARNED_PCT <- as.numeric(missouri$MATH_ALL_GROWTH_POINTS_EARNED_PCT)
missouri$SCIENCE_ALL_GROWTH_POINTS_EARNED_PCT <- as.numeric(missouri$SCIENCE_ALL_GROWTH_POINTS_EARNED_PCT)
# growth pct sg
missouri$ELA_SG_GROWTH_POINTS_EARNED_PCT <- as.numeric(missouri$ELA_SG_GROWTH_POINTS_EARNED_PCT)
missouri$SCIENCE_SG_GROWTH_POINTS_EARNED_PCT <- as.numeric(missouri$SCIENCE_SG_GROWTH_POINTS_EARNED_PCT)
missouri$MATH_SG_GROWTH_POINTS_EARNED_PCT <- as.numeric(missouri$MATH_SG_GROWTH_POINTS_EARNED_PCT)
# other
missouri$ATTENDANCE_POINTS_EARNED_PCT <- as.numeric(missouri$ATTENDANCE_POINTS_EARNED_PCT)
missouri$GRADUATION_POINTS_EARNED_PCT <- as.numeric(missouri$GRADUATION_POINTS_EARNED_PCT)
missouri$ELA_ALL_STATUS_ACCOUNTABLE <- as.numeric(missouri$ELA_ALL_STATUS_ACCOUNTABLE)
missouri$MATH_ALL_STATUS_ACCOUNTABLE <- as.numeric(missouri$MATH_ALL_STATUS_ACCOUNTABLE)
missouri$SCIENCE_ALL_STATUS_ACCOUNTABLE <- as.numeric(missouri$SCIENCE_ALL_STATUS_ACCOUNTABLE)
missouri$SOC_STUD_ALL_STATUS_ACCOUNTABLE <- as.numeric(missouri$SOC_STUD_ALL_STATUS_ACCOUNTABLE)
missouri$PERFORMANCE_POINTS_EARNED_PCT <- as.numeric(missouri$PERFORMANCE_POINTS_EARNED_PCT)
missouri$CONTINUOUS_IMPROVEMENT_POINTS_EARNED_PCT <- as.numeric(missouri$CONTINUOUS_IMPROVEMENT_POINTS_EARNED_PCT)
missouri$TOTAL_POINTS_EARNED_PCT <- as.numeric(missouri$TOTAL_POINTS_EARNED_PCT)

# dollar... weird one... using regex  to strip non-digit characters
missouri$Total.Building <- as.numeric(gsub("[^0-9.]", "", missouri$Total.Building))
missouri$`2023 F&RL Percentage` <- as.numeric(gsub("[^0-9.]", "", missouri$`2023 F&RL Percentage`))
missouri$Total.September.Membership <- as.numeric(gsub("[^0-9.]", "", missouri$Total.September.Membership))




# checking correlation
cor_matrix <- cor(missouri[, c("ELA_ALL_STATUS_MPI", "MATH_ALL_STATUS_MPI", "SCIENCE_ALL_STATUS_MPI",
                               "SOC_STUD_ALL_STATUS_MPI", "ELA_SG_STATUS_MPI", "MATH_SG_STATUS_MPI", 
                               "SCIENCE_SG_STATUS_MPI", "SOC_STUD_SG_STATUS_MPI", "ELA_ALL_GROWTH_POINTS_EARNED_PCT",
                               "MATH_ALL_GROWTH_POINTS_EARNED_PCT", "SCIENCE_ALL_GROWTH_POINTS_EARNED_PCT", "ELA_SG_GROWTH_POINTS_EARNED_PCT",
                               "MATH_SG_GROWTH_POINTS_EARNED_PCT", "SCIENCE_SG_GROWTH_POINTS_EARNED_PCT", "ATTENDANCE_POINTS_EARNED_PCT",
                               "GRADUATION_POINTS_EARNED_PCT",
                               "ELA_ALL_STATUS_ACCOUNTABLE",
                               "MATH_ALL_STATUS_ACCOUNTABLE",
                               "SCIENCE_ALL_STATUS_ACCOUNTABLE",
                               "SOC_STUD_ALL_STATUS_ACCOUNTABLE",
                               "PERFORMANCE_POINTS_EARNED_PCT",
                               "CONTINUOUS_IMPROVEMENT_POINTS_EARNED_PCT",
                               "TOTAL_POINTS_EARNED_PCT",
                               "Total.Building",
                               "Total.September.Membership",
                               "2023 F&RL Percentage")])

# heatmap to visualize correlation
ggcorrplot::ggcorrplot(cor_matrix)



#### ASSUMPTION--- INDEPENDENCE BETWEEN OBSERVATIONS
'''
- this is met: high schools are all separate, no districts are the same, etc.
'''


#### ASSUMPTION--- MVN


clean <- missouri %>%
  select(ELA_ALL_STATUS_MPI,
         MATH_ALL_STATUS_MPI,
         SCIENCE_ALL_STATUS_MPI,
         SOC_STUD_ALL_STATUS_MPI,
         ELA_ALL_GROWTH_POINTS_EARNED_PCT,
         MATH_ALL_GROWTH_POINTS_EARNED_PCT,
         SCIENCE_ALL_GROWTH_POINTS_EARNED_PCT,
         MATH_SG_GROWTH_POINTS_EARNED_PCT,
         ELA_SG_GROWTH_POINTS_EARNED_PCT,
         SCIENCE_SG_GROWTH_POINTS_EARNED_PCT,
         ELA_SG_STATUS_MPI,
         MATH_SG_STATUS_MPI,
         SCIENCE_SG_STATUS_MPI,
         SOC_STUD_SG_STATUS_MPI,
         ATTENDANCE_POINTS_EARNED_PCT,
         GRADUATION_POINTS_EARNED_PCT,
         PERFORMANCE_POINTS_EARNED_PCT,
         Total.Building,
         Total.September.Membership,
         `2023 F&RL Percentage`) %>%
  clean_names() %>%
  rename(frl_percentage = x2023_f_rl_percentage) %>%
  rename(total_membership = total_september_membership) %>%
  rename(cost_building = total_building) 
# %>%
#mutate(cost_building = log(cost_building))
#%>%
#mutate(total_membership = log(total_membership))



normality_test <- mvn(data = clean, mvnTest = "royston")
normality_test$multivariateNormality
# normality assumption violated



mvn(data = clean, multivariatePlot = "qq")
# qq plot shows clear deviance abline

'''
Checking normality of variables... transforming??
  
  ela_all_status_mpi- transforming did not fix (log, sqrt)
math_all_status_mpi- transforming did not fix (")
science_all_status_mpi- transforming did not fix (")
total_membership- log transformation seemed to make this assumption better...
but the test for mvn still says this is violated
cost_building- log transformation seemed to make this assumption better...
but the test for mvn still says this is violated
'''


qqnorm(clean$total_membership)
qqline(clean$total_membership)

qqnorm(log(clean$total_membership)) # no significant improvement
qqline(log(clean$total_membership)) 



# qqnorm(clean$cost_building)
# qqline(clean$cost_building)
# 
# qqnorm(log(clean$cost_building))
# qqline(log(clean$cost_building))

'''
Normally distributed variables:
  - soc_stud_all_status_mpi
- ela_sg_status_mpi
- math_sg_status_mpi
- science_sg_status_mpi
- soc_stud_sg_status_mpi
'''

# create subset of univariate normal vars
mvn_test <- subset(clean, select = c("soc_stud_all_status_mpi","ela_sg_status_mpi",
                                     "math_sg_status_mpi", "science_sg_status_mpi",
                                     "soc_stud_sg_status_mpi"))

# testing mvn of select performance variables
normality_test_2 <- mvn(data = mvn_test, mvnTest = "royston")
normality_test_2$multivariateNormality

# still not MVN... other combinations of variables still could be, but just because they are univariate
# normal does not guarantee MVN


#### ASSUMPTION--- ABSENCE OF MULTICOLLINEARITY
'''
Avoid the error "residuals have rank 25<26":
  - search for collinearity
- removed continuous improvement points.. a linear combo of other vars
- removed "all_status_accountable" variables bc r > 0.90... keep total membership
- removed "total_points_earned_pct"... r > 0.90 ... keep performance points


Assumption of MVN not met. Cannot continue with MANOVA.
'''

#### Principle Components Analysis (PCA)

# shorten variable names and make all lowercase
clean2 <- missouri %>%
  select(DISTRICT_NAME,
         ELA_ALL_STATUS_MPI,
         MATH_ALL_STATUS_MPI,
         SCIENCE_ALL_STATUS_MPI,
         SOC_STUD_ALL_STATUS_MPI,
         ELA_ALL_GROWTH_POINTS_EARNED_PCT,
         MATH_ALL_GROWTH_POINTS_EARNED_PCT,
         SCIENCE_ALL_GROWTH_POINTS_EARNED_PCT,
         MATH_SG_GROWTH_POINTS_EARNED_PCT,
         ELA_SG_GROWTH_POINTS_EARNED_PCT,
         SCIENCE_SG_GROWTH_POINTS_EARNED_PCT,
         MATH_ALL_STATUS_ACCOUNTABLE,
         SCIENCE_ALL_STATUS_ACCOUNTABLE,
         ELA_ALL_STATUS_ACCOUNTABLE,
         SOC_STUD_ALL_STATUS_ACCOUNTABLE,
         ELA_SG_STATUS_MPI,
         MATH_SG_STATUS_MPI,
         SCIENCE_SG_STATUS_MPI,
         SOC_STUD_SG_STATUS_MPI,
         ATTENDANCE_POINTS_EARNED_PCT,
         GRADUATION_POINTS_EARNED_PCT,
         PERFORMANCE_POINTS_EARNED_PCT,
         Total.Building,
         Total.September.Membership,
         `2023 F&RL Percentage`) %>%
  clean_names() %>%
  rename(frl_percentage = x2023_f_rl_percentage) %>%
  rename(total_membership = total_september_membership) %>%
  rename(cost_building = total_building) %>%
  rename(attendance = attendance_points_earned_pct) %>%
  rename(grad = graduation_points_earned_pct) %>%
  rename(performance = performance_points_earned_pct) %>%
  rename(ela_all_growth = ela_all_growth_points_earned_pct) %>%
  rename(math_all_growth = math_all_growth_points_earned_pct) %>%
  rename(sci_all_growth = science_all_growth_points_earned_pct) %>%
  rename(math_sg_growth = math_sg_growth_points_earned_pct) %>%
  rename(ela_sg_growth = ela_sg_growth_points_earned_pct) %>%
  rename(sci_sg_growth = science_sg_growth_points_earned_pct) %>%
  rename(ela_count = ela_all_status_accountable) %>%
  rename(math_count = math_all_status_accountable) %>%
  rename(sci_count = science_all_status_accountable) %>%
  rename(soc_stud_count = soc_stud_all_status_accountable)



'''
Assumptions for PCA:
  1. multiple variables, continuous 
MET

2. linear relationships between variables
'''
```{r}
correlation_check <- cor(clean2[, c("ela_all_status_mpi",
                                    "math_all_status_mpi",
                                    "science_all_status_mpi",
                                    "soc_stud_all_status_mpi",
                                    "ela_all_growth",
                                    "math_count",
                                    "ela_count",
                                    "sci_count",
                                    "soc_stud_count",
                                    "math_all_growth",
                                    "sci_all_growth",
                                    "math_sg_growth",
                                    "ela_sg_growth",
                                    "sci_sg_growth",
                                    "ela_sg_status_mpi",
                                    "math_sg_status_mpi",
                                    "science_sg_status_mpi",
                                    "soc_stud_sg_status_mpi",
                                    "attendance",
                                    "grad",
                                    "performance",
                                    "cost_building",
                                    "total_membership",
                                    "frl_percentage")])
```
'''
3. high enough sample size
MET

4. suitable for data reduction
MET

5. no significant outliers
'''

clean3 <- clean2 %>%
  select(-district_name) %>%
  select(-grad) 

#?mvn

outlier_check <- mvn(data = clean3, mvnTest = "hz", multivariateOutlierMethod =
                       "adj")

'''
Potential outliers: 8, 221, 146, 132, 300
- only 5 total and 8 is significantly worse than the other three
- assumption not horribly violated
- maybe run another pca without these observations and see if theres significant difference

Creating DF without 5 identified outliers
'''

# dataframe without outliers
indices_out <- c(8,132,146,221, 300)
mo_no_outliers <- clean3[-indices_out, ]
mo_name <- clean2[-indices_out,]

'''
Checking eigenvalues and vectors
'''

evals <- eigen(correlation_check)
eigenvals <- evals$values
eigenvecs <- evals$vectors
eigenvals # already ordered
#eigenvecs

'''
PCA, whole dataset
'''
# perform PCA
mo_pca <- prcomp(clean3, scale = TRUE) 
mo_pca # loadings
summary(mo_pca) # prop of variance

# look at plot
fviz_screeplot(mo_pca)
# it looks like 4 PC's is optimal

# look at principal components
first_pc <- mo_pca$rotation[,1]
first_pc

second_pc <- mo_pca$rotation[,2]
second_pc

third_pc <- mo_pca$rotation[,3]
third_pc

fourth_pc <- mo_pca$rotation[,4]
fourth_pc


'''
takeaways PC1:
  - most variance described by test scores (both all and sg)

takeaways PC2:
  - enrollment, and counts most important to this PC
- these are all negative

takeaways PC3:
- growth categories most important to this PC
  - all positive
- first time cost variable has had this much influence on a PC... same direction as growth
  
takeaways PC4:   
- mix of pos and neg values
- math and science important
- math growth all negative while science growth all positive
'''

'''

Proportion of Variance explained:
4 PCS = 75.3%
'''


Visualizing first two PCs (PC1 = performance metrics, CPC2 = attendance and enrollment)
               
               # look at variables
               mo_pca$rotation
               
               # too many variables to look at... setting contribution threshold for clarity
               cont_0 <- mo_pca$rotation^2
               threshold <- 0.05 # must have contribution of at least 5%
               
               vars_keep0 <- apply(cont_0[,1:2], 1, function(x) any(x >= threshold))
               filt_0 <- cont_0[vars_keep0, 1:2]
               
               fviz_pca_var(mo_pca,
                            col.var = "contrib", # Color by contributions to the PC
                            gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                            repel = TRUE,
                            select.var = list(name = rownames(filt_0))) # Avoid text
               
               
               
               
               #### PCA, without outliers
               # perform PCA
               mo_pca2 <- prcomp(mo_no_outliers, scale = TRUE) 
               mo_pca2 # loadings
               summary(mo_pca2) # prop of variance

               '''
               Very minimal differences between this one and the full model. Shows that even though these schools are performing in different ways or have different student demographics that the same variables are the most important to explaining variance of MO high schools.
               '''
               # look at plot
               fviz_screeplot(mo_pca2)
               # same 4

               # look at variables
               mo_pca2$rotation
               
               # setting contribution threshold
               cont_1 <- mo_pca2$rotation^2
               # at least 5%
               
               vars_keep1 <- apply(cont_1[,1:2], 1, function(x) any(x >= threshold))
               filt_1 <- cont_1[vars_keep1, 1:2]
               
               fviz_pca_var(mo_pca2,
                            col.var = "contrib", # Color by contributions to the PC
                            gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                            repel = TRUE,
                            select.var = list(names = rownames(filt_1))) # Avoid text
               

               
               ### PCA, subsetting by FRL (income measurement) and enrollment (size and capacity measurement)
               
               
               # splitting data
               mo_high_pct <- mo_frl %>%
                 filter(frl == 0) %>%
                 select(-frl) %>%
                 clean_names() %>%
                 select(-county_district_code) %>%
                 select(-district_name) %>%
                 select(-school_code) %>%
                 select(-school_name) %>%
                 select(c(-beg_grade, -end_grade, -continuous_improvement_points_earned_pct,
                          -graduation_points_earned_pct, -total_points_earned_pct))  
               
               # so i should have been using c() this whole time... you live and learn
               mo_low_pct <- mo_frl %>%
                 filter(frl == 1) %>%
                 clean_names() %>%
                 select(-c(county_district_code, district_name, school_code, school_name,
                           beg_grade, end_grade, continuous_improvement_points_earned_pct,
                           frl, graduation_points_earned_pct, total_points_earned_pct))
               # perform PCA
               mo_pca3 <- prcomp(mo_high_pct, scale = TRUE) 
               #mo_pca3 # loadings
               
               mo_pca4 <- prcomp(mo_low_pct, scale = TRUE)
               #mo_pca4
               
               summary(mo_pca3) # prop of variance
               summary(mo_pca4)

               
               # look at plot
               fviz_screeplot(mo_pca3)
               # 4 PC's... explain 72%
               fviz_screeplot(mo_pca4)
               # 4 PC's... explain 79%
'''
               - this is interesting that more variance can be explained in 4 PCs for higher income schools than for lower income schools
  - financial stress and overall school capacity could explain this
  '''


# principal components
pc1_low_pct <- mo_pca4$rotation[,1]
pc1_low_pct
pc2_low_pct <- mo_pca4$rotation[,2]
pc2_low_pct

pc1_high_pct <- mo_pca3$rotation[,1]
#pc1_high_pct
pc2_high_pct <- mo_pca3$rotation[,2]
#pc2_high_pct

# comparing PC1
pc1_low_pct
pc1_high_pct

'''
Total membership in PC1 for pca3/high_pct: -0.232
- enrollment explains more variance for schools with a lot of students on 
FRL programs... consistent with other observations
- more variance in accountable (attendance) than the wealthy schools

Total membership in PC1 for pca4/low_pct:  -0.059

Test scores account for more variance in for the wealthy subset!
'''

# look at variables... high_pct on FRL
# setting contribution threshold
cont_2 <- mo_pca3$rotation^2
 # at least 5%

vars_keep2 <- apply(cont_2[,1:2], 1, function(x) any(x >= threshold))
filt_2 <- cont_2[vars_keep2, 1:2]

fviz_pca_var(mo_pca3,
             col.var = "contrib", # Color by contributions to the PC
                                 gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                                 repel = TRUE,
             select.var = list(names = rownames(filt_2))) # Avoid text

# setting contribution threshold
cont_3 <- mo_pca4$rotation^2
 # at least 5%

vars_keep3 <- apply(cont_3[,1:2], 1, function(x) any(x >= threshold))
filt_3 <- cont_3[vars_keep3, 1:2]

# low_pct on FRL
fviz_pca_var(mo_pca4,
             col.var = "contrib", 
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE,
             select.var = list(names = rownames(filt_3))
             # Avoid text overlapping
             )
