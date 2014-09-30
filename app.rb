require 'em-twitter'
require 'json'
require 'colorize'
require 'chronic_duration'
require 'yaml'
require './aggregator'

config = YAML.load_file('config.yml')

options = {
	:path   => '/1.1/statuses/filter.json',
	:params => { :track => 'championsleague' },
	:oauth  => config['oauth']
}

def run!
	time_window_ms = ChronicDuration.parse(config['window_period']) * 1000
	aggr = RTAggregator.new

	EM.run do
		client = EM::Twitter::Client.connect(options)

		client.each do |result|
			json = JSON.parse result
			aggr.on_tweet(json)
		end

		client.on_error do |message|
			puts "oops: error: #{message}"
		end

		EM.add_periodic_timer(1) do
			puts "\e[H\e[2J" 

			#clear all old retweeted values 
			aggr.delete_older_than time_window_ms
			aggr.top_retweets(config['top_retweets'])
			.each do |t|
				rt_secs = t["rt_timestamp"] / 1000
				time_ago = ChronicDuration.output(Time.now.to_i - rt_secs, 
						:keep_zero => true)
				puts [
					"##{t['retweet_count']}".green,
					"@#{t['user']['screen_name']}".blue.bold,
					"#{t['text']}",
					"(#{time_ago} ago)".yellow].join ' '
			end
		end
	end
end

run! if __FILE__==$0