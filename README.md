[![Build Status](https://secure.travis-ci.org/xpepper/tracco.png)](http://travis-ci.org/xpepper/tracco)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/xpepper/tracco)

# Tracco

## What is Tracco?
Tracco is an effort tracker for Trello: the purpose of Tracco is to extract and track estimates and actual efforts out of the cards on your Trello boards.
All you have to do is notify all of your estimates and efforts tracked on your Trello cards using a simple conventional format.
Tracco will extract and store these estimates and actual efforts to let you mine useful key metrics (e.g. estimate errors, remaining efforts, pair programming frequencies, and so on).

## Why Tracco?
Trello is a very good surrogate for a physical team board: it's simple and effective, and it can really help when you have a distributed team.
That said, Trello does not (still) offer a way to track time estimated and actually spent on cards, though many people [ask for that feature](https://trello.com/card/time-tracking/4d5ea62fd76aa1136000000c/1054) on Trello's development board.

Having that precise need, we defined a simple convention to track estimates and efforts on cards: we use a predefined board member (let's call him 'tracking user') which we sent special notifications to (we call them 'tracking notifications').
This 'tracking user' will then receives estimates and efforts notifications, and Tracco will collect and store them.
Moreover, a web app will be soon available to properly present card estimates and efforts (we're working on it).

## More details
All you need to have to start using Tracco is a Trello account, a Trello board and a board member to use as 'tracking user'.
You'll also need to know your Trello developer key and generate a proper auth token to have access to the trackinguser's notifications.
To see how to have these two keys, see [the following section](#api_key).

The Trello API is used behind the scenes to read data from the team board. Tracco uses the awesome [Trello API Ruby wrapper](https://github.com/jeremytregunna/ruby-trello) for this purpose.

## Usage
This tool can be used as a standalone gem or cloning this git repo.

### Installation as a ruby gem

```shell
gem install tracco
```

### Installation cloning the repo

```shell
git clone git://github.com/xpepper/tracco.git
```

Then cd in the cloned repo and copy the config template

```shell
cd tracco
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


Full Disclosure: this library is still work-in-progress, so if you find anything missing or not functioning as you expect it to, please [open an issue on github](https://github.com/xpepper/tracco/issues).

## Requirements
* [mongoDB](http://www.mongodb.org/) - macosx users with homebrew will just run 'brew install mongodb' to have mongoDB installed on their machine.
* (optional) [rvm](https://rvm.io/rvm/install/) is useful (but optional) for development



### <a id="api_key"></a>Where do I get an API key?
Log in to Trello with your account and visit [https://trello.com/1/appKey/generate](https://trello.com/1/appKey/generate) to get your developer\_public\_key.

### Where do I get an API Access Token Key?
To generate a proper access token key, log in to Trello with the 'tracking user' account. Then go to this URL:

    https://trello.com/1/connect?key=<YOUR_DEVELOPER_PUBLIC_KEY>&name=Trello+Effort+Tracker&response_type=token&scope=read,write&expiration=never

At the end of this process, you'll receive a valid access\_token\_key, which is needed by Tracco to fetch all the tracking notifications sent to the 'tracking user'.

## Usage
The best way is to use one of the rake task defined, e.g.

```ruby
rake 'run:today[test]' # will extract today's tracked data and store on the test db

rake run:today  # will extract today's tracked data and store on the default (that is development) db

rake 'run:from_day[2012-11-1, production]'  # will extract tracked data starting from November the 1st, 2012 and store them into the production db
```

Or you may just create a TrelloTracker instance and execute its track method.

```ruby
require 'tracco'

tracker = Tracco::TrelloTracker.new
tracker.track
```

## Configuration params
### Mongo storage configuration
Tracking data collected from Trello are stored in a MongoDB database.

There are two env variables you can set to configure mongodb

- `MONGOID_ENV` defines which mongodb env is actually used (development, test, production). Development is the default mongo environment.
- `MONGOID_CONFIG_PATH` defines the path to the mongoid configuration file (default is `config/mongoid.yml`)

A standard mongoid.yml is the following:

```yml
development:
  sessions:
    default:
      database: tracco_dev
      hosts:
        - localhost:27017
test:
  sessions:
    default:
      database: tracco_test
      hosts:
        - localhost:27017
production:
  autocreate_indexes: true
  persist_in_safe_mode: true

  sessions:
    default:
      database: tracco_production
      hosts:
        - localhost:27017
```

#### Trello configuration params
You can set the Trello's configuration params in three ways.
Through the following environment variables (ENV object):

```
  access_token_key
  developer_public_key
  tracker_username
```

Passing into the constructor a hash containing the auth values:

```ruby
tracker = Tracco::TrelloTracker.new(
 developer_public_key: "487635b55e6fe9021902fa763b4d101a",
 access_token_key: "33bed56f2a12a49c9ba1c2d6ad3e2002e11a34358c3f3fe260d7fba746a06203",
 tracker_username: "my_personal_tracker")

tracker.track
```

Or using the config.yml (which is the actual fallback mode, useful in development mode).

### Console
You can open a irb console with the ruby-trello gem and this gem loaded, so that you can query the db or the Trello API and play with them

```ruby
rake console
```

The default env is development. To load a console in the (e.g.) production db env, execute:

```ruby
rake "console[production]"
```

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

Moreover, a card moved into a DONE column (the name of the Trello list contains the word "Done") is automatically marked as done.

## Database import/export
To export the db you can execute something like:

```shell
mongoexport --db tracco_production --collection tracked_cards --out tracco_production.json
```

To reimport that db:

```shell
mongoimport  --db tracco_production --collection tracked_cards --file tracco_production.json
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
GEMSET="ruby-1.9.3-p385@spikes"
PROJECT_PATH="/Users/$USER/Documents/workspace/tracco"
LC_ALL=en_US.UTF-8

# m h  dom mon dow   command
*/10 * * * *  rvm-shell $GEMSET -c "cd $PROJECT_PATH;  bundle exec rake run:today[production]" >> /tmp/crontab.out 2>&1
```

## Roadmap and improvements
We develop Tracco using [Trello itself](https://trello.com/board/trello-effort-tracker-roadmap/509c3228dcb1ac3f1c018791).

## Contributing
To get started, [sign the Contributor License Agreement](http://www.clahub.com/agreements/xpepper/tracco).

If you'd like to hack on Tracco, start by forking the repo on GitHub:

https://github.com/xpepper/tracco

The best way to get your changes merged back into core is as follows:

1. Clone down your fork
1. Create a thoughtfully named topic branch to contain your change
1. Hack away
1. Add tests and make sure everything still passes by running `rake spec`
1. If you are adding new functionality, document it in the README
1. Do not change the version number, we will do that on our end
1. If necessary, rebase your commits into logical chunks, without errors
1. Push the branch up to GitHub
1. Send a pull request for your branch

[@pierodibello](http://twitter.com/pierodibello)
