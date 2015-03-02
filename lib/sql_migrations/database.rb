module SqlMigrations
  class Database

    class << self
      def migrate
        options = SqlMigrations.options
        self.new(options).execute_migrations
      end

      def seed
        options = SqlMigrations.options
        self.new(options).seed_database
      end
    end

    def initialize(options)
      puts "[i] Connecting to database using #{options['adapter']} adapter"
      @db = Sequel.connect(adapter:  options['adapter'],
                           host:     options['host'],
                           database: options['database'],
                           user:     options['username'],
                           password: options['password'])
    end

    def execute_migrations
    end

    def seed_database
    end

  end
end
