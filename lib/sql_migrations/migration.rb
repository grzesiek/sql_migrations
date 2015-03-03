module SqlMigrations
  class Migration < SqlScript

    def self.find(db_name)
      super(db_name, :migrations)
    end

    def to_s
      "Migration #{@name} for db: #{@db_name}, datetime: #{@date + @time}"
    end

  end
end
