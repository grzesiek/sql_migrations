require 'sequel'
require 'yaml'
require 'pp'

require 'sql_migrations/version'
require 'sql_migrations/database'

module SqlMigrations
  class << self
    attr_reader :options

    def load_tasks
      load "sql_migrations/tasks/migrate.rake"
      load "sql_migrations/tasks/seed.rake"
    end

    def load!(config_file)
      ENV['ENV'] ||= "development"
      @options = YAML::load_file(config_file)[ENV['ENV']]
    end
  end
end
