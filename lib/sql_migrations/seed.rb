module SqlMigrations
  # Seed class
  #
  class Seed < Script
    def self.find(database_name)
      super(database_name, :seed)
    end

    def to_s
      "Seed data #{@name} for `#{@file.database}` database, datetime: #{@datetime}"
    end
  end
end
