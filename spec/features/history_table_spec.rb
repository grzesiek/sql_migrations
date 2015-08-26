describe 'history table in database' do
  before do
    allow(SqlMigrations::Config).to receive(:databases) { { default: {} } }
  end

  it 'should be created if it does not exist' do
    expect do
      @database = SqlMigrations::Database.new(:default, adapter: :sqlite)
    end.to output("[+] Connected to `default` database using sqlite adapter\n" \
                  "[!] Installing `sqlmigrations_schema` history table\n").to_stdout
    expect(@database.driver.table_exists?(:sqlmigrations_schema)).to be true
  end

  it 'should not be create if it exists' do
    @sqlite_db.create_table(:sqlmigrations_schema) do
      # rubocop:disable Style/SingleSpaceBeforeFirstArg
      primary_key :id
      Bignum      :time
      DateTime    :executed
      String      :name
      String      :type
      index       [:time, :type]
      # rubocop:enable Style/SingleSpaceBeforeFirstArg
    end
    expect do
      @database = SqlMigrations::Database.new(:default, adapter: :sqlite)
    end.to output("[+] Connected to `default` database using sqlite adapter\n").to_stdout
    expect(@database.driver.table_exists?(:sqlmigrations_schema)).to be true
  end
end
