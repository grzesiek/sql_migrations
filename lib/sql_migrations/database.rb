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
      install_table
    end

    def execute_migrations
      puts "[i] Executing migrations"
      Migration.find.each { |migration| migration.execute(@db) }
    end

    def seed_database
      puts "[i] Seeding database"
      Seed.find.each { |seed| seed.execute(@db) }
    end

    private
    def install_table
      # Check if we have `sqlmigrations_schema` table created
      unless @db.table_exists?(:sqlmigrations_schema)
        puts "[!] Installing `sqlmigrations_schema`"
        @db.create_table(:sqlmigrations_schema) do
          primary_key :id
          DateTime :time, unique: true
          DateTime :executed
          String   :name
          index [ :time, :name ]
        end
      end
    end

  end
end
