module SqlMigrations
  class Fixture < SqlFile

    def self.find(db_name)
      super(db_name, :fixture)
    end

    def to_s
      "Fixture #{@name}, datetime: #{@date + @time}"
    end

  end
end
