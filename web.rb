require 'sinatra/base'
require 'thin'

class RTAggregatorApp < Sinatra::Base
  attr_accessor :aggregator

  def initialize(aggregator, config)
    super()
    @aggregator = aggregator
    @page = config[:page]
    @time_window = config[:time_window]
  end

  configure do
    set :threaded, false
  end

  get '/' do
    @aggregator.delete_older_than @time_window
    tops = @aggregator.top_retweets @page
    erb :index, locals: { tops: tops }
  end
end
