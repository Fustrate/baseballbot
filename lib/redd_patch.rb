# frozen_string_literal: true

# Fix for Ruby 3
module Redd
  module Models
    class Subreddit < Model
      def modify_settings(...)
        full_params = settings.merge(...).merge(sr: read_attribute(:name))

        SETTINGS_MAP.each { |src, dest| full_params[dest] = full_params.delete(src) }

        client.post('/api/site_admin', full_params)
      end
    end
  end
end
