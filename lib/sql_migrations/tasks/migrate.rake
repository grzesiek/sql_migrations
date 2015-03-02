namespace :sqlmigrations do
  namespace :db do
    desc "Run migrations"
    task :migrate do
      SqlMigrations::Database.migrate
    end
  end
end
