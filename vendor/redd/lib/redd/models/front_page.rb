# frozen_string_literal: true

require_relative 'basic_model'
require_relative '../utilities/stream'

module Redd
  module Models
    # The front page.
    # FIXME: deal with serious code duplication from Subreddit
    class FrontPage < BasicModel
      # @return [Array<String>] reddit's base wiki pages
      def wiki_pages = @client.get('/wiki/pages').body[:data]

      # Get a wiki page by its title.
      # @param title [String] the page's title
      # @return [WikiPage]
      def wiki_page(title) = WikiPage.new(@client, title:)

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

        @client.model(:get, "/#{sort}", params)
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

      # Stream newly submitted posts.
      def post_stream(**params, &)
        params[:limit] ||= 100

        stream = Utilities::Stream.new do |previous|
          before = previous ? previous.first.name : nil

          listing(:new, params.merge(before:))
        end

        block_given? ? stream.stream(&) : stream.enum_for(:stream)
      end

      # Stream newly submitted comments.
      def comment_stream(**params, &)
        params[:limit] ||= 100

        stream = Utilities::Stream.new do |previous|
          before = previous ? previous.first.name : nil

          listing(:comments, params.merge(before:))
        end

        block_given? ? stream.stream(&) : stream.enum_for(:stream)
      end
    end
  end
end
