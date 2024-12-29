# MO-Education
![missouri](/Photos/mo_nature.jpg?raw=true "Clean")

Multivariate analysis of Missouri High Schools using Principal Components Analysis

<h2>Description</h2>
This project uses multivariate statistics to identify key differences in educational performance across high schools in Missouri, analyzing factors like reported student growth, socioeconomic data at the school and district levels, and several other school population demographics.


<h2>Languages and Utilities Used</h2>

- <b>RStudio</b> 
- <b>tidyverse</b>
- <b>Hmisc</b>
- <b>ClustOfVar</b>
- <b>nsprcomp</b>
- <b>janitor</b>

<h2>Project walk-through:</h2>

### Gathering the Data
The data for this project was obtained through the Missouri Department of Education’s online Comprehensive Data System (MCDS). Three different datasets were combined to increase the number of variables and scope of analysis. I am working primarily off of the 2023 Supporting Building Report data from MCDS (link: https://apps.dese.mo.gov/MCDS/home.aspx) and adding columns from Free and Reduced Lunch Percentage (2023) and Per Pupil Expenditures (2023).


### Preprocessing 
1. Narrow focus of analysis to only 4-year high schools
2. Inspect count of null values & variable name
   
![Cleaning1](/Plots/preprocess_01.jpg?raw=true "Clean")

  
✂️ I decided to remove individual schools with 8 or more total null values.

✂️ I also removed social studies categories due to more than 50% of the data being missing for all testing groups. 

#### A new look at the remaining null values
     
![Nulls](/Plots/preprocess_02.jpg?raw=true "Nulls")



### Other considerations

📕 Several schools report 100% of students qualify for Free and Reduced Lunch

  - schools can qualify 100% if a high enough proportion of students are direct certified
  - link to eligibility guidelines: https://dese.mo.gov/financial-admin-services/food-nutrition-services/community-eligibility-provisiocep
    
📙 Special education schools were not considered in this analysis for large proportion of null values in selected variables 

📒 Low-enrollment schools did not have enough students to compute state standardized metrics are also not considered

📓 Social Studies and History subjects are not accounted for as much as ELA, Math, and Science
   
   - some high schools only offer social studies subjects such as government every other year
   - this could impact the way these subjects are reported in my sample


### Dataset Dilemma: Sacrifice Sample Size or Demographic Info?

Most of the remaining null values are in "SG" categories, referring to certain student groups (such as students with learning disabilities and ESL students). In order to deal with the remaining missing values, I considered two options.

Option #1: Remove SG Growth Columns 

   ✅  Pros = keeps sample size high

   🛑  Cons = reduces dimensionality by 3, excludes interesting angle for analysis 

Option #2: Remove Remaining Rows (Schools) with Null Values 

   ✅  Pros = keeps dimensionality high, includes student groups

   🛑  Cons = excludes 60 high schools from analysis

#### My Choice

I chose Option #2 that includes student group growth data. 

I decided that I would rather keep the student group columns and sacrifice some of the sample size because I think this is a really important piece of information for schools to look at. Schools often look toward programs where ESL and other minority students perform well. I still have n = 239 high schools with 32 total columns in my df. The high number of dimensions is suitable for Principal Components Analysis (PCA).


### Description of Variables: Cleaned Dataset

![Desc](/Plots/var_desc.JPEG?raw=true "Vars")



### MANOVA: Multivariate Analysis Of Variance

The first thing I wanted to try with my data was MANOVA. I created groups for comparison using school enrollment size (big v. small schools) and % of student population qualifying for Free and Reduced Lunches. These seemed like good starting points to check if there were major performance differences based on these variables that represent socioeconomic environment and size of schools.


#### Checking MANOVA Assumptions:
- <b>Independence between observations</b>
  - ✅
- <b>Multivariate Normality</b>
   - ❌

Royston's Test for Multivariate Normality
     
![Norm](/Plots/mvn_normality_roy.png?raw=true "Test")

Anderson-Darling's Test for Univariate Normality

![Norm](/Plots/univariate_normality_anderson.png?raw=true "Test")
   note: quadratic, square root, and log transformations were unsuccessful for all variables which failed the Anderson-Darling Test


- <b>Absence of multicollinearity</b>
   - ❌✅

![Cor](/Plots/cor_heatmap_1.png?raw=true "Heatmap")

#### Moving on

With both normality and multicollinearity violations, I decided not to move forward with this method. 


### Principal Components Analysis (PCA)

#### Checking PCA Assumptions:
- <b>Continuous variables</b>
   - ✅
- <b>Linear relationships between variables</b>
   - ✅
- <b>High sample size</b>
   - ✅
- <b>No significant outliers</b>
   - ❌✅
 
![MVN](/Plots/mvn_outliers.png?raw=true "Mahalanobis")
note: only five of these appear to be extreme outliers (8, 300, 221, 146, 132) and that is not a horrible violation of this assumption;
moving forward each method will be tested with and without these 5 schools to see if their removal is essential to interpretation


### Full Model

![scree](/Plots/full_mod.JPEG?raw=true "PCA")

1. Number of principal componenets = 4

2. Proportion of variance explained

   PC1: 38.6%

   PC2: 17.9%

   PC3: 12.4%

   PC4: 6.3%

🎖 TOTAL: 75.2% 

3. Biplot, PC1-PC2

   

### Model without outliers

This model produced results nearly indentical to the full model, thus they are not described here. Documentation in the R code shows full comparison of these two models.

### Subsetting by % Free and Reduced Lunch

One of my original questions about student performance among Missouri high schools was on the effect of wealth/nourishment through the given Free and Reduced Lunch (FRL) metric. Due to the assumptions of MANOVA being violated, I could not run that multivariate test. I chose to subset my cleaned dataset by schools with 50% or more qualifying for FRL and one for less than 50%.

### PCA, <50% qualifying for FRL (💰 higher income)

![scree](/Plots/FRL_low.JPEG?raw=true "PCA")

1. Number of principal components = 4

2. Proportion of variance explained

   PC1: 35.7%

   PC2: 23.0%

   PC3: 12.6%

   PC4: 7.7%

🎖 TOTAL: 79.0% 

3. Biplot, PC1-PC2



### PCA, >50% qualifying for FRL (💰 lower income)

![scree](/Plots/FRL_high.JPEG?raw=true "PCA")

1. Number of principal components = 4

2. Proportion of variance explained

   PC1: 39.3%

   PC2: 17.4%

   PC3: 8.9%

   PC4: 6.6%

🎖 TOTAL: 72.2% 




### Interpretations

#### Full Model

- Student performance, measured by test and growth scores, and attendance metrics account for most variation in this dataset. The plots below show key differences between schools with high and low % of students qualifying for FRL.

#### High and Low % (Free & Reduced Lunch)

![scree](/Plots/biplot_comparison.png?raw=true "PCA")

- Higher proportion of variance explained in 4 PCs for low % group
   - The variables in this dataset do well to explain variance for a higher income population
   - I interpret this to mean that lower-income schools experience other factors that may influence student performance not captured in this dataset
- Attendance metrics contribute more to PCs for the high % group
   - High variance in testing attendance could be explained further through additional socioeconomic variables such as mode/access to transportation

# Future work and considerations
![beauty](/Photos/even_mo_nature.jpg?raw=true "Clean")


- Canonical Correlation Analysis
   - This method could potentially identify relationships between performance metrics and demographic makeup
- K-means clustering
   - The PCA's provided are a good basis for identifying schools similar to each other based on size and performance
- Univariate Tests
   - There were a handful of univariate normal variables... this wasn't the focus of my project, but could be interesting to test on a univariate level to supplement with multivariate findings




