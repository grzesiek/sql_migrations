module SqlMigrations
  class Fixture < SqlFile

    def self.find
      super(:fixture)
    end

    def to_s
      "Fixture #{@name}, datetime: #{@date + @time}"
    end

  end
end
