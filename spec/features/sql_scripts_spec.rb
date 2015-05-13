# rubocop:disable Metrics/LineLength
describe 'sql scripts' do
  before do
    Dir.mkdir('/migrations')
    Dir.mkdir('/seed')
    Dir.mkdir('/fixtures')

    File.open('/migrations/20150305_154010_first_test_migration.sql', 'w') do |f|
      f.puts 'CREATE TABLE first_test_table(col_int1 INTEGER, col_str1 STRING)'
    end
    File.open('/migrations/20150305_154011_second_test_migration.sql', 'w') do |f|
      f.puts 'CREATE TABLE second_test_table(col_int2 INTEGER, col_str2 STRING)'
    end
    File.open('/seed/20150305_154010_test_seed.sql', 'w') do |f|
      f.puts 'INSERT INTO first_test_table(col_int1, col_str1) VALUES(123, "test_string1")'
      f.puts 'INSERT INTO second_test_table(col_int2, col_str2) VALUES(456, "test_string2")'
    end
    File.open('/fixtures/20150305_154010_test_test_seed', 'w') do |f|
      f.puts 'INSERT INTO first_test2_table(col_int1, col_str1) VALUES(2123, "2test_string1")'
      f.puts 'INSERT INTO second_test2_table(col_int2, col_str2) VALUES(2456, "2test_string2")'
    end

    Dir.mkdir('/migrations/test2_db')
    File.open('/migrations/test2_db/20150511_144000_second_db_test_migration.sql', 'w') do |f|
      f.puts 'CREATE TABLE second_db_test_table(col_int1 INTEGER, col_str1 STRING)'
    end

    Dir.mkdir('/migrations/default')
    File.open('/migrations/default//20150511_144100_default_db_test2_migration.sql', 'w') do |f|
      f.puts 'CREATE TABLE default_db_test2_table(col_int1 INTEGER, col_str1 STRING)'
    end

    allow(SqlMigrations::Config).to receive(:databases) { { default: {}, test2_db: {} } }
  end

  it 'should be found' do
    expect { SqlMigrations.list_files }.to \
      output("Migration first_test_migration for `default` database, datetime: 20150305154010\n" \
             "Migration second_test_migration for `default` database, datetime: 20150305154011\n" \
             "Migration default_db_test2_migration for `default` database, datetime: 20150511144100\n" \
             "Seed data test_seed for `default` database, datetime: 20150305154010\n" \
             "Migration second_db_test_migration for `test2_db` database, datetime: 20150511144000\n"
            ).to_stdout
  end
end
# rubocop:enable Metrics/LineLength
