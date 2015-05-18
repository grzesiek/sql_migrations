describe 'fixture' do
  before do
    Dir.mkdir('/migrations')
    File.open('/migrations/20150305_154010_test_migration.sql', 'w') do |f|
      f.puts 'CREATE TABLE test_table_fixture(col_int INTEGER, col_str STRING)'
    end
    Dir.mkdir('/fixtures')
    File.open('/fixtures/20150305_154012_test_fixture.sql', 'w') do |f|
      f.puts 'INSERT INTO test_table_fixture VALUES(12, "test_string_fixture")'
    end
    allow(SqlMigrations::Config).to receive(:databases) { { default: { development: {} } } }
    database = SqlMigrations::Database.new(:default, adapter: :sqlite)
    database.execute_migrations
    database.seed_with_fixtures
  end

  it 'should be properly executed' do
    expect(@sqlite_db.table_exists?(:test_table_fixture)).to be true
    expect(@sqlite_db[:test_table_fixture].first)
      .to eq(col_int: 12, col_str: 'test_string_fixture')
  end
end
