describe 'multistatement migration' do
  before do
    Dir.mkdir('/migrations')
    File.open('/migrations/20150514_154010_test_multistatement_migration.sql', 'w') do |f|
      f.puts 'CREATE TABLE multi_test_table1(col_int1 INTEGER, col_str1 STRING);'
      f.puts 'CREATE TABLE multi_test_table2(col_int2 INTEGER, col_str2 STRING);'
    end
    allow(SqlMigrations::Config).to receive(:databases) { { default: { development: {} } } }
    allow(SqlMigrations::Config).to receive(:options) { { separator: ';' } }
    @migration = SqlMigrations::Migration.find(:default).first
  end

  it 'should have multiple statements' do
    expect(@migration.statements.count).to eq 2
  end

  it 'should be properly executed' do
    $stdout = StringIO.new
    database = SqlMigrations::Database.new(:default, adapter: :sqlite)
    @migration.execute(database)
    expect(@sqlite_db.table_exists?(:multi_test_table1)).to be true
    expect(@sqlite_db[:multi_test_table1].columns).to include(:col_int1)
    expect(@sqlite_db[:multi_test_table1].columns).to include(:col_str1)
    expect(@sqlite_db.table_exists?(:multi_test_table2)).to be true
    expect(@sqlite_db[:multi_test_table2].columns).to include(:col_int2)
    expect(@sqlite_db[:multi_test_table2].columns).to include(:col_str2)
  end
end
