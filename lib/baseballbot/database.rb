# frozen_string_literal: true

require 'sequel'

Sequel.extension :pg_json_ops

# Connect to the database immediately so that model classes can be created.
DB = Sequel.connect(
  adapter: :postgres,
  host: ENV.fetch('BASEBALLBOT_PG_HOST', nil),
  database: ENV.fetch('BASEBALLBOT_PG_DATABASE'),
  password: ENV.fetch('BASEBALLBOT_PG_PASSWORD'),
  user: ENV.fetch('BASEBALLBOT_PG_USERNAME')
)

DB.extension :pg_array
DB.extension :pg_json
DB.wrap_json_primitives = true

class Baseballbot
  module Database
    def db = DB
  end
end
