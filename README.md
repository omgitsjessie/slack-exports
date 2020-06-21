# slack-exports
Looking at how to manipulate slack text data from Slack's JSON export zip

## Getting your data
From Slack, go to Settings & Administration > Workspace Settings. This will launch Slack's admin page in your browser. In the upper right, choose the "Import/Export Data" button.

![browser button from Admin panel](/images/export_data_button_browser.png)

In the dialog that appears, choose the time frame you're interested in exporting.

![select export timeframe](/images/slack_export_dialog.png)

Slack will send you an email and a notification from SlackBot when your export is ready.

![export is ready](/images/slack_export_ready.png)

Download your file, unzip it, and move the unzipped parent folder into your R working directory.


## Structure of the JSON export
Inspect your JSON files to make sure it's roughly what you are expecting.  For free orgs, note:
* If there are channels that aren't showing up -- it's possible that there are no messages in that channel during the time frame you selected.
* If you choose the pre-selected date options, it will not include exports from the current day
* No private channels or 1:1 messages will be exported -- this will include all public channels
* Note that (for free accounts) exports can only be generated once per hour. So if you fiddle with things or time frames, be prepared to wait until you're eligible to export again.

In the unzipped export folder, you'll see 3 JSON items that are common to all exports, and a folder for each of the channels contained in the export:

![structure of the unzipped export folder](/images/slack_export_structure.png)

Inside each of the channel folders, data is gathered for each day of activity. Missing date JSON files within your date range mean that there was no activity that day.

![structure of a channel's subfolder](/images/channel_folder_structure.png)

Each JSON file represents a day of activity, and the messages will create slightly different structure based on the content of those messages. More information on how Slack structures those JSON files can be found [here](https://api.slack.com/messaging).

## Data Handling
Pull down slack-export-data-handling.r -- all you'll need is the name of the unzipped parent folder that you've put into your working directory.  Plug that in, and that .r file will ingest metadata about your workspace channels, and create a dataframe and then export it to CSV that is a easy to parse within R for whatever text parsing analysis you want to do on your Slack history.


### Output File
The output file is a CSV, which will be created in your working directory.
Filename structure will be: <parent folder filename>_<earliest date>_to_<latest date>.csv

### Schema for all messages in a workspace:
If you're operating within R, the df that has this information and is written to CSV is `<all_channels_all_files_df>`

Field | Description | Example
 ------------- | ------------- | -------------
msg_id | identifier for each message | NA (this is a redundant field -- will clean up later)
ts | timestamp, in seconds, that the message was sent | 1543715389.000200
user | obfuscated user ID | UEGCGGY3S
type | message type | message
text | content of the message | gotcha, it's me
reply_count | number of replies in the thread, NA if no thread exists | 1
reply_users_count | number of users who replied to the thread, NA if no thread exists | 3
ts_latest_reply | timestamp of the most recent reply | 1592105418.002100
ts_thread | timestamp of the parent of the thread, if this is a threaded message | 1592103591.002000
parent_user_id | user ID that submitted the parent message of the thread | UEGCN2DJL
channel | slack channel that this message exists in | general

### Schema for channel metadata
..TBD! 

### Schema for user metadata
..TBD!

