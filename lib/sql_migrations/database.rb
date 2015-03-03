module SqlMigrations
  class Database

    SCHEMA_TABLE = :sqlmigrations_schema
    attr_reader :db

    def initialize(options)
      @name = options[:name] || :default
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
      install_table
    end

    def execute_migrations
      puts "[i] Executing migrations"
      Migration.find(@name).each { |migration| migration.execute(self) }
    end

    def seed_database
      puts "[i] Seeding database"
      Seed.find(@name).each { |seed| seed.execute(self) }
    end

    def seed_with_fixtures
      puts "[i] Seeding test database with fixtures"
      Fixture.find(@name).each { |fixture| fixture.execute(self) }
    end

    def schema_dataset
      @db[SCHEMA_TABLE]
    end

    private
    def install_table
      # Check if we have migrations_schema table present
      unless @db.table_exists?(SCHEMA_TABLE)
        puts "[!] Installing `#{SCHEMA_TABLE}`"
        @db.create_table(SCHEMA_TABLE) do
          primary_key :id
          Bignum   :time
          DateTime :executed
          String   :name
          String   :type
          index [ :time, :type ]
        end
      end
    end


  end
end
