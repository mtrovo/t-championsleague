require 'spec_helper'

describe RTAggregator do
  before(:each)  do 
    @aggr = RTAggregator.new
  end

  context 'when initialized' do
    it "has size 0" do
      expect(@aggr.size).to eq(0)
    end
    
    it 'delete no rts' do
      expect{@aggr.delete_older_than 99999}
        .not_to change{@aggr.rts.size} 
    end
    
    it 'should have empty top_retweets' do
      expect(@aggr.top_retweets(99)).to be_empty
    end
  end

  context 'when new tweet received' do
    it 'ignores tweet with no RT info' do

      expect{@aggr.on_tweet new_tweet}.not_to change{@aggr.rts.size}
    end
  end
end