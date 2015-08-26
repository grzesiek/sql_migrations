module SqlMigrations
  # Fixture class
  #
  class Fixture < Script
    def self.find(database_name)
      super(database_name, :fixture)
    end

    def to_s
      "Fixture #{name} for `#{@file.database}` database, datetime: #{datetime}"
    end
  end
end
