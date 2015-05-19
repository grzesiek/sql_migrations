module SqlMigrations
  # Fixture class
  #
  class Fixture < SqlScript
    def self.find(database_name)
      super(database_name, :fixture)
    end

    def to_s
      "Fixture #{@name} for `#{@database_name}` database, datetime: #{@date + @time}"
    end
  end
end
