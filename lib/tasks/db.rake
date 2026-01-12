# frozen_string_literal: true

namespace :test do
  namespace :db do
    def db_env_vars(include_dbname: false)
      vars = {
        'PGHOST' => ENV.fetch('BASEBALLBOT_PG_HOST', nil),
        'PGUSER' => ENV.fetch('BASEBALLBOT_PG_USERNAME'),
        'PGPASSWORD' => ENV.fetch('BASEBALLBOT_PG_PASSWORD')
      }

      vars['PGDATABASE'] = 'baseballbot_test' if include_dbname

      vars.compact
    end

    desc 'Drop the test database'
    task :drop do
      puts "Dropping database baseballbot_test..."
      result = system(db_env_vars, "dropdb --if-exists baseballbot_test")

      if result
        puts "Database baseballbot_test dropped successfully"
      else
        abort 'Failed to drop database'
      end
    end

    desc 'Create the test database'
    task :create do
      puts "Creating database baseballbot_test..."
      result = system(db_env_vars, "createdb baseballbot_test")

      if result
        puts "Database baseballbot_test created successfully"
      else
        abort 'Failed to create database'
      end
    end

    desc 'Reset the test database by dropping all tables and reloading from spec/database.sql'
    task :reset do
      # Drop and recreate the database
      Rake::Task['test:db:drop'].invoke
      Rake::Task['test:db:create'].invoke

      puts 'Loading schema and data from spec/database.sql...'
      sql_file = File.join(__dir__, '../../spec/database.sql')

      result = system(db_env_vars(include_dbname: true), "psql -f #{sql_file} -q")

      unless result
        puts "\n⚠️  Warning: psql command encountered errors."
      end

      puts "\nDatabase reset complete!"
    end

    desc 'Dump the current database to spec/database.sql'
    task :dump do
      sql_file = File.join(__dir__, '../../spec/database.sql')

      puts 'Dumping database to spec/database.sql...'

      result = system(db_env_vars(include_dbname: true), "pg_dump --clean --if-exists > #{sql_file}")

      if result
        puts "Database dumped successfully to #{sql_file}"
      else
        abort 'Failed to dump database'
      end
    end
  end
end
