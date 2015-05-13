require 'bundler/setup'
require 'memfs'
Bundler.require

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
  end

  config.after do
    MemFs.deactivate!
  end
end
