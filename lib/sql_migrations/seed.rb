module SqlMigrations
  class Seed < SqlFile

    def self.find
      super(:seed)
    end

    def to_s
      "Seed data #{@name}, datetime: #{@date + @time}"
    end

    def execute(db)
      puts "[s] Inserting seed date #{@name}, added #{@date}"
      super
    end
  end
end
