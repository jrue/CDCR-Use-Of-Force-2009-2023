library(tidyverse)

#################
### Load Data ###
#################
# Load data
uof_hs <- read.csv("~/Downloads/use_of_force.csv", header=TRUE)

# Manually add the rest of 2023 data from https://public.tableau.com/app/profile/cdcr.or/viz/SB601/Statewide
months <- c("Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
year <- 2023
prison <- c(rep("CCI", 6),
            rep("COR", 6), 
            rep("HDSP", 6), 
            rep("KVSP", 6), 
            rep("LAC", 6), 
            rep("PBSP", 6), 
            rep("SAC", 6), 
            rep("SVSP", 6))

uof_values <- c(23, 37, 27, 18, 28, 34, # cci
                51, 57, 56, 49, 53, 61, # cor
                20, 26, 13, 21, 12, 11, # hdsp
                34, 51, 35, 44, 47, 46, # kvsp
                78, 78, 59, 82, 85, 65, # lac
                16, 12, 17, 15, 15, 31, # pbsp
                62, 55, 41, 65, 59, 60, # sac
                76, 56, 65, 61, 60, 70 # svsp
                )

pop_values <- c(1627, 1657, 1698, 1715, 1718, 1750, # cci
                3448, 3525, 3491, 3505, 3479, 3463, # cor
                2413, 2535, 2475, 2387, 2296, 2242, # hdsp
                2796, 2816, 2848, 2871, 2867, 2914, # kvsp
                2631, 2601, 2611, 2679, 2790, 2808, # lac
                1581, 1530, 1544, 1576, 1534, 1524, # pbsp
                1735, 1803, 1863, 1841, 1818, 1795, # sac
                2832, 2772, 2738, 2687, 2661, 2623 # svsp
                )

uof_end_2023 <- data.frame(Institution = prison,
                           Year = 2023,
                           Month = rep(months, 8),
                           use_of_force = uof_values,
                           inmate_count = pop_values) %>%
  mutate(uof_per_1000 = use_of_force * 1000 / inmate_count)

# Merge uof data
uof_hs <- uof_hs %>% bind_rows(uof_end_2023)

####################
### Analyze data ###
####################
# Average monthly use of force rate
uof_hs %>% 
  group_by(Institution) %>%
  summarize(mean_uof = mean(uof_per_1000),
            sd_uof = sd(uof_per_1000), 
            count = n())

# calculate uof change from 2009 to 2023
uof_2023 <- uof_hs %>%
  group_by(Institution, Year) %>%
  summarize(mean_uof = mean(uof_per_1000),
            sum_uof = sum(uof_per_1000)) %>%
  filter(Year %in% c(2023))

uof_2009 <- uof_hs %>%
  group_by(Institution, Year) %>%
  summarize(mean_uof = mean(uof_per_1000), sum_uof = sum(uof_per_1000)) %>%
  filter(Year %in% c(2009))

uof_2009 %>% 
  left_join(uof_2023, by = "Institution") %>% 
  mutate(uof_ratio = mean_uof.y / mean_uof.x) %>%
  ungroup() %>%
  summarize(mean(uof_ratio))

# Plot uof rate by year
uof_hs %>% 
  group_by(Year) %>%
  summarize(mean_uof = mean(uof_per_1000), sum_uof = sum(uof_per_1000)) %>%
  ggplot(aes(x = Year, y = mean_uof)) +
  geom_point(size = 5) +
  labs(x = "Year", y = "Average UOF per 1000 inmates", title = "Average UOF rate for HSI, 2009-2023") + 
  theme(plot.title = element_text(hjust = 0.5), text = element_text(size = 15))

# Use of force by institution
avg_uof <- uof_hs %>%
  group_by(Institution) %>%
  summarize(mean_uof = mean(uof_per_1000))

avg_uof %>% 
  ggplot(aes(x = reorder(Institution, -mean_uof), y = mean_uof, 
             fill=factor(ifelse(Institution=="SAC","Highlighted","Normal")))) + 
  geom_col(show.legend = FALSE) +
  scale_fill_manual(name = "Institution", values=c("red","grey50")) +
  labs(x = "HSI", y = "Average monthly UOF per 1000 inmates", 
       title = "Average UOF per 1000 Inmates at HSIs, 2009-2023") +
  theme(plot.title = element_text(hjust = 0.5), text = element_text(size = 15))

# Yearly max
uof_hs %>%
  group_by(Institution, Year) %>%
  summarize(mean_uof = mean(uof_per_1000),
            sum_uof = sum(uof_per_1000)) %>%
  select(Institution, Year, mean_uof) %>%
  pivot_wider(names_from = Institution, values_from = mean_uof) %>%
  rowwise() %>%
  mutate(other_max = max(SVSP, CCI, COR, HDSP, KVSP, LAC, PBSP, na.rm = T)) %>% ## Figure out why NAs
  select(Year, SAC, other_max) %>%
  mutate(diff = SAC - other_max)

# Plot yearly data
uof_hs %>%
  group_by(Institution, Year) %>%
  summarize(mean_uof = mean(uof_per_1000),
            sum_uof = sum(uof_per_1000)) %>%
  ggplot(aes(x = Year, y = mean_uof, col = Institution)) +
    geom_line() +
  labs(y = "Average Monthly UOF per 1000 Inmates",
       title = "Average Monthly UOF Rate by Year and Institution") +
  theme(plot.title = element_text(hjust = 0.5))

# perm test between SAC and SVSP
sac_max <- uof_hs %>%
  select(Institution, Year, Month, uof_per_1000) %>%
  filter(Institution %in% c("SAC", "SVSP")) %>%
  pivot_wider(names_from = Institution, values_from = uof_per_1000) %>%
  mutate(diff = SAC - SVSP)

mean(sac_max$diff)
reps <- 100000
perms <- rep(0, reps)
for(i in 1:reps){
  perms[i] <- mean(sac_max$diff * sample(c(-1, 1), nrow(sac_max), replace = TRUE))
}

sum(perms >= mean(sac_max$diff)) / (reps + 1)

# Plot permutation distribution
data.frame(perm_diff = perms) %>%
  ggplot(aes(x = perm_diff)) +
  geom_density() +
  geom_vline(xintercept = mean(sac_max$diff), col = "red") +
  labs(y = "Density", x = "Difference in average UOF rate between SAC and SVSP", title = "Permutation distribution") +
  theme(plot.title = element_text(hjust = 0.5))
