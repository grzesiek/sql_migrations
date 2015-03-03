require 'sequel'
require 'yaml'
require 'find'
require 'benchmark'

require 'sql_migrations/version'
require 'sql_migrations/database'
require 'sql_migrations/supervisor'
require 'sql_migrations/sql_script'
require 'sql_migrations/migration'
require 'sql_migrations/seed'
require 'sql_migrations/fixture'

module SqlMigrations
  class << self
    attr_reader :options

    def load_tasks
      load "sql_migrations/tasks/migrate.rake"
      load "sql_migrations/tasks/seed.rake"
      load "sql_migrations/tasks/seed_test.rake"
      load "sql_migrations/tasks/list.rake"
    end

    def load!(config_file)
      @options = YAML::load_file(config_file)
    end
  end
end
