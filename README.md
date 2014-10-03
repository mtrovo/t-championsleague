# t-championsleague
Sample UEFA Champions League retweets tracking application

## About
Tracks all retweets for specific keywords (currently only 'championsleague') and display them to the console window.
Inside it uses EventMachine to handle the multiple actions dispatching.

## Usage
Put a valid twitter OAuth credentials inside the `config.yml` file.
```
oauth:
    :consumer_key: [consumer key]
    :consumer_secret: [consumer secret]
    :token: [access token]
    :token_secret: [access secret]
```

Install all the gems dependencies using:
```
    bundle install
```

And run the application using the following command:
```
	ruby app.rb
```
