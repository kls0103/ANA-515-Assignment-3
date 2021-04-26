#importing my csv file into R
read.csv(file='Storm events 1993.csv')

#naming my csv file storm events
stormevents <- read.csv(file='Storm events 1993.csv')

#checking mu current column names
names(stormevents)

#limiting my dataframe to specified columns from the directions for assignment 3
myvars <- c("BEGIN_DATE_TIME","END_DATE_TIME","EPISODE_ID","EVENT_ID","STATE","STATE_FIPS","CZ_NAME","CZ_TYPE","CZ_FIPS","EVENT_TYPE","SOURCE","BEGIN_LAT","BEGIN_LON","END_LAT","END_LON")
limitedstormevents <- stormevents[myvars]

#checking to make sure I have all of the specified columns
names(limitedstormevents)

#date and time formatting
#This is producing an error message, but I am leaving the code in for now while working on a fix
install.packages("lubridate")
library(dplyr)
library(lubridate)
library(tidyverse)
mutate(limitedstormevents,BEGIN_DATE_TIME=dmy_hms(BEGIN_DATE_TIME), 
       END_DATE_TIME=dmy_hms(END_DATE_TIME))

#change state and county names to title case
limitedstormevents$STATE = str_to_title(limitedstormevents$STATE)
limitedstormevents$CZ_NAME = str_to_title(limitedstormevents$CZ_NAME)

#Limit to the events listed by the county type of C and remove CZ_Type
filter(limitedstormevents, CZ_TYPE == "C")
select(limitedstormevents, -CZ_TYPE)

#Pad the state and county FIPS with a 0 at the beginning and then unite the two columns
str_pad(limitedstormevents$STATE_FIPS, width=3, side="left", pad="0")
str_pad(limitedstormevents$CZ_FIPS, width=4, side="left", pad="0")
unite(limitedstormevents, "fips", c("STATE_FIPS","CZ_FIPS"))

#change all the column names to lower case
rename_all(limitedstormevents, tolower)

#use the state data  from R to create a new data frame with the state name, region, and area
stateinfo<-data.frame(state=state.name, region=state.region, area=state.area)

#create a dataframe with the number of events per states in the year of my birth and merge it with the stateinfo dataframe
statefreq <- data.frame(table(limitedstormevents$STATE))
str_to_title(statefreq$Var1)
newstatefreq <- rename(statefreq, c("state"="Var1"))
newstatefreq$state = str_to_title(newstatefreq$state)
mergedstatetable <- merge(x=newstatefreq,y=stateinfo,by.x="state",by.y="state")

#creating a plot
library(ggplot2)
stormplot <- ggplot(mergedstatetable, aes(x = area, y = Freq,)) + 
  geom_point(aes(color = region)) + 
  labs(x = "Land area (square miles)",
       y = "# of storms in 1993" )
print(stormplot)
