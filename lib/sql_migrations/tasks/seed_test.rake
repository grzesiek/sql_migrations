namespace :sqlmigrations do
  namespace :db do
    namespace :test do
      desc "Seed test database with fixtures"
      task :seed do
        SqlMigrations::Supervisor.new.seed_test
      end
    end
  end
end
