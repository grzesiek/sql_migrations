require 'sql_migrations/version'
require 'sql_migrations/database'
require 'sql_migrations/config'
require 'sql_migrations/file'
require 'sql_migrations/script'
require 'sql_migrations/migration'
require 'sql_migrations/seed'

# SqlMigrations
#
module SqlMigrations
  extend self

  def migrate
    databases(&:migrate)
  end

  def seed
    databases(&:seed)
  end

  def scripts
    Config.databases.each do |name, _config|
      Migration.find(name).each { |migration| puts migration }
      Seed.find(name).each      { |seed|      puts seed      }
    end
  end

  def databases
    Config.databases.each do |name, config|
      db = Database.new(name, config)
      yield db if block_given?
    end
  end

  def load_tasks!
    load 'sql_migrations/tasks/migrate.rake'
    load 'sql_migrations/tasks/seed.rake'
    load 'sql_migrations/tasks/scripts.rake'
  end
end
