## TrelloTracker
The purpose of this tool is to extract and track estimates and actual efforts on Trello cards.

This project contains also some (very alpha) scripts to play with Trello boards and sync them from and to Google Spreadsheets.

The Trello API is used in readonly mode in this code, so all you need to access is your developer key.
TrelloTracker uses the [Trello API Ruby wrapper](https://github.com/jeremytregunna/ruby-trello) for this purpose.

### Setup
Copy the config template

    cp config/config.template.yaml config/config.yml

and then fill the correct values in the placeholders in config.yml (see _"Where do I get an API key and API secret?"_ section).

Then run bundle to get all the required gems:

    bundle install

### Where do I get an API key and API secret?
Log in as a Trello user and visit [this URL](https://trello.com/1/appKey/generate) to get your developer\_public\_key and the developer\_public\_key.

## Where do I get an API Access Token Key?
You will need an access token to use ruby-trello, which trello tracker depends on. To get it, you'll need to go to this URL:

    https://trello.com/1/connect?key=<YOUR_DEVELOPER_PUBLIC_KEY>&name=name=Trello+Effort+Tracker&response_type=token&scope=read,write&expiration=never

At the end of this process, You'll be told to give some key to the app, this is what you want to put in the access\_token\_key yml prop file.

## Issues


## Pull Requests

Pull requests are welcome :)

[@pierodibello](http://twitter.com/pierodibello)