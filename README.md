# MO-Education
Multivariate analysis of Missouri High Schools using Principal Components Analysis.

<h2>Description</h2>
The goal of this project is to utilize multivariate statistical techniques to test preconceived assumptions about educational performance between schools with varying student demographics as well as reveal new insights about student learning. Multivariate methods provide us a way to view many different dimensions of learning (in-class learning, at-home learning, school financial resources, demographics, etc.) and interpret how those can all be related to student success. 

<h2>Languages and Utilities Used</h2>

- <b>RStudio</b> 
- <b>tidyverse</b>
- <b>factoextra</b>

<h2>Project walk-through:</h2>

### Gathering the Data
The data for this project was obtained through the Missouri Department of Education’s online Comprehensive Data System (MCDS). Three different datasets were combined to increase the number of variables and scope of analysis. I am working primarily off of the 2023 Supporting Building Report data from MCDS (link: https://apps.dese.mo.gov/MCDS/home.aspx) and adding columns from Free and Reduced Lunch Percentage (2023) and Per Pupil Expenditures (2023).


### Data Cleaning
1. Narrow focus of analysis to only 4-year high schools
   
![Cleaning1](/cleaning_select_hs.png?raw=true "Clean")

  
2. Inspect null values
- columns with null values and the number of occurances
     
![Nulls](/proportion_null_1.png?raw=true "Nulls")

   - columns and the number of occurances AFTER removing schools with 8 or more total null values across all columns
      - NOTE: social studies categories have been removed due to over half of their observations being missing
     
![Nulls](/proportion_null_2.png?raw=true "Nulls")



3. Caveats
- <b>Some schools report 100% of students qualify for Free and Reduced Lunch</b>
  - schools can qualify 100% if a high enough proportion of students are direct certified
  - link to eligibility guidelines: https://dese.mo.gov/financial-admin-services/food-nutrition-services/community-eligibility-provisiocep 
- <b>Special education schools had to be removed because of reporting differences</b>
- <b>Low-enrollment schools sometimes had to be removed due to not having enough students to compute state standardized metrics</b>
- <b>Social Studies and History subjects are not accounted for as much as ELA, Math, and Science</b>
  - this can be explained through potential adjustments for school capacity
    - a common example of this is offering government every other year



### Dataset Dilemma: Sacrifice Sample Size or Demographic Info?

Most of the remaining null values are in "SG" categories, referring to minority students (learning disabilities, minorities, ESL students, etc.). In order to deal with the remaining missing values, I considered two options.

####  Option #1: Remove SG Growth Columns 

✅  Pros = keeps sample size high

🛑  Cons = reduces dimensionality by 3, excludes interesting angle for analysis 

####  Option #2: Remove Remaining Rows (Schools) with Null Values 

✅  Pros = keeps dimensionality high, includes student groups

🛑  Cons = excludes 60 high schools from analysis

#### My Choice

I chose Option #2 that includes student group growth data. I decided that I would rather keep the student group columns and sacrifice some of the sample size because I think this is a really important piece of information for schools to look at. Schools often look toward programs where ESL and other minority students perform well. I still have n = 239 high schools with 32 total columns in my df. The high number of dimensions is suitable for Principal Components Analysis (PCA).


### Description of Variables: Cleaned Dataset
![Desc](/var_desc_1.png?raw=true "Vars")
![Desc](/var_desc_2.png?raw=true "Vars")



### MANOVA: Multivariate Analysis Of Variance

The first thing I wanted to try with my data was MANOVA. I created groups for comparison using school enrollment size (big v. small schools) and % of student population qualifying for Free and Reduced Lunches. These seemed like good starting points to check if there were major performance differences based on these variables that represent wealth and capacity of schools.


#### Checking MANOVA Assumptions:
- <b>Independence between observations</b>
  - ✅
- <b>Multivariate Normality</b>
   - ❌

Royston's Test for Multivariate Normality
     
![Norm](/mvn_normality_roy.png?raw=true "Test")

Anderson-Darling's Test for Univariate Normality

![Norm](/univariate_normality_anderson.png?raw=true "Test")
note: quadratic, square root, and log transformations were unsuccessful for all variables which failed the Anderson-Darling Test


- <b>Absence of multicollinearity</b>
   - ❌✅

![Cor](/cor_heatmap_1.png?raw=true "Heatmap")




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
 
![MVN](/mvn_outliers.png?raw=true "Mahalanobis")
note: only five of these appear to be extreme outliers (8, 300, 221, 146, 132) and that is not a horrible violation of this assumption;
moving forward each method will be tested with and without these 5 schools to see if their removal is essential to interpretation


### Full Model

1. Number of principal componenets = 4

![scree](/scree_pca1.png?raw=true "PCA")

2. Proportion of variance explained

   PC1: 38.6%

   PC2: 17.9%

   PC3: 12.4%

   PC4: 6.3%

🎖 TOTAL: 75.2% 

4. Biplot, PC1-PC2

![biplot](/biplot_pca1.png?raw=true "PCA")

   

### Model without outliers

This model produced results nearly indentical to the full model, thus they are not described here. Documentation in the R code shows full comparison of these two models.

### Subsetting by % Free and Reduced Lunch

One of my original questions about student performance among Missouri high schools was on the effect of wealth/nourishment through the given Free and Reduced Lunch (FRL) metric. Due to the assumptions of MANOVA being violated, I could not run that multivariate test. I chose to subset my cleaned dataset by schools with 50% or more qualifying for FRL and one for less than 50%.

### PCA, <50% qualifying for FRL (💰 higher income)

1. Number of principal components = 4

![scree](/scree_low_FRL.png?raw=true "PCA")

2. Proportion of variance explained

   PC1: 35.7%

   PC2: 23.0%

   PC3: 12.6%

   PC4: 7.7%

🎖 TOTAL: 79.0% 

3. Biplot, PC1-PC2

![scree](/biplot_low_FRL.png?raw=true "PCA")


### PCA, >50% qualifying for FRL (💰 lower income)

1. Number of principal components = 4

![scree](/scree_high_FRL.png?raw=true "PCA")

2. Proportion of variance explained

   PC1: 39.3%

   PC2: 17.4%

   PC3: 8.9%

   PC4: 6.6%

🎖 TOTAL: 72.2% 

3. Biplot, PC1-PC2

![scree](/biplot_high_FRL.png?raw=true "PCA")



### Interpretations

![scree](/biplot_comparison.png?raw=true "PCA")

![scree](/pca_interpretations.png?raw=true "PCA")

### Future work and considerations

- Canonical Correlation Analysis
   - This method could potentially identify relationships between performance metrics and demographic makeup
- K-means clustering
   - The PCA's provided are a good basis for identifying schools similar to each other based on size and performance
- Univariate Tests
   - There were a handful of univariate normal variables... this wasn't the focus of my project, but could be interesting to test on a univariate level to supplement with multivariate findings




