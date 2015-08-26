module SqlMigrations
  # Migration class
  #
  class Migration < Script
    def self.find(database_name)
      super(database_name, :migration)
    end
  end
end
