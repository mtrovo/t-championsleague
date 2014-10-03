require 'spec_helper'

describe 'bootstrap code' do
	context 'formating console output' do
		before(:each) do
			@t = new_tweet
			
			@aggr = RTAggregator.new
		end
		
		it 'displays now for recent tweets' do
			rt = new_retweet @t, timestamp_ms: Time.now.to_f * 1000
			@aggr.on_tweet rt
			
			top = @aggr.top_retweets(1).first
			expect(format_colored_tweet top).to end_with '(now)'.yellow
		end

		it 'displays the time ago for olders tweets' do 
			rt = new_retweet @t, timestamp_ms: Time.now.to_f * 1000 - 6e5
			@aggr.on_tweet rt

			top = @aggr.top_retweets(1).first
			expect(format_colored_tweet top).to end_with '(10 mins ago)'.yellow
		end

		it 'contains the number of times the tweet was retweeted' do
			rt = new_retweet @t, {timestamp_ms: Time.now.to_f * 1000 - 6e6},
					retweet_count: 42
			@aggr.on_tweet rt

			top = @aggr.top_retweets(1).first
			expect(format_colored_tweet top).to start_with '+42'.green
		end

		it 'contains the name of the tweet creator' do
			t = new_tweet user:{screen_name:'creator'}
			rt = new_retweet t, timestamp_ms: Time.now.to_f * 1000
			@aggr.on_tweet rt

			expect(format_colored_tweet @aggr.top_retweets(1).first).to include('@creator')
		end

	end
end