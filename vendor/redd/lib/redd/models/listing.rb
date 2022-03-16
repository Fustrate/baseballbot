# frozen_string_literal: true

require_relative 'basic_model'

module Redd
  module Models
    # A backward-expading listing of items.
    # @see Stream
    class Listing < BasicModel
      include Enumerable

      # @return [Array<Comment, Submission, PrivateMessage>] an array representation of self
      def to_ary
        get_attribute(:children)
      end

      def [](index) = get_attribute(:children)[index]

      def each(&) = get_attribute(:children).each(&)

      def empty? = get_attribute(:children).empty?

      def first(amount = nil) = get_attribute(:children).first(amount)

      def last(amount = nil) = get_attribute(:children).last(amount)
    end
  end
end
