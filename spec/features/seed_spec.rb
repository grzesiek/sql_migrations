describe 'seed' do
  before do
    Dir.mkdir('/migrations')
    File.open('/migrations/20150305_154010_test_migration.sql', 'w') do |f|
      f.puts 'CREATE TABLE test_table(col_int INTEGER, col_str STRING)'
    end
    Dir.mkdir('/seeds')
    File.open('/seeds/20150305_154011_test_seed.sql', 'w') do |f|
      f.puts 'INSERT INTO test_table VALUES(10, "test_string")'
    end
    allow(SqlMigrations::Config).to receive(:databases) { { default: { development: {} } } }
    database = SqlMigrations::Database.new(:default, adapter: :sqlite)
    database.migrate
    database.seed
  end

  it 'should be properly execute' do
    expect(@sqlite_db.table_exists?(:test_table)).to be true
    expect(@sqlite_db[:test_table].first).to eq(col_int: 10, col_str: 'test_string')
  end
end
