------------------------------------------------------------------------

title: "Cyclistic Case Study"

author: "Andy Zheng"

output: pdf_document

------------------------------------------------------------------------

# Cyclistic Case Study

**Introduction:**

In 2016, Cyclistic launched a successful bike-share offering. The bikes can be unlocked from one station and returned to any other station in the system anytime. Since then, the program has grown to a fleet of 5,824 bicycles that are geo-tracked and locked into a network of 692 stations across Chicago. The bikes can be unlocked from one station and returned to any other station in the system anytime. Until now, Cyclistic's marketing strategy relied on building general awareness and appealing to broad consumer segments. One approach that helped make these things possible was the flexibility of its pricing plans: single-ride passes, full-day passes, and annual memberships. Customers who purchase single-ride or full-day passes are referred to as casual riders. Customers who purchase annual memberships are Cyclistic members.

**Scenario:**

Cyclistic's finance analysts have concluded that annual members are much more profitable than casual riders. Although the pricing flexibility helps Cyclistic attract more customers, the company believes that maximizing the number of annual members will be key to future growth. Rather than creating a marketing campaign that targets all-new customers, the company believes there is a very good chance to convert casual riders into members. She notes that casual riders are already aware of the Cyclistic program and have chosen Cyclistic for their mobility needs. Marketing team needs to design marketing strategies aimed at converting casual riders into annual members. In order to do that, however, the marketing analyst team needs to better understand how annual members and casual riders differ.

**Objectives:**

To discover how casual riders and Cyclistic members use their rental bikes differently. Finance analysts have concluded that annual members are more profitable.

-   How do annual members and casual riders use Cyclistic bikes differently?

-   Why would casual riders buy Cyclistic annual memberships?

-   How can Cyclistic use digital media to influence casual riders to become members?

**Business Task:**

The results of this analysis will be used to design a new marketing strategy to aqcuire more subscribers / to convert casual riders to annual members.

**Data Source:**

-   [Motivate International Inc.](https://divvy-tripdata.s3.amazonaws.com/index.html)

**Data Integrity & Credibility:**

-   Data is company internal data, publicly available, and does not contain personal information.

**Tools:**

-   Data cleaning and preparation done in *R*. (too large for excel)
-   Data visualizations made in *R* and *Tableau*.

------------------------------------------------------------------------

# PREPARATION

> Loading packages

```{r}

library(tidyverse)
library(dplyr)
library(ggplot2)
library(lubridate)
library(readxl)
library(janitor)
library(data.table)
library(tidyr)
library(modeest)

```

> Importing 12 .xlsx datasets to R

```{r}

rides2020_04 <- read_xlsx("202004-divvy-tripdata.xlsx")
rides2020_05 <- read_xlsx("202005-divvy-tripdata.xlsx")
rides2020_06 <- read_xlsx("202006-divvy-tripdata.xlsx")
rides2020_07 <- read_xlsx("202007-divvy-tripdata.xlsx")
rides2020_08 <- read_xlsx("202008-divvy-tripdata.xlsx")
rides2020_09 <- read_xlsx("202009-divvy-tripdata.xlsx")
rides2020_10 <- read_xlsx("202010-divvy-tripdata.xlsx")
rides2020_11 <- read_xlsx("202011-divvy-tripdata.xlsx")
rides2020_12 <- read_xlsx("202012-divvy-tripdata.xlsx")
rides2021_01 <- read_xlsx("202101-divvy-tripdata.xlsx")
rides2021_02 <- read_xlsx("202102-divvy-tripdata.xlsx")
rides2021_03 <- read_xlsx("202103-divvy-tripdata.xlsx")

```

> Checking for column name inconsistencies

```{r}

colnames(rides2020_04)
colnames(rides2020_05)
colnames(rides2020_06)
colnames(rides2020_07)
colnames(rides2020_08)
colnames(rides2020_09)
colnames(rides2020_10)
colnames(rides2020_11)
colnames(rides2020_12)
colnames(rides2021_01)
colnames(rides2021_02)
colnames(rides2021_03)
```

    - All columns have same names.

> Getting an overview of the data

```{r}

tibble(rides2020_04)
tibble(rides2020_05)
tibble(rides2020_06)
tibble(rides2020_07)
tibble(rides2020_08)
tibble(rides2020_09)
tibble(rides2020_10)
tibble(rides2020_11)
tibble(rides2020_12)
tibble(rides2021_01)
tibble(rides2021_02)
tibble(rides2021_03)

```

> Mutate (rides2020_12), (rides2021_01), (rides2021_02), (rides2021_03) to be consistent with other datesets; Changing [end_station_id] & [start_station_id] from *chr* changed to *dbl*

```{r}

rides2020_12 <- mutate(rides2020_12,start_station_id = as.double(start_station_id), end_station_id = as.double(end_station_id))
rides2021_01 <- mutate(rides2021_01,start_station_id = as.double(start_station_id), end_station_id = as.double(end_station_id))
rides2021_02 <- mutate(rides2021_02,start_station_id = as.double(start_station_id), end_station_id = as.double(end_station_id))
rides2021_03 <- mutate(rides2021_03,start_station_id = as.double(start_station_id), end_station_id = as.double(end_station_id))

```

> Checking if change took effect

```{r}

is.double(rides2020_12$start_station_id)
is.double(rides2020_12$end_station_id)
is.double(rides2021_01$start_station_id)
is.double(rides2021_01$end_station_id)
is.double(rides2021_02$start_station_id)
is.double(rides2021_02$end_station_id)
is.double(rides2021_03$start_station_id)
is.double(rides2021_03$end_station_id)

```

    - all outputs true

> Merging all data sets April, 2020 - May, 2021 into one dataset (rides_202004_202103)

```{r}

rides_202004_202103 <- bind_rows(rides2020_04, rides2020_05,rides2020_06, rides2020_07, rides2020_08, rides2020_09, rides2020_10, rides2020_11, rides2020_12, rides2021_01, rides2021_02, rides2021_03)

```

> Adding columns for [date], [month], [day], [day_of_week], [year], [ride_length_secs], [ride_length_mins] pulled from columns: [started_at], [ended_at]

```{r}

rides_202004_202103$date <- as.Date(rides_202004_202103$started_at)
rides_202004_202103$month <- format(as.Date(rides_202004_202103$date),"%m")
rides_202004_202103$day <- format(as.Date(rides_202004_202103$date),"%d")
rides_202004_202103$year <- format(as.Date(rides_202004_202103$date),"%Y")
rides_202004_202103$day_of_week <- format(as.Date(rides_202004_202103$date),"%A")
rides_202004_202103$ride_length_secs <- as.numeric(difftime(rides_202004_202103$ended_at,rides_202004_202103$started_at))
rides_202004_202103$ride_length_mins <-as.numeric(rides_202004_202103$ride_length_secs / 60)

```

> Removing rows with N/A, negative values, test rides into new dataset (rides_202004_202103_v2)

```{r}

# rides_202004_202103_v2 <- drop_na(rides_202004_202103)

rides_202004_202103_v2 <- rides_202004_202103[!(rides_202004_202103$ride_length_secs < 0),]
rides_202004_202103_v2 <- rides_202004_202103_v2 [!((rides_202004_202103_v2$start_station_name %like% "TEST" | rides_202004_202103_v2$start_station_name %like% "test")),]

```

    - Rows with N/A make up a significant portion of data \~540,000 rides. Not going to remove these assuming these rides are legitimate and just missing station_id or end_station_id

    - 10552 rows removed (3489748-3479196), negative values make up .30% of (rides_202004_202103_v2)

    - 3352 rows removed (3479196-3475844), test & TEST rides make up .39% of (rides_202004_202103_v2)

> Checking for distinct values in column member_casual, Counting trips by type of rider

```{r}

unique(rides_202004_202103_v2[c("member_casual")])
table(rides_202004_202103_v2$member_casual)

```

    - Only two values found: member (2051968), casual (1423876)

------------------------------------------------------------------------

# ANALYZE

> Summary of fully cleaned dataset (rides_202004_202103_v2)

```{r}

summary(rides_202004_202103_v2)

```

    - Average ride is around 28 minutes

> Summary by member type

```{r}

aggregate(rides_202004_202103_v2$ride_length_mins ~ rides_202004_202103_v2$member_casual, FUN = mean)
aggregate(rides_202004_202103_v2$ride_length_mins ~ rides_202004_202103_v2$member_casual, FUN = median)

rides_202004_202103_v2 %>%
  group_by(member_casual) %>%
  summarise(min_ride_length_mins= min(ride_length_mins),max_ride_length_mins = max(ride_length_mins),
            median_ride_length_mins = median(ride_length_mins), mean_ride_length_mins = mean(ride_length_mins))

```

    - Average casual ride is ~45 minutes. Average member ride is ~16 minutes.

    - Casual riders spend more than double the time per ride when compared to member riders. Casual riders also spend on average more time per ride than average of all rides (28 minutes) while member riders spend less time.

> Determining mode, what days are the most busy?

```{r}

aggregate(rides_202004_202103_v2$day_of_week ~ rides_202004_202103_v2$member_casual, FUN = mfv)

rides_202004_202103_v2 %>% 
  group_by(member_casual, day_of_week) %>%  
  summarise(number_of_rides = n(),average_ride_length_mins = mean(ride_length_mins)) %>% 
  arrange(member_casual, desc(number_of_rides))

```

    - Saturday has the most rides for both members and casuals. For both casual riders and member riders, there was more activity on weekends; more rides and longer rides.

------------------------------------------------------------------------

# SHARE / VISUALIZATIONS

> Ride Percentage by Customer Type

```{r}

member_vs_casual_rides <- rides_202004_202103_v2 %>%
  group_by(member_casual) %>%
  summarize(number_of_rides = n()) %>%
  arrange(member_casual) %>%
  mutate(percent = number_of_rides/sum(number_of_rides*1)) %>%
  ggplot(aes(x="", y = number_of_rides, fill = member_casual)) +
  geom_bar(stat="identity", width=1) + coord_polar("y", start=0) +
  geom_text(aes(label = scales::percent(round(percent,3))), position = position_stack(vjust = 0.5))

member_vs_casual_rides +
  labs(title = "Ride Percentage by Customer Type") +
  labs(fill = 'Customer Type') +
  theme_void() 

```

> Average Number of Rides by Day of Week & Rider Type

```{r}

avg_week <- rides_202004_202103_v2 %>% 
  select(-day, -month) %>%
  group_by(day_of_week, member_casual) %>%
  summarise(number_of_riders = length(rideable_type))

avg_day <- rides_202004_202103_v2 %>%
  distinct(day ,day_of_week)%>%
  group_by(day_of_week) %>%
  summarise(number_of_riders_day=length(day))

avg_week <-merge(avg_week,avg_day,by="day_of_week") %>%
  mutate(ave_rider_count_week=number_of_riders/number_of_riders_day,.keep="unused")

avg_week_plot <- avg_week %>%
  mutate(day_of_week=factor(day_of_week, levels=c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"))) %>% 
  ggplot(aes(x= day_of_week,y=ave_rider_count_week,fill=member_casual, width=0.5)) +
  geom_col(color = "Black", position="dodge", stat="identity")

avg_week_plot + labs(title ="Average Number of Rides by Day of Week & Rider Type", x ="Day of Week", y ="Average Number of Riders", fill ="Customer Type")

```

> Number of Ride by Day of Week & Rider Type

```{r}

rides_202004_202103_v2 %>% 
  group_by(member_casual, day_of_week) %>% 
  summarise(number_of_rides = n()) %>% 
  arrange(member_casual, day_of_week)  %>% 
  ggplot(aes(x = day_of_week, y = number_of_rides, fill = member_casual)) +
  geom_col(color = "Black", width=0.5, position = position_dodge(width=0.5)) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  labs(title = "Number of Rides by Day & Rider Type") + 
  ylab("Number of Rides") + 
  xlab("Day of Week") +
  labs(fill = 'Customer Type')

```

> Number of Rides by Month & Rider Type (BAR)

```{r}

rides_202004_202103_v2 %>%  
  group_by(member_casual, month) %>% 
  summarise(number_of_rides = n()) %>% 
  arrange(member_casual, month)  %>% 
  ggplot(aes(x = month, y = number_of_rides, fill = member_casual)) +
  labs(title ="Number of Rides by Month & Rider Type (BAR) ") +
  geom_col(color = "Black", width=0.5, position = position_dodge(width=0.5)) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  ylab("Number of Rides") + 
  xlab("Month") +
  labs(fill = 'Customer Type')

```

> Number of Rides by Month & Rider Type (LINE)

```{r}

avg_month_rides <- rides_202004_202103_v2 %>% 
  group_by(member_casual, month) %>% 
  summarize(number_of_rides = n_distinct(ride_id), .groups = 'drop')

ggplot(data = avg_month_rides) +
  geom_line(mapping = aes(x = month, y = number_of_rides, color = member_casual, group = member_casual)) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  labs(title ="Number of Rides by Month & Rider Type (LINE) ") +
  ylab("Number of Rides") + 
  xlab("Month") +
  scale_color_discrete("Customer Type")

```

> Average Ride Length by Rider Type & Week

```{r}

rides_202004_202103_v2 %>%  
  group_by(member_casual, day_of_week) %>% 
  summarise(avg_ride_length = mean(ride_length_mins)) %>%
  ggplot(aes(x = day_of_week, y = avg_ride_length, fill = member_casual)) +
  geom_col(color = "Black", width=0.5, position = position_dodge(width=0.5)) + 
  labs(title ="Average Ride Length by Rider Type & Week") +
  ylab("Average Ride Length") + 
  xlab("Day of Week") +
  labs(fill = 'Customer Type')

```

> Average Ride Length by Rider Type & Month

```{r}

rides_202004_202103_v2 %>%  
  group_by(member_casual, month) %>% 
  summarise(avg_ride_length = mean(ride_length_mins)) %>%
  ggplot(aes(x = month, y = avg_ride_length, fill = member_casual)) +
  geom_col(color = "Black", width=0.5, position = position_dodge(width=0.5)) + 
  labs(title ="Average Ride Length by Rider Type & Month") +
  ylab("Average Ride Length") + 
  xlab("Month") +
  labs(fill = 'Customer Type')

```

> Ride type vs number trips

```{r}

rides_202004_202103_v2 %>%
  group_by(rideable_type, member_casual) %>%
  summarise(number_of_trips = n()) %>%  
  ggplot(aes(x = rideable_type, y = number_of_trips, fill = member_casual))+
  geom_bar(color = "Black", stat ='identity') +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  labs(title ="Ride type Vs. Number of trips") +
  ylab("Number of Trips") + 
  xlab("Ride Type") +
  labs(fill = 'Customer Type')

```

------------------------------------------------------------------------

# FINDINGS

**How do casual riders and Cyclistic members use their rental bikes differently?**

Based on 12 months of data from April, 2020 to March, 2021:

-   Members make up ~59% of all rides while casual riders make up ~41% of all rides.

-   The docked bike option is far more popular than both classic bikes and electric bikes for both casual riders and members.

-   Throughout the year, there are always consistently more riders than casual riders with peak traffic from July to September.

-   Members of Cyclistic are much more consistent with riding throughout the week, especially on weekdays based on trip duration and number of rides.

-   Casual riders on the other hand prefer the weekend and have a large range for trip duration.

-   On average, each bike trip takes 30 minutes. Casual members on average ride much longer(46 minutes) than members(16 minutes) per trip - nearly twice as much.

-   It could be that members primarily use bikes for regular / scheduled commutes while casual riders are may use bikes for leisure and are more spontaneous. Additionally, members may have more consistently direct routes while casual riders may get lost or take detours.

------------------------------------------------------------------------

# RECOMMENDATIONS

**Based on our findings, how can Cyclistic acquire more subscribers / convert casual riders to annual members?**

-   Create incentive for casual riders to ride more on weekdays such as a promotion or discount throughout work/school days(Monday - Friday).

-   Consider alternative membership options for casual riders; perhaps a membership just for the weekend.

-   Focus advertising for casual riders to expose them to more weekday riding.

-   Run more campaigns during the summer when ridership is at it's highest.

-   Setup a system or provide a guide for casual riders to help them to their destinations.

-   Setup more hotspots in popular detour locations to be more efficient or improve traffic.
