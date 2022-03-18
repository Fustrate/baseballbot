# frozen_string_literal: true

require_relative 'model'

module Redd
  module Models
    # An object that represents a bunch of comments that need to be expanded.
    class MoreComments < Model
      # Expand the object's children into a listing of Comments and MoreComments.
      # @param link [Submission] the submission the object belongs to
      # @return [Listing<Comment, MoreComments>] the expanded children
      def expand(link:) = expand_recursive(link:, lookup: {})

      # @return [Array<String>] an array representation of self
      def to_a = read_attribute(:children)

      alias to_ary to_a

      # @!attribute [r] count
      #   @return [Integer] the comments under this object
      property :count

      # @!attribute [r] name
      #   @return [String] the object fullname
      property :name

      # @!attribute [r] id
      #   @return [String] the object id
      property :id

      # @!attribute [r] parent_id
      #   @return [String] the parent fullname
      property :parent_id

      # @!attribute [r] depth
      #   @return [Integer] the depth
      property :depth

      # @!attribute [r] children
      #   @return [Array<String>] the unexpanded comments
      property :children

      protected

      # Keep expanding until all top-level MoreComments are converted to comments.
      # @param link [Submission] the object's submission
      # @param lookup [Hash] a hash of comments to add future replies to
      # @return [Array<Comment, MoreComments>] the expanded comments or self if past depth
      def expand_recursive(link:, lookup:)
        return [self] if depth.zero?

        expand_one(link:).each_with_object([]) do |thing, coll|
          target = target_for_thing(thing, coll, lookup)

          if target.nil?
            warn "expanding error: orphaned comment #{thing.name}"
            next
          end

          process_thing(thing, target, link, lookup)
        end
      end

      private

      def target_for_thing(thing, coll, lookup)
        return coll if thing.parent_id == read_attribute(:parent_id)

        return unless lookup.key?(thing.parent_id)

        lookup[thing.parent_id].replies.children
      end

      def process_thing(thing, target, link, lookup)
        case thing
        when Comment
          # Add the comment to a lookup hash.
          lookup[thing.name] = thing

          # If the parent is not in the lookup hash, add it to the root listing.
          target.push thing
        when MoreComments
          return unless thing.count.positive?

          return target.push(thing) unless thing.parent_id == read_attribute(:parent_id)

          target.concat thing.expand_recursive(link:, lookup:, depth: depth - 1)
        end
      end

      # Expand the object's children into a listing of Comments and MoreComments.
      # @param link [Submission] the submission the object belongs to
      # @return [Listing<Comment, MoreComments>] the expanded children
      def expand_one(link:)
        client.model(:post, '/api/morechildren', {
          link_id: link.name,
          children: read_attribute(:children).join(','),
          sort: link.sort_order
        }.compact)
      end
    end
  end
end
