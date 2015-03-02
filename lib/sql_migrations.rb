require 'sequel'
require 'yaml'
require 'find'

require 'sql_migrations/version'
require 'sql_migrations/database'
require 'sql_migrations/migration'

module SqlMigrations
  class << self
    attr_reader :options

    def load_tasks
      load "sql_migrations/tasks/migrate.rake"
      load "sql_migrations/tasks/seed.rake"
      load "sql_migrations/tasks/list.rake"
    end

    def load!(config_file)
      ENV['ENV'] ||= "development"
      @options = YAML::load_file(config_file)[ENV['ENV']]
    end

    def list_files
      Migration.find.each { |migration| puts migration }
      # Seed.find.each { |seed| puts seed }
    end
  end
end
