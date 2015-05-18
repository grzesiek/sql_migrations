describe 'migration' do
  before do
    Dir.mkdir('/migrations')
    File.open('/migrations/20150305_154010_test_migration.sql', 'w') do |f|
      f.puts 'CREATE TABLE test_table(col_int INTEGER, col_str STRING)'
    end
    allow(SqlMigrations::Config).to receive(:databases) { { default: { development: {} } } }
    @migration = SqlMigrations::Migration.find(:default).first
  end

  it 'should be found and initialized' do
    expect(@migration).to be_a(SqlMigrations::Migration)
  end

  it 'should have proper date' do
    expect(@migration.date).to eql('20150305')
  end

  it 'should have proper time' do
    expect(@migration.time).to eql('154010')
  end

  it 'should have proper name' do
    expect(@migration.name).to eql('test_migration')
  end

  it 'should be properly executed' do
    database = SqlMigrations::Database.new(:default, adapter: :sqlite)
    @migration.execute(database)
    expect(@sqlite_db.table_exists?(:test_table)).to be true
    expect(@sqlite_db[:test_table].columns).to include(:col_int)
    expect(@sqlite_db[:test_table].columns).to include(:col_str)
  end
end
