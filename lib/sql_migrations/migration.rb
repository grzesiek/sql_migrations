module SqlMigrations
  # Migration class
  #
  class Migration < Script
    def self.find(database_name, path_migration_seed)
      super(database_name, :migration, path_migration_seed)
    end
  end
end
