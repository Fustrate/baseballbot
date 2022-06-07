# frozen_string_literal: true

lock '~> 3.17'

set :application, 'baseballbot'
set :user, 'baseballbot'
set :deploy_to, "/home/#{fetch :user}/apps/#{fetch :application}"

set :repo_url, 'git@github.com:Fustrate/baseballbot.git'
set :branch, ENV.fetch('REVISION', 'master')

append :linked_dirs, 'log'
append :linked_files, 'config/honeybadger.yml'

set :default_env, { path: '/opt/ruby/bin:$PATH' }

set :rbenv_ruby, File.read(File.expand_path('../.ruby-version', __dir__)).strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch :rbenv_path} #{fetch :rbenv_path}/bin/rbenv exec"
set :rbenv_map_bins, %w[bundle gem honeybadger rake ruby]
