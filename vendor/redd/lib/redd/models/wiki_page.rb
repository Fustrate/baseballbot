# frozen_string_literal: true

require_relative 'lazy_model'

module Redd
  module Models
    # A reddit user.
    class WikiPage < LazyModel
      # Edit the wiki page.
      # @param content [String] the new wiki page contents
      # @param reason [String, nil] an optional reason for editing the page
      def edit(content, reason: nil)
        params = {
          page: @attributes.fetch(:title),
          content:,
          reason:
        }.compact

        @client.post("/r/#{subreddit_display_name}/api/wiki/edit", params)
      end

      private

      def default_loader
        title = @attributes.fetch(:title)

        if @attributes.key?(:subreddit)
          return @client.get("/r/#{subreddit_display_name}/wiki/#{title}").body[:data]
        end

        @client.get("/wiki/#{title}").body[:data]
      end

      def after_initialize
        return unless @attributes[:revision_by]

        @attributes[:revision_by] = @client.unmarshal(@attributes[:revision_by])
      end

      def subreddit_display_name = @attributes.fetch(:subreddit).display_name
    end
  end
end
