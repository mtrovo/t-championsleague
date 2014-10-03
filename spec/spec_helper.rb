require_relative '../app'
require 'rspec'
require 'mockingbird'

def new_tweet args = {}
	{created_at:"Tue Sep 30 18:18:05 +0000 2014",
	 id:999,
	 id_str:"999",
 	 text:"TEST TWEET",
 	 user: {
 	 	screen_name: 'acme'
 	 }
 	}.merge! args
end

def new_retweet t, targs = {}, rtargs = {}
	{created_at:"Tue Sep 30 18:18:05 +0000 2014",
	 id:157,
	 id_str:"157",
 	 text:"RT " + t[:text],
 	 retweeted_status: t.merge({
 	 	retweet_count: 1
 	 	}).merge(rtargs)
 	}.merge! targs
end

def now_ms 
	(Time.now.to_f * 1000).to_i
end