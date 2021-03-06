describe 'migration' do
  before do
    Dir.mkdir('/migrations')
    File.open('/migrations/20150305_154010_test_migration.sql', 'w') do |f|
      f.puts 'CREATE TABLE test_table(col_int INTEGER, col_str STRING)'
    end

    allow(SqlMigrations::Config).to receive(:databases) { { default: { development: {} } } }
    @migration = SqlMigrations::Migration.find(:default).first
    @database  = SqlMigrations::Database.new(:default, adapter: :sqlite)
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

  context 'executing migrations' do
    subject { -> { @database.migrate } }

    it 'should be properly executed' do
      subject.call
      expect(@sqlite_db.table_exists?(:test_table)).to be true
      expect(@sqlite_db[:test_table].columns).to include(:col_int)
      expect(@sqlite_db[:test_table].columns).to include(:col_str)
    end

    context 'migration datetime before last one' do
      before do
        subject.call
        File.open('/migrations/20150201_200000_new_before_migration.sql', 'w') do |f|
          f.puts 'CREATE TABLE before_table(col_int INTEGER, col_str STRING)'
        end
      end

      it 'should print warning' do
        expect { subject.call }
          .to output(/datetime BEFORE last one executed !/).to_stdout
      end
    end

    context 'invalid migration' do
      before do
        File.open('/migrations/20150825_184010_invalid_migration.sql', 'w') do |f|
          f.puts 'CREATE this_is_error TABLE invalid'
        end
      end

      it 'should print warning about invalid migration' do
        expect { subject.call }
          .to output(/Error while executing migration invalid_migration !/).to_stdout
          .and raise_error(Sequel::DatabaseError)
      end
    end
  end
end
