# frozen_string_literal: true

module Redd
  module Models
    # Methods for user-submitted content, i.e. Submissions and Comments.
    module Postable
      # Edit a thing.
      # @param text [String] The new text.
      # @return [self] the edited thing
      def edit(text)
        client.post('/api/editusertext', thing_id: read_attribute(:name), text:)

        self
      end

      # Delete the thing.
      def delete = client.post('/api/del', id: read_attribute(:name))

      # @return [Boolean] whether the item is probably deleted
      def deleted? = read_attribute(:author).name == '[deleted]'

      # Save a link or comment to the user's account.
      # @param category [String] a category to save to
      def save(category = nil) = client.post('/api/save', { id: read_attribute(:name), category: }.compact)

      # Remove the link or comment from the user's saved links.
      def unsave = client.post('/api/unsave', id: read_attribute(:name))

      # Hide a link from the user.
      def hide = client.post('/api/hide', id: read_attribute(:name))

      # Unhide a previously hidden link.
      def unhide = client.post('/api/unhide', id: read_attribute(:name))

      # Upvote the model.
      def upvote = vote(1)

      # Downvote the model.
      def downvote = vote(-1)

      # Clear any upvotes or downvotes on the model.
      def undo_vote = vote(0)

      # Send replies to this thing to the user's inbox.
      def enable_inbox_replies = client.post('/api/sendreplies', id: read_attribute(:name), state: true)

      # Stop sending replies to this thing to the user's inbox.
      def disable_inbox_replies = client.post('/api/sendreplies', id: read_attribute(:name), state: false)

      private

      # Send a vote.
      # @param direction [-1, 0, 1] the direction to vote in
      def vote(direction) = client.post('/api/vote', id: read_attribute(:name), dir: direction)
    end
  end
end
