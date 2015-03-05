describe 'schema table in database' do
  before(:each) do
    allow(SqlMigrations::Database).to receive(:connect) { Sequel.sqlite }
  end

  it 'should create schema table if it does not exist' do
    expect do
      @database = SqlMigrations::Database.new(name: :default, 'adapter' => :sqlite)
    end.to output("[+] Connected to database using sqlite adapter\n" +
                  "[!] Installing `sqlmigrations_schema`\n").to_stdout
    expect(@database.db.table_exists?(:sqlmigrations_schema)).to be true
  end
end
