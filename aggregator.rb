class RTAggregator
	attr_reader :rts
	
	def initialize()
		@rts = {}
	end

	def on_tweet(tweet)
		# only interested in retweets
		if tweet['retweeted_status']
			orig_id = tweet['retweeted_status']['id']
			
			# only maintain the most recent RT received 
			@rts[orig_id] = tweet
		end
	end

	def delete_older_than window
		@rts.delete_if do |id, tweet| 
			time_ago_ms = (Time.now.to_f * 1000) - tweet['timestamp_ms'].to_i
			time_ago_ms > TIME_WINDOW_MS
		end
	end

	def top_retweets n
		@rts.values
		.map!{|t| 
			t['retweeted_status']['rt_timestamp'] = t["timestamp_ms"].to_i
			t['retweeted_status']
		}
		.sort!{|a,b| b["retweet_count"] <=> a["retweet_count"]}[0...n]
	end
	
	def size
		@rts.size
	end
	
end