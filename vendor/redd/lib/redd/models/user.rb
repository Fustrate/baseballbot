# frozen_string_literal: true

require_relative 'lazy_model'
require_relative 'messageable'

module Redd
  module Models
    # A reddit user.
    class User < LazyModel
      include Messageable

      # Create a User from their name.
      # @param client [APIClient] the api client to initialize the object with
      # @param id [String] the username
      # @return [User]
      def self.from_id(client, id)
        new(client, name: id)
      end

      # Unblock a previously blocked user.
      # @param me [User] (optional) the person doing the unblocking
      def unblock(my_id: nil)
        my_id = "t2_#{my_id.is_a?(User) ? user.id : @client.get('/api/v1/me').body[:id]}"

        # Talk about an unintuitive endpoint
        @client.post('/api/unfriend', container: my_id, name: get_attribute(:name), type: 'enemy')
      end

      # Compose a message to the moderators of a subreddit.
      #
      # @param subject [String] the subject of the message
      # @param text [String] the message text
      # @param from [Subreddit, nil] the subreddit to send the message on behalf of
      def send_message(subject:, text:, from: nil)
        super(to: get_attribute(:name), subject:, text:, from:)
      end

      # Add the user as a friend.
      # @param note [String] a note for the friend
      def friend(note = nil)
        name = get_attribute(:name)
        body = JSON.generate(note ? { name:, note: } : { name: })
        @client.request(:put, "/api/v1/me/friends/#{name}", body:)
      end

      # Unfriend the user.
      def unfriend
        name = get_attribute(:name)
        @client.request(:delete, "/api/v1/me/friends/#{name}", raw: true, form: { id: name })
      end

      # Get the appropriate listing.
      # @param type [:overview, :submitted, :comments, :liked, :disliked, :hidden, :saved, :gilded]
      #   the type of listing to request
      # @param params [Hash] a list of params to send with the request
      # @option params [:hot, :new, :top, :controversial] :sort the order of the listing
      # @option params [String] :after return results after the given fullname
      # @option params [String] :before return results before the given fullname
      # @option params [Integer] :count the number of items already seen in the listing
      # @option params [1..100] :limit the maximum number of things to return
      # @option params [:hour, :day, :week, :month, :year, :all] :time the time period to consider
      #   when sorting
      # @option params [:given] :show whether to show the gildings given
      #
      # @note The option :time only applies to the top and controversial sorts.
      # @return [Listing<Submission>]
      def listing(type, **params)
        params[:t] = params.delete(:time) if params.key?(:time)
        @client.model(:get, "/user/#{get_attribute(:name)}/#{type}.json", params)
      end

      # @see #listing
      def overview(**params) = listing(:overview, **params)

      # @see #listing
      def submitted(**params) = listing(:submitted, **params)

      # @see #listing
      def comments(**params) = listing(:comments, **params)

      # @see #listing
      def liked(**params) = listing(:liked, **params)

      # @see #listing
      def disliked(**params) = listing(:disliked, **params)

      # @see #listing
      def hidden(**params) = hidden(:rising, **params)

      # @see #listing
      def saved(**params) = saved(:rising, **params)

      # @see #listing
      def gilded(**params) = listing(:gilded, **params)

      # Gift a redditor reddit gold.
      # @param months [Integer] the number of months of gold to gift
      def gift_gold(months: 1)
        @client.post("/api/v1/gold/give/#{get_attribute(:name)}", months:)
      end

      private

      def default_loader
        @client.get("/user/#{@attributes.fetch(:name)}/about").body[:data]
      end
    end
  end
end
