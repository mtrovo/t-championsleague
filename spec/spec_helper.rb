require_relative '../app'
require 'rspec'
require 'mockingbird'

def new_tweet
	{"created_at"=>"Tue Sep 30 18:18:05 +0000 2014",
	 "id"=>999,
	 "id_str"=>"999",
 	 "text"=>"TEST TWEET"
 	}.merge! args
end

def new_retweet t, targs, rtargs
	{"created_at"=>"Tue Sep 30 18:18:05 +0000 2014",
	 "id"=>157,
	 "id_str"=>"157",
 	 "text"=>"RT " + t['text'],
 	 "retweeted_status" => t.merge({
 	 	"retweet_count": 1
 	 	}).merge rtargs
 	}.merge! targs
end
