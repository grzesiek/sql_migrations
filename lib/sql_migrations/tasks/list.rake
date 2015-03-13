namespace :sqlmigrations do
  namespace :files do
    desc "List found migration and seed files"
    task :list do
      SqlMigrations.list_files
    end
  end
end
