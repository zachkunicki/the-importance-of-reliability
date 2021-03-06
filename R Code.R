###################################
## The Importance of Reliability ##
###################################

#install.packages("remotes")
#remotes::install_github("debruine/faux")

## Loading Packages ##

library(MASS)
library(faux)
library(tidyverse)
library(purrr)
library(psych)

## Writing Function ##

reliability_test <- function(obs, r){

  data = MASS::mvrnorm(n=obs, mu=c(0, 0), Sigma=matrix(c(1, r, r, 1), nrow=2), empirical=TRUE)
  X = data[, 1]  # standard normal (mu=0, sd=1)
  Y = data[, 2]  # standard normal (mu=0, sd=1)
  
  df <- cbind(X, Y)
  
  df <- as_tibble(df)
  
  prob = c(.1, .2, .4, .2, .1)
  
  df <- df %>% mutate(X_Ordinal = norm2likert(X, prob = prob),
                      Y_Ordinal = norm2likert(Y, prob = prob))
  
  df$D <- df$X_Ordinal - df$Y_Ordinal
  
  df_results <- df %>% count(D)

  reliability_absolute_results <- df_results %>% filter(D == 0) 
  reliability_absolute_results
  
  reliability_absolute <- sum(reliability_absolute_results$n)/obs
  reliability_absolute
    
  reliability_approx_results <- df_results %>% filter(between(D, -1, 1)) 
  reliability_approx_results
  
  reliability_approx <- sum(reliability_approx_results$n)/obs
  reliability_approx
  
  reliability_nottrue_results <- df_results %>% filter(!between(D, -1, 1))
  reliability_nottrue_results
  
  reliability_nottrue <- sum(reliability_nottrue_results$n)/obs
  
  # Wanted to print the table of results so we could see it easily, can take out or replace with
  # a histogram for data visualization.
  diff_results <- c("absolute reliability" = reliability_absolute, "approximate reliability" = reliability_approx,
                    "loose reliability" = reliability_nottrue)
  #print(diff_results)

  return(diff_results)
  }

reliability_test(200000, .97)
reliability_test(200000, .95)
reliability_test(200000, .9)
reliability_test(200000, .8)
reliability_test(200000, .7)
reliability_test(200000, .6)
reliability_test(200000, .5)
reliability_test(200000, .4)
reliability_test(200000, .3)
reliability_test(200000, .2)
reliability_test(200000, .1)


reliability_test(200, .95)
reliability_test(200, .9)
reliability_test(200, .8)
reliability_test(200, .7)
reliability_test(200, .6)
reliability_test(200, .5)
reliability_test(200, .4)
reliability_test(200, .3)
reliability_test(200, .2)
reliability_test(200, .1)



iterate <- map(seq_len(1000), ~reliability_test(20000, .8))
#This line runs the reliability_test function for nobs = 20000 and reliability = .8 for 1000 iterations

iterate.df <- data.frame(matrix(unlist(iterate), nrow=length(iterate), byrow = T))
#This unlists the iterate function and turns it into a dataframe. X1 = true, X2 = false

describe(iterate.df$X1)
describe(iterate.df$X2)

mean(iterate.df$X1)
sd(iterate.df$X1)

True.CI <- c(mean(iterate.df$X1) - 1.96*((sd(iterate.df$X1)/sqrt(100))), mean(iterate.df$X1) + 1.96*((sd(iterate.df$X1)/sqrt(100)))) 
False.CI <- c(mean(iterate.df$X2) - 1.96*((sd(iterate.df$X2)/sqrt(100))), mean(iterate.df$X2) + 1.96*((sd(iterate.df$X2)/sqrt(100))))

#Below are notes taken in QSP/RJ Meetings on possible ways to set up an iteration fuction.
#Notes stop at the #####

#Set up data frame before iterating the function
#Before 10 iterations, set up dataframe with 10 rows, have variable called "replicate"
#numbered 1 to N, where N is number of replications

#Edit function to return just p, not p, q -- or figure out how to parse the 2 parts of
#the list
iterate[[2]]

df <- data.frame(true = iterate[1], false=iterate[2])

it2 <-

df = NULL
for (k in 1:1000)
{
  true = iterate[1]
  false = iterate[2]
  df = rbind(df, data.frame(true,false))
}

#Use lapply or purrr to set up a dataframe with 1000 rows
#mutate, results = purr(give function)
#bsample function to put into purr command

#edit function to save out just the proportion in agreement
#alt: save out the dataframe, do the calculation afterwards. either approach would work

#could save out the list, label first part the dataframe, second part the proportion, third part is whatever else, then save out the entire thing
#then call for just the first part of the list (or whichever part is the dataframe/needed)

#####


## Simulating Data with a Pre-Specified Correlation ##

set.seed(2019)

#code pulled from stackexchange here:
# https://stats.stackexchange.com/questions/83172/generate-two-variables-with-precise-pre-specified-correlation?noredirect=1&lq=1

data_80 = mvrnorm(n=200, mu=c(0, 0), Sigma=matrix(c(1, .8, .8, 1), nrow=2), empirical=TRUE)
X_80 = data_80[, 1]  # standard normal (mu=0, sd=1)
Y_80 = data_80[, 2]  # standard normal (mu=0, sd=1)

cor.test(X_80, Y_80)

## Converting Simulated Data to Likert-type Data ##

df_80 <- cbind(X_80, Y_80)

df_80 <- as_data_frame(df_80)

prob = c(.1, .2, .4, .2, .1)

df_80 <- df_80 %>% mutate(X_Ordinal = norm2likert(X_80, prob = prob),
                          Y_Ordinal = norm2likert(Y_80, prob = prob))

table(df_80$X_Ordinal)
table(df_80$Y_Ordinal)

## Plotting Data ##

df_80_plot <- df_80 %>% select(X_Ordinal, Y_Ordinal)

df_80_long <- df_80_plot %>% gather(label, key, X_Ordinal:Y_Ordinal)

ggplot(df_80_long, aes(x=key, color = label)) + geom_histogram(position = "identity")

## Determining 'Accurate' vs. 'Inaccurate' Data ##
# Let x.ordinal = "Truth" and y.ordinal = "Measured"
# Subtract y.ordinal from x.ordinal, called d. If d = -1, 0, or 1 then accurate. Otherwise, inaccurate. 

diff_80 <- df_80 %>% mutate(D = X_Ordinal - Y_Ordinal) 

diff_80_results <- diff_80 %>% count(D)

diff_80_results

# A tibble: 5 x 2
#      D     n
#1    -2     3
#2    -1    39
#3     0   112
#4     1    40
#5     2     6

#Based on the results, with a reliability of 0.80, (39 + 112 + 40) / 200 = 95.5% of the data can be considered
#accurate. For the remaining (3 + 6) / 200 = 4.5%, inaccurate.

#"Poor" Reliability

data_50 = mvrnorm(n=200, mu=c(0, 0), Sigma=matrix(c(1, .5, .5, 1), nrow=2), empirical=TRUE)
X_50 = data_50[, 1]  # standard normal (mu=0, sd=1)
Y_50 = data_50[, 2]  # standard normal (mu=0, sd=1)

cor.test(X_50, Y_50)

## Converting Simulated Data to Likert-type Data ##

df_50 <- cbind(X_50, Y_50)

df_50 <- as_data_frame(df_50)

prob = c(.1, .2, .4, .2, .1)

df_50 <- df_50 %>% mutate(X_Ordinal = norm2likert(X_50, prob = prob),
                          Y_Ordinal = norm2likert(Y_50, prob = prob))

table(df_50$X_Ordinal)
table(df_50$Y_Ordinal)

## Plotting Data ##

df_50_plot <- df_50 %>% select(X_Ordinal, Y_Ordinal)

df_50_long <- df_50_plot %>% gather(label, key, X_Ordinal:Y_Ordinal)

ggplot(df_50_long, aes(x=key, color = label)) + geom_histogram(position = "identity")

## Determining 'Accurate' vs. 'Inaccurate' Data ##
# Let x.ordinal = "Truth" and y.ordinal = "Measured"
# Subtract y.ordinal from x.ordinal, called d. If d = -1, 0, or 1 then accurate. Otherwise, inaccurate. 

diff_50 <- df_50 %>% mutate(D = X_Ordinal - Y_Ordinal) 

diff_50_results <- diff_50 %>% count(D)

diff_50_results

# A tibble: 7 x 2
#      D     n
#1    -3     1
#2    -2    20
#3    -1    47
#4     0    67
#5     1    47
#6     2    14
#7     3     4

#Based on the results, with a reliability of 0.50, (47 + 67 + 47) / 200 = 80.5% of the data can be considered
#accurate. For the remaining (1 + 20 + 14 + 4) / 200 = 19.5%, inaccurate.

#"Questionable" Reliability

data_60 = mvrnorm(n=200, mu=c(0, 0), Sigma=matrix(c(1, .6, .6, 1), nrow=2), empirical=TRUE)
X_60 = data_60[, 1]  # standard normal (mu=0, sd=1)
Y_60 = data_60[, 2]  # standard normal (mu=0, sd=1)

cor.test(X_60, Y_60)

## Converting Simulated Data to Likert-type Data ##

df_60 <- cbind(X_60, Y_60)

df_60 <- as_data_frame(df_60)

prob = c(.1, .2, .4, .2, .1)

df_60 <- df_60 %>% mutate(X_Ordinal = norm2likert(X_60, prob = prob),
                          Y_Ordinal = norm2likert(Y_60, prob = prob))

table(df_60$X_Ordinal)
table(df_60$Y_Ordinal)

## Plotting Data ##

df_60_plot <- df_60 %>% select(X_Ordinal, Y_Ordinal)

df_60_long <- df_60_plot %>% gather(label, key, X_Ordinal:Y_Ordinal)

ggplot(df_60_long, aes(x=key, color = label)) + geom_histogram(position = "identity")

## Determining 'Accurate' vs. 'Inaccurate' Data ##
# Let x.ordinal = "Truth" and y.ordinal = "Measured"
# Subtract y.ordinal from x.ordinal, called d. If d = -1, 0, or 1 then accurate. Otherwise, inaccurate. 

diff_60 <- df_60 %>% mutate(D = X_Ordinal - Y_Ordinal) 

diff_60_results <- diff_60 %>% count(D)

diff_60_results

# A tibble: 7 x 2
#      D     n
#1    -3     2
#2    -2    12
#3    -1    39
#4     0    94
#5     1    40
#6     2    12
#7     3     1

#Based on the results, with a reliability of 0.60, (39 + 94 + 40) / 200 = 86.5% of the data can be considered
#accurate. For the remaining (2 + 12 + 12 + 1) / 200 = 13.5%, inaccurate.

#"Acceptable" Reliability

data_70 = mvrnorm(n=200, mu=c(0, 0), Sigma=matrix(c(1, .7, .7, 1), nrow=2), empirical=TRUE)
X_70 = data_70[, 1]  # standard normal (mu=0, sd=1)
Y_70 = data_70[, 2]  # standard normal (mu=0, sd=1)

cor.test(X_70, Y_70)

## Converting Simulated Data to Likert-type Data ##

df_70 <- cbind(X_70, Y_70)

df_70 <- as_data_frame(df_70)

prob = c(.1, .2, .4, .2, .1)

df_70 <- df_70 %>% mutate(X_Ordinal = norm2likert(X_70, prob = prob),
                          Y_Ordinal = norm2likert(Y_70, prob = prob))

table(df_70$X_Ordinal)
table(df_70$Y_Ordinal)

## Plotting Data ##

df_70_plot <- df_70 %>% select(X_Ordinal, Y_Ordinal)

df_70_long <- df_70_plot %>% gather(label, key, X_Ordinal:Y_Ordinal)

ggplot(df_70_long, aes(x=key, color = label)) + geom_histogram(position = "identity")

## Determining 'Accurate' vs. 'Inaccurate' Data ##
# Let x.ordinal = "Truth" and y.ordinal = "Measured"
# Subtract y.ordinal from x.ordinal, called d. If d = -1, 0, or 1 then accurate. Otherwise, inaccurate. 

diff_70 <- df_70 %>% mutate(D = X_Ordinal - Y_Ordinal) 

diff_70_results <- diff_70 %>% count(D)

diff_70_results

# A tibble: 5 x 2
#      D     n
#1    -2     9
#2    -1    46
#3     0    83
#4     1    51
#5     2    11

#Based on the results, with a reliability of 0.70, (46 + 83 + 51) / 200 = 90% of the data can be considered
#accurate. For the remaining (9 + 11) / 200 = 10%, inaccurate.