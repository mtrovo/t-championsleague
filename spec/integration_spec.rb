require 'spec_helper'
require 'byebug'


describe 'sinatra web app' do

	subject { page }

	shared_examples_for 'all pages' do
		it { should have_link('Refresh', href: '/') }
		it { should have_selector('h3', text: 'UEFA Champions League tracker') }
	end

	before do
		@aggregator = RTAggregator.new
		Capybara.app.helpers.aggregator = @aggregator 
	end

	describe 'home page' do
		before do
			@t = new_tweet text: 'My awesome tweet deserves a lot of RTS',
					user: {screen_name: 'MTROVO', profile_image_url: 'http://t.co/profile-picture'}
			@rt = new_retweet @t, {user: {screen_name: 'follower'}, timestamp_ms: now_ms}, retweet_count: 9001
			@aggregator.on_tweet @rt

			visit '/'
		end

		it_behaves_like 'all pages'

		it 'contains tweet text' do
			should have_selector('div.tweet span.text', text: @t[:text])
		end

		it 'contains link to retweet creator page' do
			link = find('div.tweet a')
			expect(link.text).to eq('@MTROVO')
			expect(link['href']).to eq('https://twitter.com/MTROVO')
		end

		it 'shows retweet creator profile picture' do 
			img = find('div.tweet>span>img')
			expect(img['src']).to eq('http://t.co/profile-picture')
		end

		it 'contains retweet count' do
			should have_selector('.rtnum', text: '9001 retweets')
		end
	end
end