describe 'sql scripts' do
  before do
    Dir.mkdir('/migrations')
    Dir.mkdir('/seed')
    Dir.mkdir('/fixtures')

    File.open('/migrations/20150305_154010_first_test_migration.sql', 'w') do |f|
      f.puts "CREATE TABLE first_test_table(col_int1 INTEGER, col_str1 STRING)"
    end
    File.open('/migrations/20150305_154011_second_test_migration.sql', 'w') do |f|
      f.puts "CREATE TABLE second_test_table(col_int2 INTEGER, col_str2 STRING)"
    end
    File.open('/seed/20150305_154010_test_seed.sql', 'w') do |f|
      f.puts "INSERT INTO first_test_table(col_int1, col_str1) VALUES(123, 'test_string1')"
      f.puts "INSERT INTO second_test_table(col_int2, col_str2) VALUES(456, 'test_string2')"
    end
    File.open('/fixtures/20150305_154010_test_test_seed', 'w') do |f|
      f.puts "INSERT INTO first_test_table(col_int1, col_str1) VALUES(2123, '2test_string1')"
      f.puts "INSERT INTO second_test_table(col_int2, col_str2) VALUES(2456, '2test_string2')"
    end
  end

  it 'should be found' do
    expect { SqlMigrations::Supervisor.new.list_files }.to \
      output("Migration first_test_migration for db: default, datetime: 20150305154010\n" +
             "Migration second_test_migration for db: default, datetime: 20150305154011\n" +
             "Seed data test_seed, datetime: 20150305154010\n").to_stdout
  end

end
