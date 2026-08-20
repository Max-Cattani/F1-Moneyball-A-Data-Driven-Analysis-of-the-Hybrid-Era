################################################################################
##### F1 Moneyball: A Data Driven analysis of the Hybrid Era ###################
####################################### by Massimo Cattani #####################


#_____Upload required packages_____#

library(dplyr)
library(ggplot2)
library(readr)
library(NbClust)
library(tibble)
library(ggrepel)

#_____Upload financial data_____#
f1_budget = read.csv("f1_budget_2014-2025.csv")

#_____Data cleaning focused on teams who their change name over the seasons_____#
f1_budget = f1_budget %>% 
  mutate(constructor_id = case_when(
    constructor_id %in% c("rb", "toro_rosso","alphatauri") ~ "faenza_team",
    constructor_id %in% c("lotus_f1", "renault","alpine") ~ "enstone_team",
    constructor_id %in% c("racing_point", "aston_martin","force_india") ~ "silverstone_team",
    constructor_id %in% c("alfa","sauber") ~ "swiss_team",
    TRUE ~ constructor_id)) %>%
  filter(year<2025)

#_____pit stop performance data - from DHL pit stop award_____#
pit_stop <- read_csv("DHL_pit_stop.csv",
                     col_types = cols(`total_pit_points;;;;;` = col_number()))
pit_stop = pit_stop %>%
  rename("total_pit_points" = "total_pit_points;;;;;")%>%
  filter(year<2025) %>%
  mutate(legacy = case_when(
    legacy %in% c("rb", "toro_rosso","alphatauri") ~ "faenza_team",
    legacy %in% c("lotus_f1", "renault","alpine") ~ "enstone_team",
    legacy %in% c("racing_point", "aston_martin","force_india") ~ "silverstone_team",
    legacy %in% c("alfa","sauber") ~ "swiss_team",
    TRUE ~ legacy))


#_____races results_____#
results = read.csv("results_2024.csv")
finished = c(1, 11:19, 45, 50, 53, 55, 58, 88, 111:120, 122:125, 127:128, 133:134)
technical = c(5:10, 21:26, 30, 32, 34, 37:40, 42:44, 46:49, 51, 56, 129, 63, 65, 67, 69:70, 72, 75, 79:80, 83:84, 86:87, 91, 94:95, 98, 101, 103, 108, 110, 131, 132, 141)
accident = c(3, 4, 20, 130, 137, 138, 140)

#_____cleaning races results_____#
results = results %>%
  mutate(statusId = case_when(
    statusId %in% finished ~ "Finished",
    statusId %in% technical ~ "DNF_Technical",
    statusId %in% accident ~ "DNF_Accident",
    TRUE ~ "Other"
  ))

races = read.csv("races_2024.csv")
constructors = read.csv("constructors_2024.csv")


#_____Drivers data_____#
driverid = read.csv("drivers_2024.csv")

#_____JOIN_____#
hybrid_era = results %>%
  left_join(races, by = "raceId") %>%
  filter(year >= 2014) %>%
  left_join(constructors, by = "constructorId") %>%
  left_join(driverid, by = "driverId") %>%
  select(raceId, year, constructorRef, grid, positionOrder, points, rank, statusId, surname)

#_____mutating teams name again for helping future join_____#
hybrid_era = hybrid_era %>%
  mutate(constructorRef = case_when(
    constructorRef %in% c("rb", "toro_rosso","alphatauri") ~ "faenza_team",
    constructorRef %in% c("lotus_f1", "renault","alpine") ~ "enstone_team",
    constructorRef %in% c("racing_point", "aston_martin","force_india") ~ "silverstone_team",
    constructorRef %in% c("alfa","sauber") ~ "swiss_team",
    TRUE ~ constructorRef)) %>%
  mutate(is_wdc = case_when(
    surname %in% c("Alonso","Räikkönen", "Hamilton","Button", "Vettel", "Rosberg", "Verstappen") ~ 1,
    TRUE ~ 0))
# This is our DataBase of the Hybrid Era on which is possible to start many analyses...

df1 = hybrid_era %>%
  group_by(constructorRef, year) %>%
  summarise(mean_start = mean(grid),mean_finish = mean(positionOrder), delta_performance = mean_start - mean_finish,mean_points = sum(points)/n_distinct(raceId), num_fastest_lap = sum(rank == 1),
            num_podiums = sum(positionOrder %in% 1:3), num_wins = sum(positionOrder == 1), num_tech_dnf = sum(statusId == "DNF_Technical") ,
            standings = sum(points), wins_rate = (num_wins/n_distinct(raceId))*100, reliability_rate = (1 - (num_tech_dnf / n())) * 100, has_wdc = max(is_wdc)) %>%
  arrange(year, desc(standings))
# Dataset of performance indicator variables

#_____JOIN w/budget_____#

df_full = df1 %>%
  left_join(f1_budget, by = c("constructorRef" ="constructor_id", "year"))%>%
  left_join(pit_stop, by = c("constructorRef"= "legacy", "year"))

ggplot(df_full, aes(x = budget_millions_usd, y = standings)) +
  geom_point(colour = "lightgreen") +
  geom_smooth(method = "lm", colour = "darkgreen") # Too little variability explained

ggplot(df_full, aes(x = budget_millions_usd, y = standings, colour = status)) +
  geom_point(mapping = ) +
  geom_smooth(method = "lm") # That's a starting point for further investigation



#_____Cluster analysis_____#

df_clustering_prep = df_full %>%
  filter(year < 2021) %>%
  mutate(team_year = paste(constructorRef, year, sep = "_")) %>%
  select(team_year, budget_millions_usd, standings)

df_full_clustering = df_clustering_prep %>%
  column_to_rownames("team_year") %>%
  select(budget_millions_usd, standings)
df_full_clustering = scale(df_full_clustering)

ResClustering = NbClust(data = df_full_clustering, distance = "euclidean", method = "kmeans", index = "all")
#* 8 proposed 2 as the best number of clusters 
#* 6 proposed 3 as the best number of clusters --> we pick this solution because of the real standing structure is composed of Top teams, Midfield and Bottom of the grid
#                                             --> we could choose 2 centers, however the presence of many overlaps and observations suggests a 
#                                                 3 clusters grid, each one with its own attributes: 3 clusters explain much more of the standings variability

set.seed(1)
Kmeans_f1 = kmeans(df_full_clustering, nstart = 50, centers = 3)
df_pre_cap = df_full %>%
  filter(year < 2021)

df_pre_cap$cluster_id = as.factor(Kmeans_f1$cluster)

df_pre_cap <- df_pre_cap %>%
  mutate(team_year = paste(constructorRef, year, sep = "_"))# Useful for highlighting key observations

ggplot(df_pre_cap, aes(x = budget_millions_usd, y = standings, colour = cluster_id)) +
  geom_point(linewidth = 2, alpha = 0.7) +
  geom_smooth(method = "lm", se = T) +
  geom_text_repel(aes(label = ifelse(team_year %in% c("ferrari_2020", "mercedes_2019", "williams_2019", "mclaren_2015","silverstone_team_2020","mercedes_2020","williams_2014"), team_year, "")),
                  size = 4, fontface= "bold.italic", box.padding = 0.1, show.legend = FALSE) +
  labs(title = "Cluster Analysis: Budget Efficiency",
       subtitle = "The decreasing line shows financial and engineering crisis",
       x = "Budget (Millions USD)", y = "Standings", colour = "Cluster") +
  theme_minimal()
# Few subtrends explained...

# Using other predictors, the accuracy and interpretability of the target variable may improve

model1 = lm(standings ~ budget_millions_usd + mean_start + mean_finish + delta_performance + mean_points + num_fastest_lap + num_podiums +
              num_wins + num_tech_dnf + wins_rate + reliability_rate + has_wdc + total_pit_points, data = df_full)
summary(model1)
# High multicollinearity
# Predictor selection required = catching key factors for a winning team



#_____LASSO_____#
library(glmnet)
grid <- 10^seq(10, -2, length = 100) # Lambda grid of values


#_____ERA 1: PRE-CAP (2014-2020)_____#
df_pre <- df_full %>% filter(year <= 2020) %>% na.omit()

#____matrix X_____#
x_pre = model.matrix(standings ~ budget_millions_usd + delta_performance
                     + num_fastest_lap  + num_tech_dnf + reliability_rate
                     + has_wdc + mean_start + total_pit_points, data = df_pre)[,-1]
y_pre = df_pre$standings

set.seed(1)
train_pre = sample(1:nrow(x_pre), 0.7*nrow(x_pre))
test_pre = (-train_pre)
y.test_pre = y_pre[test_pre]
lasso_pre = glmnet(x_pre[train_pre,],y_pre[train_pre], alpha = 1, lambda = grid)

#_____Cross-Validation_____#
set.seed(1)
cv_pre = cv.glmnet(x_pre[train_pre,],y_pre[train_pre], alpha = 1, lambda = grid)
best_lambda = cv_pre$lambda.min

plot(cv_pre)
abline(v = log(cv_pre$lambda.min), col = "blue", lwd = 1.5)
title("Cross-Validation: Choice of Penalty Parameter", line = 3)

#_____LASSO coefficients' path_____#
plot(lasso_pre, xvar = "lambda", xlim = c(-5, 6))
y_pos <- lasso_pre$beta[, ncol(lasso_pre$beta)]
text(x = min(log(lasso_pre$lambda)), y = y_pos, labels = colnames(x_pre), pos = 1, xpd = TRUE, cex = 0.5, col = "blue")
abline(v = log(cv_pre$lambda.min), col = "red", lty = 2)
title("Lasso Path: Pre-Budget Cap", line = 2)


lasso_pre_pred = predict(lasso_pre, s = best_lambda, newx = x_pre[test_pre,])
mse_pre = mean((lasso_pre_pred-y.test_pre)^2)
print(sqrt(mse_pre))

#_____coefficients extraction_____#
out_pre = glmnet(x_pre, y_pre, alpha = 1, lambda = grid)
lasso.coef_pre = predict(out_pre , type = "coefficients",s = best_lambda)
print(lasso.coef_pre) # Negative delta paradox (regarding comebacks) is resolved by adding 'mean_start'.
# The model better captures top team comebacks (e.g., 7th to 3rd) rather than midfield ones.
# Conclusion: Starting position drives wins; gaining positions earns points, but certainly fewer than starting at the front.


#_____ERA 2: POST-CAP (2021-2024)_____#
df_post <- df_full %>% filter(year > 2020) %>% na.omit()

x_post = model.matrix(standings ~ budget_millions_usd + delta_performance
                      + num_fastest_lap  + num_tech_dnf + reliability_rate
                      + has_wdc + mean_start + total_pit_points, data = df_post)[,-1]
y_post = df_post$standings

set.seed(1)
train_post = sample(1:nrow(x_post), 0.7*nrow(x_post))
test_post = (-train_post)

y.post_test = y_post[test_post]


lasso_post = glmnet(x_post[train_post,], y_post[train_post], alpha = 1, lambda = grid)

#_____CV_____#
set.seed(1)
cv_post = cv.glmnet(x_post[train_post,],y_post[train_post], alpha = 1, lambda = grid )
best_lambda_post = cv_post$lambda.min
print(best_lambda_post)


plot(cv_post)
abline(v = log(cv_post$lambda.min), col = "blue", lwd = 1.5)
title("Cross-Validation: Choice of Penalty Parameter", line = 3)


plot(lasso_post, xvar = "lambda", xlim = c(-5, 6))
y_pos <- lasso_post$beta[, ncol(lasso_post$beta)]
text(x = min(log(lasso_post$lambda)), y = y_pos, labels = colnames(x_post), pos = 1, xpd = TRUE, cex = 0.5, col = "blue")
abline(v = log(cv_post$lambda.min), col = "red", lty = 2)
title("Lasso Path: Post-Budget Cap", line = 2)


lasso.pred_post = predict(lasso_post, s = best_lambda_post, newx = x_post[test_post,])
mse_post = mean((lasso.pred_post-y.post_test)^2)
print(sqrt(mse_post))

out_post = glmnet(x_post, y_post , alpha = 1, lambda = grid)
lasso.coef_post = predict(out_post, type = "coefficients", s = best_lambda_post)
print(lasso.coef_post)
# As the years go by races are characterized by less overtakes, however delta_performance coeff. increased, but as aforementioned, comebacks are a Top teams perk
# Further demonstration of this conclusion are evaluated in the following lines


#____Comeback Paradox_____#
ggplot(df_pre_cap, aes(x = delta_performance, y = standings, colour = cluster_id)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_smooth(method = "lm", se = FALSE, size = 1.2) +
  labs(title = "Comeback Paradox (Pre-Cap Era)",
       subtitle = "The capacity of remounting during races is a Top Team exclusive",
       x = "Gained Positions (Delta Performance)",
       y = "Standings",
       color = "Cluster") +
  theme_minimal()

# Analyzing come back paradox in depth with an interaction model

mod_verification = lm(standings ~ delta_performance * cluster_id, data = df_pre_cap)
summary(mod_verification)


df_post = df_post %>%
  mutate(team_year = paste(constructorRef, year, sep = "_"))

df_post = df_post %>% mutate(tier = as.factor(ifelse(mean_start <= 7.4, "Top_Team", "Rest_of_Grid"))) # 7.4 it's obtainable from Regression Trees split

table(df_post$tier)

# Post-Cap Interaction model
mod_verification_post = lm(standings ~ delta_performance * tier, data = df_post)
summary(mod_verification_post)


ggplot(df_post, aes(x = delta_performance, y = standings, colour = tier)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_smooth(method = "lm", se = FALSE, size = 1.2) +
  labs(title = "Comeback Paradox (Post-Cap Era)",
       subtitle = "The capacity of remounting during races is a Top Team exclusive: The Gap is bigger in the post-cap era",
       x = "Gained Positions (Delta Performance)",
       y = "Standings",
       color = "Cluster") +
  theme_minimal()


# The interaction models confirm the comeback paradox across both eras: gaining positions (delta_performance) 
# translates into significant points exclusively for Top Teams.
# For the rest of the grid, race-day comebacks yield negligible or even negative marginal points, 
# proving that their success is heavily dictated by starting position rather than race recovery.

#_____Regression Tree_____#
library(tree)

set.seed(1)
train_pre = sample(1:nrow(x_pre), 0.7*nrow(x_pre))
test_pre = (-train_pre)

tree_pre = tree(standings ~ budget_millions_usd + delta_performance
                + num_fastest_lap  + num_tech_dnf + reliability_rate
                + has_wdc + mean_start + total_pit_points, data = df_pre[train_pre,])
summary(tree_pre)
plot(tree_pre)
text(tree_pre, pretty = 0)


#_____CV_____#
cv_tree_pre = cv.tree(tree_pre)
plot(cv_tree_pre$size, cv_tree_pre$dev, type = "b")
yhat = predict(tree_pre, newdata = df_pre[-train_pre, ])
y_test_real = df_pre[-train_pre, ]$standings

# Predicted vs Observed
plot(yhat, y_test_real,
     main = "Regression Tree: Fitted vs Real",
     xlab = "Predicted points", ylab = "Real points",
     pch = 19, col = "blue")
abline(0, 1, col = "red", lty = 2) # 45° ideal line

mse_tree = mean((yhat - y_test_real)^2)
sqrt(mse_tree)

prune_pre = prune.tree(tree_pre, best = cv_tree_pre$size[1])
plot(prune_pre)
text(prune_pre, pretty = 0)


#_____Post-Cap Era_____#
set.seed(1)
train_post = sample(1:nrow(x_post), 0.7*nrow(x_post))
tree_post = tree(standings ~ budget_millions_usd + delta_performance +
                   num_fastest_lap + num_tech_dnf +
                   has_wdc + mean_start + total_pit_points,
                 data = df_post[train_post,])

summary(tree_post)

# Visualization
plot(tree_post)
text(tree_post, pretty = 0)

cv_tree_post = cv.tree(tree_post)
plot(cv_tree_post$size, cv_tree_post$dev, type = "b")
yhat_post = predict(tree_post, newdata = df_post[-train_post, ])
y_test_post = df_post[-train_post, ]$standings

plot(yhat_post, y_test_post)
abline(0, 1, col = "red", lty = 2)

mse_tree_post = mean((yhat_post - y_test_post)^2)
sqrt(mse_tree_post) # It's a reasonable values for fewer observation than Pre-Cap Era

#################################################################################################################
###### COMING SOON: ROBUSTNESS CHECK - PYTHON VERSION - COMPARISON ##############################################
