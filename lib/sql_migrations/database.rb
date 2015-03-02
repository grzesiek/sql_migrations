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
      begin
        @db = Sequel.connect(adapter:  options['adapter'],
                             host:     options['host'],
                             database: options['database'],
                             user:     options['username'],
                             password: options['password'],
                             test:     true)
      rescue
        puts "[-] Could not connect to database using #{options['adapter']} adapter"
        raise
      else
        puts "[+] Connected to database using #{options['adapter']} adapter"
      end
    end

    def execute_migrations
      puts "[i] Executing migrations"
      Migration.find.each { |migration| migration.execute(@db) }
    end

    def seed_database
      puts "[i] Seeding database"
      Seed.find.each { |seed| seed.execute(@db) }
    end

  end
end
