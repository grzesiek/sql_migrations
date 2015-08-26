require 'simplecov'
require 'memfs'
require 'pp' # `superclass mismatch for class File` workaround

SimpleCov.start
require 'sql_migrations'

RSpec.configure do |config|
  config.profile_examples = 2
  config.order = :random
  Kernel.srand config.seed

  config.before do
    @sqlite_db = Sequel.sqlite
    allow(SqlMigrations::Database).to receive(:connect) { @sqlite_db }
    MemFs.activate!
    # Reset configuration for every test suite
    SqlMigrations::Config.instance_eval('@databases = nil; @options = nil')
    @stdout, $stdout = $stdout, StringIO.new  # Catch STDOUT do variable
  end

  config.after do
    $stdout, @stdout = @stdout, nil   # Reassign STDOUT
    MemFs.deactivate!
  end
end
