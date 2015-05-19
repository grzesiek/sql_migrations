module SqlMigrations
  # Migration class
  #
  class Migration < SqlScript
    def self.find(database_name)
      super(database_name, :migration)
    end

    def to_s
      "Migration #{@name} for `#{@database_name}` database, datetime: #{@date + @time}"
    end
  end
end
