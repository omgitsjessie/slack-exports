library(rjson) #import and manipulate JSON files
library(dplyr) #data handling / pipe char

#example file that has some odd threaded/rich text examples
slackexport_folder_path <- "~/R Projects/slack-exports/exportunzip"
testjson_path <- paste0(slackexport_folder_path,"/general/2020-06-13.json")

#Make a list of all channels present in the slack export
#This information is all in the "<path>/exportname/channels.json" file
channels_path <- paste0(slackexport_folder_path,"/channels.json")
channels_json <- fromJSON(file = channels_path)
channel_list <- setNames(data.frame(matrix(ncol = 9, nrow = 0)), 
                          c("ch_id", "name", "created", "creator", "is_archived",
                            "is_general", "members", "topic", "purpose"))

#For each channel make a list of all the individual JSON files (one file per day of activity)
#Add that list to the channels_json object as a list in each channel: channels_json[[channel]]$dayslist
channel_folder_path <- ""
for (channel in 1:length(channels_json)) {
  channels_json[[channel]]$dayslist <- ""
  channel_folder_path <- paste0(slackexport_folder_path,"/",channel_list[channel,"name"])
  channels_json[[channel]]$dayslist <- list.files(channel_folder_path, 
                                                  pattern=NULL, all.files=FALSE, full.names=FALSE)
}

#Make a df (channel_list) with information about each channel, from the JSON file
for (channel in 1:length(channels_json)) { 
  channel_list[channel, "ch_id"] <- channels_json[[channel]]$id
  channel_list[channel, "name"] <- channels_json[[channel]]$name
  channel_list[channel, "created"] <- channels_json[[channel]]$created
  channel_list[channel, "creator"] <- channels_json[[channel]]$creator
  channel_list[channel, "is_archived"] <- channels_json[[channel]]$is_archived
  channel_list[channel, "is_general"] <- channels_json[[channel]]$is_general
  #make a comma separated list of members
    memberlist <- ""
    for(member in 1:length(channels_json[[channel]]$members)) {
      #if it isn't the last member
      if(member < length(channels_json[[channel]]$members)) {
        memberlist <- paste0(memberlist, channels_json[[channel]]$members[[member]], ", ")
      }
      if(member == length(channels_json[[channel]]$members)) {
        memberlist <- paste0(memberlist, channels_json[[channel]]$members[[member]])
      }
      
    }
  channel_list[channel, "members"] <- memberlist
  channel_list[channel, "topic"] <- channels_json[[channel]]$topic$value
  channel_list[channel, "purpose"] <- channels_json[[channel]]$purpose$value
}

#TODO: For each channel, for each day of activity:
  #import each JSON file, 
  #convert it to a df with desired fields extracted (PLUS channel name)
  #and rbind ALL of those dfs to the same giant df

#import JSON file as a list
import_day <- fromJSON(file = testjson_path)

#function to convert a single JSON file into a dataframe with specific fields extracted
slack_json_to_dataframe <- function(slack_json) {
  #blank table with correct colnames:
  messages_df <- setNames(data.frame(matrix(ncol = 10, nrow = 0)), 
                            c("msg_id", "ts", "user", "type", "text", "reply_count",
                              "reply_users_count", "ts_latest_reply", "ts_thread", 
                              "parent_user_id"))
  #for each slack message (list item in JSON file), extract relevant fields 
  for (message in 1:length(import_day)) { 
    messages_df[message, "msg_id"] <- import_day[[message]]$client_msg_id
    messages_df[message, "ts"] <- import_day[[message]]$ts
    messages_df[message, "user"] <- import_day[[message]]$user
    messages_df[message, "type"] <- import_day[[message]]$type
    messages_df[message, "text"] <- import_day[[message]]$text
    #Some values only occur for parents or children of threads.
    #this will trigger for all parent messages
    if (is.null(import_day[[message]]$reply_count) == FALSE) { 
      messages_df[message, "reply_count"] <- import_day[[message]]$reply_count
      messages_df[message, "reply_users_count"] <- import_day[[message]]$reply_users_count
      messages_df[message, "ts_latest_reply"] <- import_day[[message]]$latest_reply
    }
    #this will trigger for all child messages
    if (is.null(import_day[[message]]$parent_user_id) == FALSE) { 
      messages_df[message, "ts_thread"] <- import_day[[message]]$thread_ts
      messages_df[message, "parent_user_id"] <- import_day[[message]]$parent_user_id
    }
  }
  
  return(messages_df)
}

#test: This returns the list we expect!
#slack_json_to_dataframe(import_day)

#TODO - Run slack_json_to_dataframe() on all individual files in a channel (1 file / channel / day), and bind them into a single df


#TODO - how does it handle orphaned threads? or deleted children? 
