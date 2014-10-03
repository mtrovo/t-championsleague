# Class that aggregates all RT data populated to it by the on_tweet method
class RTAggregator
	attr_reader :rts

	def initialize()
		@rts = {}
	end

	# Add tweet to this aggregator.
	# It's discarted if it doesn't contain retweet information.
	# It overrides existing retweets with the same original id.
	def on_tweet(tweet)
		# only interested in retweets
		if tweet[:retweeted_status]
			orig_id = tweet[:retweeted_status][:id]
			tweet[:timestamp_ms] = tweet[:timestamp_ms].to_i
			
			# only maintain the most recent RT received 
			@rts[orig_id] = tweet
		end
	end

	def delete_older_than window
		@rts.delete_if do |id, tweet| 
			# how old is the post in millis 
			time_ago_ms = (Time.now.to_f * 1000) - tweet[:timestamp_ms]
			time_ago_ms > window
		end
	end

	def top_retweets n
		@rts.values
		.map!{|t| 
			# creates a field to contain the creation timestamp of the RT 
			t[:retweeted_status][:rt_timestamp] = t[:timestamp_ms]
			t[:retweeted_status]
		}
		.sort!{|a,b| b[:retweet_count] <=> a[:retweet_count]}[0...n]
	end
	
	def size
		@rts.size
	end
	
end