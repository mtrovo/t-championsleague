require 'em-twitter'
require 'json'
require 'colorize'
require 'chronic_duration'
require 'yaml'
require './aggregator'


CONFIG = YAML.load_file('config.yml')


OPTIONS = {
	:path   => '/1.1/statuses/filter.json',
	:params => { :track => 'championsleague' },
	:oauth  => CONFIG['oauth']
}


def format_colored_tweet t
	rt_secs = t[:rt_timestamp] / 1000
	secs_ago = [Time.now.to_i - rt_secs, 0].max
	text_time_ago = secs_ago == 0 ? 'now': ChronicDuration.output(secs_ago) + ' ago'
	["+#{t[:retweet_count]}".green,
	 "@#{t[:user][:screen_name]}".blue.bold,
	 "#{t[:text]}",
	 "(#{text_time_ago})".yellow].join ' '
end

def run! options
	time_window_ms = ChronicDuration.parse(CONFIG['window_period']) * 1000
	aggr = RTAggregator.new

	EM.run do
		client = EM::Twitter::Client.connect(options)

		client.each do |result|
			json = JSON.parse result, symbolize_names: true
			aggr.on_tweet(json)
		end

		EM.add_periodic_timer(ChronicDuration.parse(CONFIG['refresh_time'])) do
			puts "\e[H\e[2J" 
			
			#clear all old retweeted values 
			aggr.delete_older_than time_window_ms

			aggr.top_retweets(CONFIG['top_retweets']).each_with_index do |t, i|
				puts sprintf('#%02d ', i+1) + format_colored_tweet(t)
			end
		end

		# exception handling on Twitter Streaming API
		client.on_error do |message|
			puts "oops: error: #{message}".red
			exit 1
		end

		client.on_unauthorized do
			puts "oops: unauthorized".red
			exit 1
		end

		client.on_forbidden do
			puts "oops: unauthorized".red
			exit 1
		end

		client.on_not_found do
			puts "oops: not_found".red
			exit 1
		end

		client.on_not_acceptable do
			puts "oops: not_acceptable".red
			exit 1
		end

		client.on_too_long do
			puts "oops: too_long".red
			exit 1
		end

		client.on_range_unacceptable do
			puts "oops: range_unacceptable".red
			exit 1
		end

		client.on_enhance_your_calm do
			puts "oops: enhance_your_calm".red
			exit 1
		end
	end
end

run!(OPTIONS) if __FILE__==$0