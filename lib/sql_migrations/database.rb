require 'sequel'

module SqlMigrations
  # Class that represents database gem will connect to
  #
  class Database
    HISTORY_TABLE = :sqlmigrations_schema
    attr_reader :name, :driver

    def initialize(name, options)
      @name    = name
      @adapter = options[:adapter]
      @path_migration_seed = options[:path_migration_seed]
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

    def migrate
      migrations = Migration.find(@name, @path_migration_seed)
      if !migrations.empty?
        puts "[i] Executing migrations for `#{@name}` database"
        migrations.each { |migration| migration.execute(self) }
      else
        puts "[i] No migrations for `#{@name}` database"
      end
    end

    def seed
      seeds = Seed.find(@name, @path_migration_seed)
      if !seeds.empty?
        puts "[i] Seeding `#{@name}` database"
        seeds.each { |seed| seed.execute(self) }
      else
        puts "[i] No seeds for `#{@name}` database"
      end
    end

    def history
      @driver[HISTORY_TABLE]
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
      return if @driver.table_exists?(HISTORY_TABLE)

      puts "[!] Installing `#{HISTORY_TABLE}` history table"
      @driver.create_table(HISTORY_TABLE) do
        # rubocop:disable Style/SingleSpaceBeforeFirstArg
        primary_key :id
        column      :time, :Bignum
        DateTime    :executed
        String      :name
        String      :type
        index       [:time, :type]
        # rubocop:enable Style/SingleSpaceBeforeFirstArg
      end
    end
  end
end
