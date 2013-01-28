[![Build Status](https://secure.travis-ci.org/xpepper/trello_effort_tracker.png)](http://travis-ci.org/xpepper/trello_effort_tracker)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/xpepper/trello_effort_tracker)

# Trello Effort Tracker

## What is Trello Effort Tracker?
The purpose of this tool is to extract and track estimates and actual efforts on Trello cards.
You just have to notify all of your estimates and efforts tracked on your Trello cards using a conventional format.
This tool will extract and store these estimates and actual efforts to let you extract useful key metrics (e.g. estimate errors, remaining efforts, pair programming frequencies, and so on).

## Why Trello Effort Tracker?
Trello is a very good surrogate for a physical team board: it's simple and effective, and it can really help when you have a distributed team.
That said, Trello does not (still) offer a way to track time estimated and actually spent on cards, though many people [ask for that feature](https://trello.com/card/time-tracking/4d5ea62fd76aa1136000000c/1054) on Trello's development board.

We had the need to add time tracking to Trello, so we define a simple convention to track estimates and efforts on cards: we use a predefined board member (let's call him 'tracking user') which we sent special notifications to (we call them 'tracking notifications').
This 'tracking user' will then receives estimates and efforts notifications, and this library will collect them and save on a persistent storage, using a domain model which adds features related to time tracking (e.g. estimate errors).
A web app is also available to have a proper presentations of card estimates and efforts.

## More details
All you need to have to start using Trello Effort Tracker is a Trello account, a Trello board and a board member to use as 'tracking user'.
Moreover, you'll have to setup the library so that it has all the needed privileges to fetch all the notifications of the 'tracking user'.

The Trello API is used to read data from the team board, so all you need to access is your developer key.
Trello Effort Tracker uses the awesome [Trello API Ruby wrapper](https://github.com/jeremytregunna/ruby-trello) for this purpose.

## Installation

```
# gem install trello_effort_tracker
```

Full Disclosure: This library is still work-in-progress, so if you find anything missing or not functioning as you expect it to, please [open an issue on github](https://github.com/xpepper/trello_effort_tracker/issues).

## Requirements
* [mongoDB](http://www.mongodb.org/) - mac users with homebrew will just run 'brew install mongodb' to have mongoDB installed on their machine.
* [rvm](https://rvm.io/rvm/install/) (optional)

## Setup
Copy the config template

```shell
cp config/config.template.yaml config/config.yml
```

and then fill the correct values in the placeholders in config.yml (see _"Where do I get an API key and API secret?"_ section).

Then copy the mongoid config template

```shell
cp config/mongoid.template.yaml config/mongoid.yml
```

and fill the correct values for the mongodb environments ([see here](http://mongoid.org/en/mongoid/docs/installation.html#configuration) to have more details).

Then run bundle to get all the required gems:

```shell
bundle install
```

### Where do I get an API key?
Log in as a Trello user and visit [https://trello.com/1/appKey/generate](https://trello.com/1/appKey/generate) to get your developer\_public\_key.

### Where do I get an API Access Token Key?
You will need an access token to use ruby-trello, which trello tracker depends on. To get it, you'll need to go to this URL:

    https://trello.com/1/connect?key=<YOUR_DEVELOPER_PUBLIC_KEY>&name=Trello+Effort+Tracker&response_type=token&scope=read,write&expiration=never

At the end of this process, You'll be told to give some key to the app, this is what you want to put in the access\_token\_key yml prop file.

## Usage
The best way is to use one of the rake task defined, e.g.

```ruby
rake 'run:today[test]' # will extract today's tracked data and store on the test db

rake run:today  # will extract today's tracked data  and store on the default (that is development) db

rake 'run:from_day[2012-11-1, production]'  # will extract tracked data starting from November the 1st, 2012 and store them into the production db
```

Or you may just create a TrelloTracker instance and execute its track method.

```ruby
tracker = TrelloTracker.new
tracker.track
```
You can set the Trello's auth params in three ways

* setting the three auth params via environment variables (ENV object)
* using the config.yml (which remains the default mode)
* passing into the constructor a hash containing the auth values, e.g.

```ruby
tracker = TrelloTracker.new(
 "developer_public_key" => "487635b55e6fe9021902fa763b4d101a",
 "access_token_key" => "33bed56f2a12a49c9ba1c2d6ad3e2002e11a34358c3f3fe260d7fba746a06203")

tracker.track
```
### Console
You can open a irb console with the ruby-trello gem and this gem loaded, so that you can query the db or the Trello API and play with them

```ruby
rake console
```

### Storage configuration
Tracking data collected from Trello are stored in a MongoDB, as configured in config/mongoid.yml.
To define which mongodb env is actually used, just set the MONGOID_ENV env variable. Development is the default mongo environment.

### Estimate format convention
To set an estimate on a card, a Trello user should send a notification from that card to the tracker username, e.g.

    @trackinguser [15p]
    @trackinguser [1.5d]
    @trackinguser [12h]

estimates can be given in hours (h), days (d/g) or pomodori (p).

    @trackinguser 22.11.2012 [4h]

will add the estimate (4 hours) in date 22.11.2012.

### Effort format convention
To set an effort in the current day on a card, a Trello user should send a notification from that card to the tracker username, e.g.

    @trackinguser +6p
    @trackinguser +4h
    @trackinguser +0.5g

efforts can be given in hours (h), days (d/g) or pomodori (p).

### Tracking an effort in a specific date
To set an effort in a date different from the notification date, just add a date in the message

    @trackinguser 23.10.2012 +6p

There's even a shortcut for efforts spent yesterday:

    @trackinguser yesterday +6p
    @trackinguser +6p yesterday

### Tracking an effort on more members
By default, the effort is tracked on the member which sends the tracking notification.

To set an effort for more than a Trello user (e.g. pair programming), just add the other user in the message, e.g.

    @trackinguser +3p @alessandrodescovi

To set an effort just for other Trello users (excluding the current user), just include the users in round brackets, e.g.

    @trackinguser +3p (@alessandrodescovi @michelevincenzi)

### Tracking a card as finished (aka DONE)
Sending a tracking notification with the word DONE

    @trackinguser DONE

will mark the card as closed.

## Database import/export
To export the db you can execute something like:

```shell
mongoexport --db trello_effort_tracker_production --collection tracked_cards --out trello_effort_tracker_production.json
```

To reimport that db:

```shell
mongoimport  --db trello_effort_tracker_production --collection tracked_cards --file trello_effort_tracker_production.json
```

## Google Docs exporter
To export all your tracked cards on a google docs named 'my_sheet' in the 'tracking' worksheet, run

```ruby
rake "export:google_docs[my_sheet, tracking, production]"
```
The default env is development.

If you provide no name for the spreadsheet, a default name will be used.
If the spreadsheet name you provide does not exists, it will be created in you google drive account.

So, running simply

```ruby
rake export:google_docs
```
will create (or update) a spreadsheet named "trello effort tracking" using the development db env.

## Keeping your tracking database up to date
You may install a crontab entry to run the trello tracker periodically, for example

```shell
SHELL=/Users/futur3/.rvm/bin/rvm-shell
GEMSET="ruby-1.9.3-p194@spikes"
PROJECT_PATH="/Users/$USER/Documents/workspace/trello_effort_tracker"
LC_ALL=en_US.UTF-8

# m h  dom mon dow   command
*/10 * * * *  rvm-shell $GEMSET -c "cd $PROJECT_PATH;  bundle exec rake run:today[production]" >> /tmp/crontab.out 2>&1
```

## Roadmap and improvements
We develop Trello Effort Tracker using [Trello itself](https://trello.com/board/trello-effort-tracker-roadmap/509c3228dcb1ac3f1c018791).

## Contributing

Several ways you can contribute. Documentation, code, tests, feature requests, bug reports.
To get started, [sign the Contributor License Agreement](http://www.clahub.com/agreements/xpepper/trello_effort_tracker).


Pull requests are welcome :)

[@pierodibello](http://twitter.com/pierodibello)