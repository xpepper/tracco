# TrelloEffortTracker
The purpose of this tool is to extract and track estimates and actual efforts on Trello cards.

The Trello API is used in readonly mode in this code, so all you need to access is your developer key.
TrelloTracker uses the [Trello API Ruby wrapper](https://github.com/jeremytregunna/ruby-trello) for this purpose.

## Setup
Copy the config template

    cp config/config.template.yaml config/config.yml

and then fill the correct values in the placeholders in config.yml (see _"Where do I get an API key and API secret?"_ section).

Then run bundle to get all the required gems:

    bundle install

### Where do I get an API key and API secret?
Log in as a Trello user and visit [this URL](https://trello.com/1/appKey/generate) to get your developer\_public\_key and the developer\_public\_key.

### Where do I get an API Access Token Key?
You will need an access token to use ruby-trello, which trello tracker depends on. To get it, you'll need to go to this URL:

    https://trello.com/1/connect?key=<YOUR_DEVELOPER_PUBLIC_KEY>&name=name=Trello+Effort+Tracker&response_type=token&scope=read,write&expiration=never

At the end of this process, You'll be told to give some key to the app, this is what you want to put in the access\_token\_key yml prop file.

## Usage
Just create a TrelloTracker instance and execute its track method.

    tracker = TrelloTracker.new
    tracker.track

You can set the Trello's auth params in three ways

* setting the three auth params via environment variables (ENV object)
* using the config.yml
* passing into the constructor a hash containing the auth values, e.g.

        tracker = TrelloTracker.new(
         "developer_public_key" => "487635b55e6fe9021902fa763b4d101a",
         "access_token_key" => "33bed56f2a12a49c9ba1c2d6ad3e2002e11a34358c3f3fe260d7fba746a06203",
         "developer_secret" => "ab999c4396493dba4c04ade055eabfdfabdffd0ffd7c281a23234350a993524d")

        tracker.track


### Estimate format convention
To set an estimate on a card, a Trello user should send a notification from that card to the tracker username, e.g.

    @trackinguser [15p]
    @trackinguser [1.5d]
    @trackinguser [12h]

estimates can be given in hours (h), days (d/g) or pomodori (p).

### Effort format convention
To set an effort in the current day on a card, a Trello user should send a notification from that card to the tracker username, e.g.

    @trackinguser +6p
    @trackinguser +4h
    @trackinguser +0.5g

efforts can be given in hours (h), days (d/g) or pomodori (p).

### Tracking an effort in a specific date
To set an effort in a date different from the notification date, just add a date in the message

    @trackinguser 23.10.2012 +6p

### Tracking an effort on more members
By default, the effort is tracked on the member which sends the tracking notification.

To set an effort for more than a Trello user (e.g. pair programming), just add the other user in the message, e.g.

    @trackinguser +3p @alessandrodescovi

To set an effort just for other Trello users (excluding the current user), just include the users in round brackets, e.g.

    @trackinguser +3p (@alessandrodescovi @michelevincenzi)

## TODO and Roadmap
* Add logging (https://github.com/TwP/logging ?)
* A card should be able to tell its total effort
* CSV export (FasterCSV?)
* Google Docs export
* Store tracking info somewhere
* Computing key tracking metrics (e.g. estimate error)


## Pull Requests

Pull requests are welcome :)

[@pierodibello](http://twitter.com/pierodibello)