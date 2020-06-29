#text data handling

#grab relevant libraries
library(dplyr) #pipe / data manipulation
library(tm) #text mining
library(wordcloud) #wordclouds are fun


#Read in the CSVs that were created in slack-export-data-handling.r
users_df <- user_list_df
channels_df <- channel_list
messages_df <- all_channels_all_files_df

#Add channel and user metadata into the all_files dataframe.
all_slack_data <- messages_df %>% left_join(users_df, by = c("user" = "user_id"))
all_slack_data <- all_slack_data %>% left_join(channels_df, by = c("channel" = "name"))

#TODO - text manipulation for different channel participation

#Message counts
all_slack_data %>%
  select(real_name, text) %>%
  group_by(real_name) %>%
  summarize("Number of Messages" = n())

#length of messages
all_slack_data %>%
  select(real_name, text) %>%
  group_by(real_name) %>%
  mutate(avg_char = mean(nchar(text))) %>%
  summarize("Average Length (chars) of Messages" = mean(avg_char))

#wordclouds are fun :)
#establish corpus/term matrix
messageCorpus <- all_slack_data$text %>% VectorSource() %>% VCorpus()

#Clean data
messageCorpus <- messageCorpus %>% tm_map(content_transformer(tolower)) #lowercase
messageCorpus <- messageCorpus %>% tm_map(removeWords, stopwords("english")) #remove stopwords
#messageCorpus <- messageCorpus %>% tm_map(stemDocument) #stemming

#document term matrix
tdm <- messageCorpus %>% TermDocumentMatrix()
#findFreqTerms(dtm,20) #use to find a floor for frequency. Will be higher for longer histories
#Breaking out tdm terms for maximum wordcloud fun
m <- as.matrix(tdm) #coerce to a matrix
v <- sort(rowSums(m),decreasing=T) #sort from most to least frequently used terms, with a freq count
d <- data.frame(word=names(v), freq=v) #coerce back to df

#wordcloud, because why not
wordcloud(d$word,d$freq,c(3,.4),25,random.order=FALSE) #most freq words (4+ freq) plotted first


#What percentage of messages are from each title-holder?

#What does the message frequency look like over time? by user?

#How long has the channel been open?

#Average messages per day?  From each person in each role? 

#What % of messages are threaded?  

#Which users are the most prolific threaders?