# frozen_string_literal: true

require_relative 'basic_model'

module Redd
  module Models
    # The base class for lazily-initializable models.
    class LazyModel < BasicModel
      # Create a lazily initialized class.
      # @param client [APIClient] the client that the model uses to make requests
      # @param base_attributes [Hash] the already-known attributes that do not need to be looked up
      # @yield [client] the model's client
      # @yieldparam client [APIClient]
      # @yieldreturn [Hash] the response of "initializing" the lazy model
      def initialize(client, base_attributes = {}, &block)
        super(client, base_attributes)

        @lazy_loader = block
        @definitely_fully_loaded = false
      end

      # Force the object to make a request to reddit.
      # @return [self]
      def force_load
        @attributes.merge!(@lazy_loader ? @lazy_loader.call(@client) : default_loader)
        @definitely_fully_loaded = true

        after_initialize

        self
      end
      alias reload force_load

      # Convert the object to a hash, making a request to fetch additional attributes if needed.
      # @return [Hash]
      def to_h
        ensure_fully_loaded

        super
      end

      # Checks whether an attribute is supported by method_missing. Since we don't know whether an
      # attribute exists until we load it, we have to respond true until we load it.
      # @param method_name [Symbol] the method name or attribute to check
      # @param include_private [Boolean] whether to also include private methods
      # @return [Boolean] whether the method is handled by method_missing
      def respond_to_missing?(method_name, include_private = false) = (@definitely_fully_loaded ? super : true)

      # Return an attribute or raise a NoMethodError if it doesn't exist.
      # @param method_name [Symbol] the name of the attribute
      # @return [Object] the result of the attribute check
      def method_missing(method_name, ...)
        ensure_fully_loaded unless @attributes.key?(method_name)

        super
      end

      private

      # @abstract A lazy loader to use when one is not provided.
      def default_loader = {}

      # Make sure the model is loaded at least once.
      def ensure_fully_loaded = (force_load unless @definitely_fully_loaded)

      # Gets the attribute and loads it if it may be available from the response.
      def get_attribute(name)
        # XXX: Replace get_attribute calls with simple method calls?
        ensure_fully_loaded unless @attributes.key?(name)

        super
      end
    end
  end
end
