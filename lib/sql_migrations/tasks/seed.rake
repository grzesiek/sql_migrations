namespace :sqlmigrations do
  namespace :db do
    desc 'Seed database'
    task :seed do
      SqlMigrations.seed
    end
  end
end
