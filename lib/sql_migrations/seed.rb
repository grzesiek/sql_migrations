module SqlMigrations
  class Seed < SqlFile

    def self.find
      super(:seed)
    end

    def to_s
      "Seed data #{@name}, datetime: #{@date + @time}"
    end

  end
end
