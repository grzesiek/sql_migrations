require 'sequel'
require 'yaml'
require 'find'
require 'benchmark'
require 'time'
require 'erb'

require 'sql_migrations/version'
require 'sql_migrations/database'
require 'sql_migrations/config'
require 'sql_migrations/sql_script'
require 'sql_migrations/migration'
require 'sql_migrations/seed'
require 'sql_migrations/fixture'

module SqlMigrations
  class << self

    def load_tasks
      load "sql_migrations/tasks/migrate.rake"
      load "sql_migrations/tasks/seed.rake"
      load "sql_migrations/tasks/seed_test.rake"
      load "sql_migrations/tasks/list.rake"
    end

    def migrate
      databases { |db| db.execute_migrations }
    end

    def seed
      databases { |db| db.seed_database      }
    end

    def seed_test
      databases { |db| db.seed_with_fixtures }
    end

    def list_files
      Config.databases.each do |name, config|
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
end
