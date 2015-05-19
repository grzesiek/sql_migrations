module SqlMigrations
  # Seed class
  #
  class Seed < SqlScript
    def self.find(database_name)
      super(database_name, :seed)
    end

    def to_s
      "Seed data #{@name} for `#{@database_name}` database, datetime: #{@date + @time}"
    end
  end
end
