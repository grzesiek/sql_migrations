namespace :sqlmigrations do
  namespace :db do
    desc 'List found migration and seed files'
    task :scripts do
      SqlMigrations.scripts
    end
  end
end
