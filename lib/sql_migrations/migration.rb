module SqlMigrations
  # Migration class
  #
  class Migration < SqlScript
    def self.find(db_name)
      super(db_name, :migrations)
    end

    def to_s
      "Migration #{@name} for `#{@db_name}` database, datetime: #{@date + @time}"
    end
  end
end
