module SqlMigrations
  # Seed class
  #
  class Seed < Script
    def self.find(database_name)
      super(database_name, :seed)
    end
  end
end
