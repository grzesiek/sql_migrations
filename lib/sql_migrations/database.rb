module SqlMigrations
  # Class that represents database gem will connect to
  #
  class Database
    SCHEMA_TABLE = :sqlmigrations_schema
    attr_reader :name, :driver

    def initialize(name, options)
      @name    = name
      @adapter = options[:adapter]
      begin
        @driver = self.class.connect(options)
      rescue
        puts "[-] Could not connect to `#{@name}` database using #{@adapter} adapter"
        raise
      else
        puts "[+] Connected to `#{@name}` database using #{@adapter} adapter"
      end
      install_table
    end

    def execute_migrations
      migrations = Migration.find(@name)
      if !migrations.empty?
        puts "[i] Executing migrations for `#{@name}` database"
        migrations.each { |migration| migration.execute(self) }
      else
        puts "[i] No new migrations for `#{@name}` database"
      end
    end

    def seed_database
      seeds = Seed.find(@name)
      if !seeds.empty?
        puts "[i] Seeding `#{@name}` database"
        seeds.each { |seed| seed.execute(self) }
      else
        puts "[i] No new seeds for `#{@name}` database"
      end
    end

    def seed_with_fixtures
      fixtures = Fixture.find(@name)
      if !fixtures.empty?
        puts "[i] Seeding `#{@name}` database with fixtures"
        fixtures.each { |fixture| fixture.execute(self) }
      else
        puts "[i] No new fixturess for `#{@name}` database"
      end
    end

    def schema_dataset
      @driver[SCHEMA_TABLE]
    end

    private

    def self.connect(options)
      Sequel.connect(adapter:  options[:adapter],
                     encoding: options[:encoding],
                     host:     options[:host],
                     database: options[:database],
                     user:     options[:username],
                     password: options[:password],
                     test:     true)
    end

    def install_table
      # Check if we have migrations_schema table present
      return if @driver.table_exists?(SCHEMA_TABLE)
      puts "[!] Installing `#{SCHEMA_TABLE}`"
      @driver.create_table(SCHEMA_TABLE) do
        # rubocop:disable Style/SingleSpaceBeforeFirstArg
        primary_key :id
        Bignum      :time
        DateTime    :executed
        String      :name
        String      :type
        index      [:time, :type]
        # rubocop:enable Style/SingleSpaceBeforeFirstArg
      end
    end
  end
end
