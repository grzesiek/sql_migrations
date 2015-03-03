module SqlMigrations
  class Seed < SqlFile

    def self.find(db_name = nil)
      super(db_name, :seed)
    end

    def to_s
      "Seed data #{@name}, datetime: #{@date + @time}"
    end

  end
end
