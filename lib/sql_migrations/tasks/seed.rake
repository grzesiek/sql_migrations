namespace :sqlmigrations do
  namespace :db do
    desc "Seed database"
    task :seed do
      SqlMigrations::Supervisor.new.seed
    end
  end
end
