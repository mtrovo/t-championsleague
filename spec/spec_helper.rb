ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'
require_relative '../app'


RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234

  config.order = 'random'
  config.include Rack::Test::Methods
  config.include Capybara::DSL
end

Capybara.app = RTAggregatorApp.new nil, page: 10, time_window: ChronicDuration.parse('1d') * 1000

Capybara.register_driver :rack_test do |app|
	Capybara::RackTest::Driver.new(app, :headers =>  { 'User-Agent' => 'Capybara' })
end


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