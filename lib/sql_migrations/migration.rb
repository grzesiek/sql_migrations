module SqlMigrations
  # Migration class
  #
  class Migration < Script
    def self.find(database_name)
      super(database_name, :migration)
    end

    def to_s
      "Migration #{name} for `#{@file.database}` database, datetime: #{datetime}"
    end
  end
end
