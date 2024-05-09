# MO-Education
Multivariate analysis of Missouri High Schools using Principal Components Analysis and MANOVA.

<h2>Description</h2>
The goal of this project is to utilize multivariate statistical techniques to test preconceived assumptions about educational performance between schools with varying student demographics as well as reveal new insights about student learning. Multivariate methods provide us a way to view many different dimensions of learning (in-class learning, at-home learning, school financial resources, demographics, etc.) and interpret how those can all be related to student success. I chose to look at Missouri because (1) I grew up in Missouri and attended the same school district for my K-12 education; and (2) I have personal ties to public school teachers and administrators in Missouri that were able to help me decipher the meaning behind many of the variables in my dataset and direct the focus of this project.

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
   - count of null values per column: full data 
![Mod1](/311-Mod1.jpg?raw=true "Mod")
   - count of null values per column: after removing 7 schools
     - 3/7 are special education schools and 4/7 are low enough enrollment that the state doesn't compute standard metrics


4. Caveats
- <b>Some schools report 100% of students qualify for Free and Reduced Lunch</b>
  - schools can qualify 100% if a high enough proportion are direct certified
  - link to eligibility guidelines: https://dese.mo.gov/financial-admin-services/food-nutrition-services/community-eligibility-provisiocep 
- <b>Special education schools had to be removed because of reporting differences</b>
- <b>Low-enrollment schools sometimes had to be removed due to not having enough students to compute state standardized metrics</b>
- <b>Social Studies and History subjects are accounted for less than ELA, Math, and Science</b>
  - adjustments for school capacity such as offering government every other year



### Dataset Dilemma: Sacrifice Sample Size or Demographic Info?


### Description of Variables: Cleaned Dataset
![Desc](/var_desc_1.png?raw=true "Vars")
![Desc](/var_desc_2.png?raw=true "Vars")



### MANOVA

Assumptions:
- <b>Independence between observations</b> 
- <b>Multivariate Normality</b>
- <b>Absence of multicollinearity</b>

### Principal Components Analysis (PCA)

Assumptions:
- <b>Continuous variables</b> 
- <b>Linear relationships between variables</b>
- <b>High sample size</b>
- <b>Continuous variables</b> 
- <b>No significant outliers</b> 



picture notation:
------------------
![Mod1](/311-Mod1.jpg?raw=true "Mod")
