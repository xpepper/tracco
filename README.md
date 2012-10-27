trello to google_docs
=====================
Some tools to play with Trello boards and sync them from and to Google Spreadsheets

    cp config.template.yaml config.yml
    
and then fill the correct values in the placeholders in config.yml.
More info on getting the right authorizations from Trello [here](https://trello.com/docs/gettingstarted/index.html#getting-an-application-key/).

Then run bundle to get all the required gems:

    bundle install
    
To get a never-expiring auth to read Trello data of the tracking user you use (e.g. tracking@futur3.it) you need to follow this:
    
    https://trello.com/1/authorize?response_type=token&key=<your_developer_public_key>&return_url=https%3A%2F%2Ftrello.com&callback_method=fragment&scope=read&expiration=never&name=Trello+Effort+Tracker+for+Futur3
    
where _your\_developer\_public\_key_ is your developer key taken from [https://trello.com/1/appKey/generate](https://trello.com/1/appKey/generate)
