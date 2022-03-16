# frozen_string_literal: true

require_relative 'basic_model'
require_relative 'subreddit'

module Redd
  module Models
    # A container for the new modmail.
    # XXX: Instead of making ModMail a dumb container, could it be a lazy wrapper for #unread_count?
    class ModMail < BasicModel
      # Represents a conversation in the new modmail.
      # TODO: add modmail-specific user type
      class Conversation < LazyModel
        # Get a Conversation from its id.
        # @param id [String] the base36 id (e.g. abc123)
        # @return [Conversation]
        def self.from_id(client, id) = new(client, id:)

        def id = get_attribute(:id)

        # Add a reply to the ongoing conversation.
        def reply(body, hidden: false, internal: false)
          # TODO: merge response into the conversation
          @client.post(
            "/api/mod/conversations/#{get_attribute(:id)}",
            body:,
            isAuthorHidden: hidden,
            isInternal: internal
          ).body
        end

        # Mark this conversation as read.
        def mark_as_read = @client.post('/api/mod/conversations/read', conversationIds: [id])

        # Mark this conversation as unread.
        def mark_as_unread = @client.post('/api/mod/conversations/unread', conversationIds: [id])

        # Mark this conversation as archived.
        def archive = perform_action(:post, 'archive')

        # Removed this conversation from archived.
        def unarchive = perform_action(:post, 'unarchive')

        # Highlight this conversation.
        def highlight = perform_action(:post, 'highlight')

        # Remove the highlight on this conversation.
        def unhighlight = perform_action(:delete, 'highlight')

        # Mute this conversation.
        def mute = perform_action(:post, 'mute')

        # Unmute this conversation.
        def unmute = perform_action(:post, 'unmute')

        private

        def default_loader
          response = @client.get("/api/mod/conversations/#{@attributes[:id]}").body

          response[:conversation].merge(
            messages: response[:messages].values.map { Message.new(@client, _1) },
            user: response[:user],
            mod_actions: response[:modActions]
          )
        end

        # Perform an action on a conversation.
        # @param method [:post, :delete] the method to use
        # @param action [String] the name of the action
        def perform_action(method, action)
          @client.send(method, "/api/mod/conversations/#{id}/#{action}")
        end
      end

      # A conversation message.
      class Message < BasicModel; end

      # @return [#highlighted, #notifications, #archived, #new, #inprogress, #mod] the number of
      #   unread messages in each category
      def unread_count
        BasicModel.new(nil, @client.get('/api/mod/conversations/unread/count').body)
      end

      # @return [Array<Subreddit>] moderated subreddits that are enrolled in the new modmail
      def enrolled
        @client.get('/api/mod/conversations/subreddits').body[:subreddits].map do |_, s|
          Subreddit.new(@client, s.merge(last_updated: s.delete(:lastUpdated)))
        end
      end

      # Get the conversations
      # @param subreddits [Subreddit, Array<Subreddit>] the subreddits to limit to
      # @param params [Hash] additional request parameters
      # @option params [String] :after base36 modmail conversation id
      # @option params [Integer] :limit an integer (default: 25)
      # @option params [:recent, :mod, :user, :unread] :sort the sort order
      # @option params [:new, :inprogress, :mod, :notifications, :archived, :highlighted, :all]
      #   :state the state to limit the conversations by
      def conversations(subreddits: nil, **params)
        params[:entity] = Array(subreddits).map(&:display_name).join(',') if subreddits

        @client.get('/api/mod/conversations', **params).body[:conversations].map do |_, conv|
          Conversation.new(@client, conv)
        end
      end

      # Create a new conversation.
      # @param from [Subreddit] the subreddit to send the conversation from
      # @param to [User] the person to send the message to
      # @param subject [String] the message subject
      # @param body [String] the message body
      # @return [Conversation] the created conversation
      def create(from:, to:, subject:, body:, hidden: false)
        Conversation.new(@client, @client.post(
          '/api/mod/conversations',
          srName: from.display_name,
          to: to.name,
          subject:,
          body:,
          isAuthorHidden: hidden
        ).body[:conversation])
      end

      # Get a conversation from its base36 id.
      # @param id [String] the conversation's id
      # @return [Conversation]
      def get(id) = Conversation.from_id(@client, id)
    end
  end
end
