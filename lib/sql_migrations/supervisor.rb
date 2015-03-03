module SqlMigrations
  class Supervisor

    def initialize
      @env = (ENV['ENV'] ||= "development").to_sym
      @options = SqlMigrations.options
      @databases = get_databases_from_config
    end

    def migrate
      databases_run { |db| db.execute_migrations }
    end

    def seed
      databases_run { |db| db.seed_database      }
    end

    def seed_test
      databases_run { |db| db.seed_with_fixtures }
    end

    def list_files
      Migration.find(@databases).each { |migration| puts migration }
      Seed.find(@databases).each      { |seed|      puts seed      }
      Fixture.find(@databases).each   { |fixture|   puts fixture   }
    end

    private
    def get_databases_from_config
      databases = @options.map { |k, v| k.to_sym }
      unless databases.include?(:default)
        raise "Default database configuration not found !"
      end
      databases
    end

    def databases_run
      @databases.each do |db|
        db_options = @options[db.to_s][@env.to_s]
        db_options.merge!(name: db)
        if db_options
          yield Database.new(db_options)
        else
          raise "Configuration for #{db} in environment #{@env} not found !"
        end
      end
    end

  end
end
