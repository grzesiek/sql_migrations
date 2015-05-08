require 'bundler/setup'
require 'memfs'
Bundler.require

RSpec.configure do |config|
  config.before do
    @sqlite_db = Sequel.sqlite
    allow(SqlMigrations::Database).to receive(:connect) { @sqlite_db }
    MemFs.activate!
  end

  config.after do
    MemFs.deactivate!
  end
end
