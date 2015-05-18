describe 'migrations valid order support engine' do
  before do
    allow(SqlMigrations::Config).to receive(:databases) { { default: { development: {} } } }
    Dir.mkdir('/migrations')
    File.open('/migrations/20150305_154010_test_migration.sql', 'w') do |f|
      f.puts 'CREATE TABLE test_table(col_int INTEGER, col_str STRING)'
    end

    @database  = SqlMigrations::Database.new(:default, adapter: :sqlite)
    migration = SqlMigrations::Migration.find(:default).first
    migration.execute(@database)

    File.open('/migrations/20150305_154011_test2_migration.sql', 'w') do |f|
      f.puts 'CREATE TABLE test_table2(col_int2 INTEGER, col_str2 STRING)'
    end
    File.open('/migrations/20150305_154012_test3_migration.sql', 'w') do |f|
      f.puts 'CREATE TABLE test_table3(col_int3 INTEGER, col_str3 STRING)'
    end
    @migrations = SqlMigrations::Migration.find(:default)
  end

  it 'should find all migrations' do
    expect(@migrations.count).to be 3
  end

  it 'should execute only two migrations' do
    statuses = @migrations.map do |migration|
      migration.execute(@database)
    end
    expect(statuses[0]).to be false
    expect(statuses[1]).to be true
    expect(statuses[2]).to be true
  end

  it 'should create all tables' do
    @migrations.each { |migration| migration.execute(@database) }
    expect(@sqlite_db.table_exists?(:test_table)).to be true
    expect(@sqlite_db[:test_table].columns).to include(:col_int)
    expect(@sqlite_db[:test_table].columns).to include(:col_str)
    expect(@sqlite_db.table_exists?(:test_table2)).to be true
    expect(@sqlite_db[:test_table2].columns).to include(:col_int2)
    expect(@sqlite_db[:test_table2].columns).to include(:col_str2)
    expect(@sqlite_db.table_exists?(:test_table3)).to be true
    expect(@sqlite_db[:test_table3].columns).to include(:col_int3)
    expect(@sqlite_db[:test_table3].columns).to include(:col_str3)
  end
end
