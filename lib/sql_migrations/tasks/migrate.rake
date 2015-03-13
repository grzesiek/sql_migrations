namespace :sqlmigrations do
  namespace :db do
    desc "Run migrations"
    task :migrate do
      SqlMigrations.migrate
    end
  end
end
