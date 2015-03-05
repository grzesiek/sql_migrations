require 'memfs'

describe 'migration support' do
  before do
    allow(SqlMigrations::Database).to receive(:connect) { Sequel.sqlite }
    allow(SqlMigrations).to receive(:options) { { default: { development: {}}} }
    MemFs.activate!
    Dir.mkdir('/migrations')
    File.open('/migrations/20150305_154010_test_migration.sql', 'w') do |f|
      f.puts "CREATE TABLE test_table(col_int INTEGER, col_str STRING)"
    end
  end

  it 'should find migration file' do
    expect { SqlMigrations::Supervisor.new.list_files }.to \
      output("Migration test_migration for db: default, datetime: 20150305154010\n").to_stdout
  end

  it 'migration should find migration and initialize migration object' do
    migration = SqlMigrations::Migration.find([ :default ]).first
    expect(migration).to be_a(SqlMigrations::Migration)
  end

  it 'migration should have proper date' do
    migration = SqlMigrations::Migration.find([ :default ]).first
    expect(migration.date).to eql('20150305')
  end

  it 'migration should have proper time' do
    migration = SqlMigrations::Migration.find([ :default ]).first
    expect(migration.time).to eql('154010')
  end

  it 'migration should have proper name' do
    migration = SqlMigrations::Migration.find([ :default ]).first
    expect(migration.name).to eql('test_migration')
  end

  after do
    MemFs.deactivate!
  end
end
