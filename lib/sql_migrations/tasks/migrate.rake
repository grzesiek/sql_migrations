namespace :sqlmigrations do
  namespace :db do
    desc "Run migrations"
    task :migrate do
      SqlMigrations::Supervisor.new.migrate
    end
  end
end
