# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'redd/version'

Gem::Specification.new do |spec|
  spec.name = 'redd'
  spec.version = Redd::VERSION
  spec.authors = ['Avinash Dwarapu']
  spec.email = ['avinash@dwarapu.me']

  spec.summary = 'A batteries-included API wrapper for reddit.'
  spec.homepage = 'https://github.com/avinashbot/redd'
  spec.license = 'MIT'

  spec.files = [
    'Gemfile',
    'Gemfile.lock',
    'Rakefile',
    'lib/redd.rb',
    'lib/redd/api_client.rb',
    'lib/redd/auth_strategies/auth_strategy.rb',
    'lib/redd/auth_strategies/script.rb',
    'lib/redd/auth_strategies/userless.rb',
    'lib/redd/auth_strategies/web.rb',
    'lib/redd/client.rb',
    'lib/redd/errors.rb',
    'lib/redd/middleware.rb',
    'lib/redd/models/access.rb',
    'lib/redd/models/comment.rb',
    'lib/redd/models/front_page.rb',
    'lib/redd/models/gildable.rb',
    'lib/redd/models/inboxable.rb',
    'lib/redd/models/listing.rb',
    'lib/redd/models/live_thread.rb',
    'lib/redd/models/live_update.rb',
    'lib/redd/models/messageable.rb',
    'lib/redd/models/mod_action.rb',
    'lib/redd/models/model.rb',
    'lib/redd/models/moderatable.rb',
    'lib/redd/models/modmail.rb',
    'lib/redd/models/modmail_conversation.rb',
    'lib/redd/models/modmail_message.rb',
    'lib/redd/models/more_comments.rb',
    'lib/redd/models/multireddit.rb',
    'lib/redd/models/paginated_listing.rb',
    'lib/redd/models/postable.rb',
    'lib/redd/models/private_message.rb',
    'lib/redd/models/replyable.rb',
    'lib/redd/models/reportable.rb',
    'lib/redd/models/searchable.rb',
    'lib/redd/models/self.rb',
    'lib/redd/models/session.rb',
    'lib/redd/models/submission.rb',
    'lib/redd/models/subreddit.rb',
    'lib/redd/models/trophy.rb',
    'lib/redd/models/user.rb',
    'lib/redd/models/wiki_page.rb',
    'lib/redd/utilities/error_handler.rb',
    'lib/redd/utilities/rate_limiter.rb',
    'lib/redd/utilities/unmarshaller.rb',
    'lib/redd/version.rb',
    'redd.gemspec',
  ]
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { File.basename(_1) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 3.1'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'http', '~> 5.0'

  spec.add_development_dependency 'bundler', '~> 2.3'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.25'
  spec.add_development_dependency 'rubocop-performance', '~> 1.13'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.9'

  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'simplecov', '~> 0.13'
  spec.add_development_dependency 'vcr', '~> 6.0'
  spec.add_development_dependency 'webmock', '~> 3.14'
end
