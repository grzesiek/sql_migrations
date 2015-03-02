module SqlMigrations
  class Migration < SqlFile

    def self.find
      super(:migrations)
    end

    def to_s
      "Migration #{@name}, datetime: #{@date + @time}"
    end

    def execute(db)
      puts "[m] Running migration #{@name}, added #{@date}"
      super
    end
  end
end
