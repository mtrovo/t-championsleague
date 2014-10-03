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
    before do
      @tweet = new_tweet

      # RTs of the same tweet
      @rt1 = new_retweet @tweet, {username: "rt1"}
      @rt2 = new_retweet @tweet, {username: "rt2"}

      @aggr.on_tweet @tweet
      @aggr.on_tweet @rt1
      @aggr.on_tweet @rt2
    end

    it 'ignores tweet with no RT info' do
      expect{@aggr.on_tweet new_tweet}.not_to change{@aggr.rts.size}
    end

    it 'only maintains one RT per original id' do
      expect(@aggr.rts.size).to eq(1)
      expect(@aggr.rts.keys[0]).to eq(@tweet[:id])
    end

    it 'maintains only the last retweet sent per original id' do
      expect(@aggr.rts.values[0]).to eq(@rt2)
    end
  end

  context 'deleting older tweets' do
    before(:each) do
      @tweet1 = new_tweet id: 9999
      @rt1 = new_retweet @tweet1, {username: "rt1", timestamp_ms: now_ms - 3e10}

      @tweet2 = new_tweet id: 7777
      @rt2 = new_retweet @tweet2, {username: "rt2", timestamp_ms: now_ms - 6e10}

      @aggr.on_tweet @tweet1
      @aggr.on_tweet @tweet2
      @aggr.on_tweet @rt1
      @aggr.on_tweet @rt2
    end

    it "deletes nothing when window value is too high" do
      expect{@aggr.delete_older_than 99e10}.not_to change{@aggr.rts.size}
    end

    it "removes only items older than the window value" do
      @aggr.delete_older_than 5e10
      expect(@aggr.rts.size).to eq(1)
      expect(@aggr.rts.values).not_to include(@rt2)
      expect(@aggr.rts.values).to include(@rt1)
    end

    it "removes all if window is 0" do
      @aggr.delete_older_than 0
      expect(@aggr.rts).to be_empty
    end
  end

  context "when aggregating top retweets" do
    before(:each) do
      @tweets = []
      @rts = []
      (1..100).each do |i|
        tweet = new_tweet id: 2e10 + i
        rt = new_retweet tweet, {username: "rt#{i}", timestamp_ms: 1e10 + i }, {retweet_count: i}

        @tweets << tweet
        @rts << rt
        @aggr.on_tweet tweet
        @aggr.on_tweet rt
      end
    end

    it "returns most retweeted when called with n=1" do 
      top = @aggr.top_retweets(1)
      expect(top.size).to eq(1)
      expect(top.first[:id]).to eq(@tweets.last[:id])
    end

    it "returns top N retweets with the highest retweet count" do 
      top = @aggr.top_retweets(10)
      expect(top.size).to eq(10)

      #extracts ids of top retweeted tweets
      expected = @rts
          .map{|e| e[:retweeted_status]}
          .map{|e| [e[:retweet_count], e[:id]]}
          .sort
          .reverse[0...10]
          .map{|count, id| id}
      expect(top.map{|e| e[:id]}).to contain_exactly(*expected)
    end

    it "contains retweet creation timestamp as rt_timestamp" do
      @aggr.top_retweets(10).each do |t|
        expected_timestamp = @rts.find{|rt| rt[:retweeted_status][:id] == t[:id]}[:timestamp_ms]
        expect(t[:rt_timestamp].to_i).to eq(expected_timestamp)
      end

    end
  end
end
