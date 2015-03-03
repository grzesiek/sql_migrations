module SqlMigrations
  class Database

    def initialize(options)
      @name = options[:name] || :default
      return
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
      Migration.find(@name).each { |migration| puts "#{@name}: #{migration}" }
    end

    def seed_database
      puts "[i] Seeding database"
      Seed.find(@name).each { |seed| seed.execute(@db) }
    end

    def seed_with_fixtures
      puts "[i] Seeding test database with fixtures"
      Fixture.find(@name).each { |fixture| fixture.execute(@db) }
    end

    private
    def install_table
      # Check if migration and seed tables are present
      unless @db.table_exists?(:sqlmigrations_migrations)
        create_schema_table(:sqlmigrations_migrations)
      end

      unless @db.table_exists?(:sqlmigrations_seeds)
        create_schema_table(:sqlmigrations_seeds)
      end
    end

    def create_schema_table(table_name)
      puts "[!] Installing `#{table_name}`"
      @db.create_table(table_name) do
        primary_key :id
        DateTime :time
        DateTime :executed
        String   :name
        index [ :time, :name ]
      end
    end

  end
end
