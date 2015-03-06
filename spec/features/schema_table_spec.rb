describe 'schema table in database' do

  it 'should be created if it does not exist' do
    expect do
      @database = SqlMigrations::Database.new(name: :default, 'adapter' => :sqlite)
    end.to output("[+] Connected to database using sqlite adapter\n" +
                  "[!] Installing `sqlmigrations_schema`\n").to_stdout
    expect(@database.db.table_exists?(:sqlmigrations_schema)).to be true
  end

  it 'should not be create if it exists' do
    @sqlite_db.create_table(:sqlmigrations_schema) do
      primary_key :id
      Bignum   :time
      DateTime :executed
      String   :name
      String   :type
      index [ :time, :type ]
    end
    expect do
      @database = SqlMigrations::Database.new(name: :default, 'adapter' => :sqlite)
    end.to output("[+] Connected to database using sqlite adapter\n").to_stdout
    expect(@database.db.table_exists?(:sqlmigrations_schema)).to be true
  end

end
