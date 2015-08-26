require 'sequel'
require 'yaml'
require 'find'
require 'benchmark'
require 'time'
require 'erb'

require 'sql_migrations/version'
require 'sql_migrations/database'
require 'sql_migrations/config'
require 'sql_migrations/file'
require 'sql_migrations/script'
require 'sql_migrations/migration'
require 'sql_migrations/seed'
require 'sql_migrations/fixture'

# SqlMigrations
#
module SqlMigrations
  extend self

  def load_tasks
    load 'sql_migrations/tasks/migrate.rake'
    load 'sql_migrations/tasks/seed.rake'
    load 'sql_migrations/tasks/seed_test.rake'
    load 'sql_migrations/tasks/list.rake'
  end

  def migrate
    databases(&:execute_migrations)
  end

  def seed
    databases(&:seed_database)
  end

  def seed_test
    databases(&:seed_with_fixtures)
  end

  def list_files
    Config.databases.each do |name, _config|
      Migration.find(name).each { |migration| puts migration }
      Seed.find(name).each      { |seed|      puts seed      }
      Fixture.find(name).each   { |fixture|   puts fixture   }
    end
  end

  private

  def databases
    Config.databases.each do |name, config|
      db = Database.new(name, config)
      yield db
    end
  end
end
