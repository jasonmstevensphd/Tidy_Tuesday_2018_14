
# Load Libraries ----------------------------------------------------------

library(tidyverse)
library(lubridate)
library(scales)


# Analysis Metadata -------------------------------------------------------

Analyst <- "@JasonMStevens"
Time_of_Analysis <- now(tz = "America/New_York")

# Import Data -------------------------------------------------------------

Troll_Tweets_Global <- list.files(pattern = "*.csv") %>% 
  map_df(~read_csv(.))

class(Troll_Tweets_Global$publish_date) #Date came in as character

# Clean Up the Dataset ----------------------------------------------------

Troll_Tweets_Global <- Troll_Tweets_Global %>%
  separate(publish_date, c("Publish_Date", "Publish_Time"), sep = " ") %>%
  mutate(Publish_Date = as.Date(Publish_Date, format = "%m/%d/%Y")) %>%
  mutate(Publish_Time = as.POSIXct(Publish_Time, format = "%H:%M", tz= "GMT")) %>%
  mutate(Publish_Date = as.POSIXct(Publish_Date)) %>%
  filter(account_category != "Unknown") %>%
  filter(account_category != "Fearmonger") %>%
  filter(Publish_Date > "2015-01-01")

# Visualize the Data ------------------------------------------------------

# Lets look at how the frequency of Tweets vs the various categories flucuated over time

Troll_Days_Plot <- ggplot(Troll_Tweets_Global, aes(x = Publish_Date,
                                                   fill = account_type))+
  facet_wrap(~account_category)+
  geom_histogram(bins = 100)+
  scale_x_datetime(labels = date_format("%Y-%b"), breaks = date_breaks("3 months"))+
  ggtitle("Troll Tweets over Time")+
  labs(x="Date of Publication", y="Counts",
       subtitle = paste("Generated by", Analyst, "on", Time_of_Analysis))+
  theme(axis.text.x = element_text(vjust = 1,
                                   hjust = 1,
                                   size=12,
                                   angle = 60))

Troll_Days_Plot

# Of particular interest is the spike in Tweets by Right Trolls that were categorized at "Right" in August of 2017, coinciding with the "Unite the Right" rally in Charlottesville Virginia.

Troll_Tweets_Aug_2017 <- Troll_Tweets_Global %>%
  filter(Publish_Date < "2017-08-31") %>%
  filter(Publish_Date > "2017-07-15")

Troll_Aug_2017_Plot <- ggplot(Troll_Tweets_Aug_2017, aes(x = Publish_Date,
                                                   fill = account_type))+
  facet_wrap(~account_category)+
  geom_histogram(bins = 100)+
  scale_x_datetime(labels = date_format("%m-%d"), breaks = date_breaks("1 week"))+
  ggtitle("Troll Tweets over August_2017")+
  labs(x="Date of Publication", y="Counts",
       subtitle = paste("Generated by", Analyst, "on", Time_of_Analysis))+
  theme(axis.text.x = element_text(vjust = 1,
                                   hjust = 1,
                                   size=12,
                                   angle = 60))

Troll_Aug_2017_Plot

# A clear spike in activity can be observed during this time. Let's drill down into when these Tweets were posted.

Troll_Tweets_Aug_2017_Right <- Troll_Tweets_Aug_2017 %>%
  filter(account_category == "RightTroll")

Troll_08_17_Times_Plot <- ggplot(Troll_Tweets_Aug_2017_Right,
                                 aes(x = Publish_Time))+
  facet_wrap(~region)+
  geom_density()+
  scale_x_datetime(labels = date_format("%H:%M"),
                   breaks = date_breaks("6 hours"))+
  theme_minimal()+
  ggtitle("Troll Preferred Tweeting Times")

Troll_08_17_Times_Plot

Key_Words <- c("Trump", "Charlottesville", "Confederate", "Statue",
               "Kessler", "Nazi")

Troll_Tweets_Aug_2017_Right[Troll_Tweets_Aug_2017_Right$content %in% Key_Words] <- 1

count(Troll_Tweets_Aug_2017_Right$content == 1)
