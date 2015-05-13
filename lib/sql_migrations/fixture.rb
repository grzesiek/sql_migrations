module SqlMigrations
  # Fixture class
  #
  class Fixture < SqlScript
    def self.find(db_name)
      super(db_name, :fixture)
    end

    def to_s
      "Fixture #{@name} for `#{@db_name}` database, datetime: #{@date + @time}"
    end
  end
end
