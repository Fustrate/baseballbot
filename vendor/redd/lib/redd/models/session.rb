# frozen_string_literal: true

require_relative 'lazy_model'
require_relative 'searchable'

module Redd
  module Models
    # The starter class.
    class Session < BasicModel
      include Searchable

      # @return [ModMail] the new modmail
      def mod_mail = ModMail.new(@client)

      # @return [LiveThread] the live thread
      def live_thread(id) = LiveThread.from_id(client, id)

      # @return [FrontPage] the user's front page
      def front_page = FrontPage.new(@client)

      # @return [Hash] a breakdown of karma over subreddits
      def karma_breakdown = @client.get('/api/v1/me/karma').body[:data]

      # @return [User] the logged-in user
      def me = User.new(@client) { _1.get('/api/v1/me').body }

      # Get a (lazily loaded) reddit user by their name.
      # @param name [String] the username
      # @return [User]
      def user(name) = User.from_id(@client, name)

      # Get a (lazily loaded) subreddit by its name.
      # @param display_name [String] the subreddit's display name
      # @return [Subreddit]
      def subreddit(display_name) = Subreddit.from_id(@client, display_name)

      # @return [Array<Multireddit>] array of multireddits belonging to the user
      def my_multis = @client.get('/api/multi/mine').body.map { @client.unmarshal(_1) }

      # Get a (lazily loaded) multi by its path.
      # @param path [String] the multi's path, surrounded by a leading and trailing /
      # @return [Multireddit]
      def multi(path) = Multireddit.from_id(@client, path)

      # Get submissions or comments by their fullnames.
      # XXX: Could we use better methods for t1_ and t3_?
      # @param fullnames [String, Array<String>] one or an array of fullnames (e.g. t3_abc1234)
      # @return [Listing<Submission, Comment>]
      def from_ids(fullnames) = @client.model(:get, '/api/info', id: Array(fullnames).join(','))

      # Get submissions or comments by their fullnames.
      # @param url [String] the object's url
      # @return [Submission, Comment, nil] the object, or nil if not found
      def from_url(url) = @client.model(:get, '/api/info', url:).first

      # Return a listing of the user's inbox (including comment replies and private messages).
      #
      # @param category ['inbox', 'unread', 'sent', 'moderator'] the category of messages to view
      # @param mark [Boolean] whether to remove the orangered from the user's inbox
      # @param params [Hash] a list of optional params to send with the request
      # @option params [String] :after return results after the given fullname
      # @option params [String] :before return results before the given fullname
      # @option params [Integer] :count (0) the number of items already seen in the listing
      # @option params [1..100] :limit (25) the maximum number of things to return
      # @return [Listing<Comment, PrivateMessage>]
      def my_messages(category: 'inbox', mark: false, **params)
        @client.model(:get, "/message/#{category}.json", params.merge(mark:))
      end

      # Mark all messages as read.
      def read_all_messages = @client.post('/api/read_all_messages')

      # @return [Hash] the user's preferences
      def my_preferences = @client.get('/api/v1/me/prefs').body

      # Edit the user's preferences.
      # @param new_prefs [Hash] the changed preferences
      # @return [Hash] the new preferences
      # @see #my_preferences
      def edit_preferences(new_prefs = {})
        @client.request(
          :patch,
          '/api/v1/me/prefs',
          headers: { 'Content-Type' => 'application/json' },
          body: JSON.generate(new_prefs)
        ).body
      end

      # @return [Array<User>] the logged-in user's friends
      def friends
        @client.get('/api/v1/me/friends').body[:data][:children].map do |h|
          User.new(@client, name: h[:name], id: h[:id].sub('t2_', ''), since: h[:date])
        end
      end

      # @return [Array<User>] users blocked by the logged-in user
      def blocked
        @client.get('/prefs/blocked').body[:data][:children].map do |h|
          User.new(@client, name: h[:name], id: h[:id].sub('t2_', ''), since: h[:date])
        end
      end

      # @return [Array<User>] users blocked by the logged-in user
      def trusted
        @client.get('/prefs/trusted').body[:data][:children].map do |h|
          User.new(@client, name: h[:name], id: h[:id].sub('t2_', ''), since: h[:date])
        end
      end

      # @return [Array<String>] a list of categories the user's items are saved in
      def saved_categories = @client.get('/api/saved_categories').body

      # Return a listing of the user's subreddits.
      #
      # @param type ['subscriber', 'contributor', 'moderator'] the type of subreddits
      # @param params [Hash] a list of optional params to send with the request
      # @option params [String] :after return results after the given fullname
      # @option params [String] :before return results before the given fullname
      # @option params [Integer] :count (0) the number of items already seen in the listing
      # @option params [1..100] :limit (25) the maximum number of things to return
      # @return [Listing<Subreddit>]
      def my_subreddits(type, **params) = @client.model(:get, "/subreddits/mine/#{type}", params)
    end
  end
end
