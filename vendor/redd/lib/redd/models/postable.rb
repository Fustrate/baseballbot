# frozen_string_literal: true

module Redd
  module Models
    # Methods for user-submitted content, i.e. Submissions and Comments.
    module Postable
      def name = get_attribute(:name)

      # Edit a thing.
      # @param text [String] The new text.
      # @return [self] the edited thing
      def edit(text)
        @client.post('/api/editusertext', thing_id: name, text:)

        @attributes[is_a?(Submission) ? :selftext : :body] = text

        self
      end

      # Delete the thing.
      def delete = @client.post('/api/del', id: name)

      # Save a link or comment to the user's account.
      # @param category [String] a category to save to
      def save(category = nil) = @client.post('/api/save', { id: name, category: }.compact)

      # Remove the link or comment from the user's saved links.
      def unsave = @client.post('/api/unsave', id: name)

      # Hide a link from the user.
      def hide = @client.post('/api/hide', id: name)

      # Unhide a previously hidden link.
      def unhide = @client.post('/api/unhide', id: name)

      # Upvote the model.
      def upvote = vote(1)

      # Downvote the model.
      def downvote = vote(-1)

      # Clear any upvotes or downvotes on the model.
      def undo_vote = vote(0)

      # Send replies to this thing to the user's inbox.
      def enable_inbox_replies = @client.post('/api/sendreplies', id: name, state: true)

      # Stop sending replies to this thing to the user's inbox.
      def disable_inbox_replies = @client.post('/api/sendreplies', id: name, state: false)

      private

      # Send a vote.
      # @param direction [-1, 0, 1] the direction to vote in
      def vote(direction)
        @client.post('/api/vote', id: name, dir: direction)

        @attributes[:ups] += direction
      end
    end
  end
end
