library(rjson) #import and manipulate JSON files
library(dplyr) #data handling / pipe char

#example file that has some odd threaded/rich text examples
testjson_path <- "~/R Projects/slack-exports/exportunzip/general/2020-06-13.json"

#import JSON file as a list
import_day <- fromJSON(file = testjson_path)

#function to convert a single JSON file into a dataframe with specific fields extracted
slack_json_to_dataframe <- function(slack_json) {
  #blank table with correct colnames:
  messages_test <- setNames(data.frame(matrix(ncol = 10, nrow = 0)), 
                            c("msg_id", "ts", "user", "type", "text", "reply_count",
                              "reply_users_count", "ts_latest_reply", "ts_thread", 
                              "parent_user_id"))
  #for each slack message (list item in JSON file), extract relevant fields 
  for (message in 1:length(import_day)) { 
    messages_test[message, "msg_id"] <- import_day[[message]]$client_msg_id
    messages_test[message, "ts"] <- import_day[[message]]$ts
    messages_test[message, "user"] <- import_day[[message]]$user
    messages_test[message, "type"] <- import_day[[message]]$type
    messages_test[message, "text"] <- import_day[[message]]$text
    #Some values only occur for parents or children of threads.
    #this will trigger for all parent messages
    if (is.null(import_day[[message]]$reply_count) == FALSE) { 
      messages_test[message, "reply_count"] <- import_day[[message]]$reply_count
      messages_test[message, "reply_users_count"] <- import_day[[message]]$reply_users_count
      messages_test[message, "ts_latest_reply"] <- import_day[[message]]$latest_reply
    }
    #this will trigger for all child messages
    if (is.null(import_day[[message]]$parent_user_id) == FALSE) { 
      messages_test[message, "ts_thread"] <- import_day[[message]]$thread_ts
      messages_test[message, "parent_user_id"] <- import_day[[message]]$parent_user_id
    }
  }
  
  return(messages_test)
}

#test: This returns the list we expect!
#slack_json_to_dataframe(import_day)

#TODO - how does it handle orphaned threads? or deleted children? 
