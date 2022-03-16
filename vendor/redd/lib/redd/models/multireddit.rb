# frozen_string_literal: true

require_relative 'lazy_model'

module Redd
  module Models
    # A multi.
    class Multireddit < LazyModel
      # Create a Multireddit from its path.
      # @param client [APIClient] the api client to initialize the object with
      # @param id [String] the multi's path (with a leading and trailing slash)
      # @return [Multireddit]
      def self.from_id(client, id) = new(client, path: id)

      # Get the appropriate listing.
      # @param sort [:hot, :new, :top, :controversial, :comments, :rising, :gilded] the type of
      #   listing
      # @param params [Hash] a list of params to send with the request
      # @option params [String] :after return results after the given fullname
      # @option params [String] :before return results before the given fullname
      # @option params [Integer] :count the number of items already seen in the listing
      # @option params [1..100] :limit the maximum number of things to return
      # @option params [:hour, :day, :week, :month, :year, :all] :time the time period to consider
      #   when sorting.
      #
      # @note The option :time only applies to the top and controversial sorts.
      # @return [Listing<Submission>]
      def listing(sort, **params)
        params[:t] = params.delete(:time) if params.key?(:time)

        @client.model(:get, "#{get_attribute(:path)}#{sort}", params)
      end

      # @see #listing
      def hot(**params) = listing(:hot, **params)

      # @see #listing
      def new(**params) = listing(:new, **params)

      # @see #listing
      def top(**params) = listing(:top, **params)

      # @see #listing
      def controversial(**params) = listing(:controversial, **params)

      # @see #listing
      def comments(**params) = listing(:comments, **params)

      # @see #listing
      def rising(**params) = listing(:rising, **params)

      # @see #listing
      def gilded(**params) = listing(:gilded, **params)

      private

      def after_initialize
        @attributes[:subreddits].map! do |subreddit|
          Subreddit.new(client, display_name: subreddit[:name])
        end
      end

      def default_loader = @client.get("/api/multi#{@attributes.fetch(:path)}").body[:data]
    end
  end
end
