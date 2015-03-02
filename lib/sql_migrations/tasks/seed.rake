namespace :sqlmigrations do
  namespace :db do
    desc "Seed database"
    task :seed do
      SqlMigrations::Database.seed
    end
  end
end
