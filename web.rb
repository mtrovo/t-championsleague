require 'sinatra/base'
require 'sinatra/handlebars'
require 'thin'


class RTAggregatorApp < Sinatra::Base
  helpers Sinatra::Handlebars

  def initialize aggregator, config
    super()
    @aggregator = aggregator
    @page = config[:page]
  end

  configure do
    set :threaded, false
  end

  get '/' do
    tops = @aggregator.top_retweets @page
    erb :index, locals: {tops: tops}
  end
end
