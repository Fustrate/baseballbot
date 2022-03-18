# frozen_string_literal: true

require_relative 'model'

module Redd
  module Models
    # A backward-expading listing of items.
    # @see Stream
    class Listing < Model
      include Enumerable

      # Create an empty listing with a client.
      # @param client [APIClient] the client to create the listing with
      # @return [Listing] the empty listing
      def self.empty(client) = Listing.new(client, children: [])

      # Create a fully initialized listing.
      # @param client [APIClient] the api client
      # @param attributes [Hash] the attribute hash
      def initialize(client, attributes = {})
        super

        fully_loaded!
      end

      # @return [Array<Comment, Submission, PrivateMessage>] an array representation of self
      def to_a = read_attribute(:children)
      alias to_ary to_a

      def [](index) = read_attribute(:children)[index]

      def each(&) = read_attribute(:children).each(&)

      def empty? = read_attribute(:children).empty?

      def first(amount) = read_attribute(:children).first(amount)

      def last(amount) = read_attribute(:children).last(amount)

      # @!attribute [r] before
      #   @return [String] the fullname of the item before this listing
      property :before, :nil

      # @!attribute [r] after
      #   @return [String] the fullname of the item that the next listing will start from
      property :after, :nil

      # @!attribute [r] children
      #   @return [Array<Model>] the listing's children
      property :children, :required, with: ->(a) { a.map { client.unmarshal(_1) } }
    end
  end
end
