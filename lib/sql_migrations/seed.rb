module SqlMigrations
  # Seed class
  #
  class Seed < Script
    def self.find(database_name, path_migration_seed = "")
      super(database_name, :seed, path_migration_seed)
    end
  end
end

